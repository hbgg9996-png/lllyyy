#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface SthenoEdgeFloatController : NSObject
@property(nonatomic, weak) UIWindow *window;
@property(nonatomic) CGPoint lastCenter;
@property(nonatomic) CFTimeInterval lastMoveTime;
@property(nonatomic) BOOL snapping;
@property(nonatomic) NSTimer *timer;
- (instancetype)initWithWindow:(UIWindow *)window;
- (void)observeFrameChange;
@end

static BOOL STHEnabled(void) {
    NSDictionary *p = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.nx.stheno.plist"];
    id v = p[@"EdgeFloatEnabled"];
    return v ? [v boolValue] : YES;
}

static CGFloat STHNumber(NSString *key, CGFloat fallback) {
    NSDictionary *p = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.nx.stheno.plist"];
    CGFloat v = [p[key] doubleValue];
    return v > 0 ? v : fallback;
}

@implementation SthenoEdgeFloatController
- (instancetype)initWithWindow:(UIWindow *)window {
    if ((self = [super init])) {
        _window = window;
        _lastCenter = window.center;
        _lastMoveTime = CACurrentMediaTime();
    }
    return self;
}

- (void)observeFrameChange {
    UIWindow *w = self.window;
    if (!w || !STHEnabled() || self.snapping) return;
    CGPoint c = w.center;
    if (fabs(c.x - self.lastCenter.x) < 0.5 && fabs(c.y - self.lastCenter.y) < 0.5) return;
    self.lastCenter = c;
    self.lastMoveTime = CACurrentMediaTime();
    [self.timer invalidate];
    NSTimeInterval delay = STHNumber(@"EdgeFloatDelay", 0.18);
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:delay repeats:NO block:^(__unused NSTimer *t) {
        [weakSelf snapIfNeeded];
    }];
}

- (void)snapIfNeeded {
    UIWindow *w = self.window;
    if (!w || !STHEnabled()) return;
    UIWindowScene *scene = w.windowScene;
    CGRect bounds = scene ? scene.coordinateSpace.bounds : UIScreen.mainScreen.bounds;
    CGRect frame = [w convertRect:w.bounds toView:nil];
    CGFloat threshold = STHNumber(@"EdgeFloatThreshold", MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds)) * 0.045);
    CGFloat left = CGRectGetMinX(frame);
    CGFloat right = CGRectGetMaxX(bounds) - CGRectGetMaxX(frame);
    CGFloat top = CGRectGetMinY(frame);
    CGFloat bottom = CGRectGetMaxY(bounds) - CGRectGetMaxY(frame);
    CGFloat minGap = MIN(MIN(left, right), MIN(top, bottom));
    if (minGap > threshold) return;

    BOOL horizontal = MIN(left, right) <= MIN(top, bottom);
    CGRect target = frame;
    if (horizontal) {
        CGFloat width = CGRectGetWidth(bounds) * STHNumber(@"EdgeFloatWidthFraction", 0.42);
        width = MAX(280.0, MIN(width, CGRectGetWidth(bounds) * 0.60));
        target.size.width = MIN(width, CGRectGetWidth(bounds));
        target.origin.x = left <= right ? 0 : CGRectGetWidth(bounds) - target.size.width;
        target.origin.y = MIN(MAX(CGRectGetMidY(frame) - CGRectGetHeight(target)/2.0, 0), CGRectGetHeight(bounds) - CGRectGetHeight(target));
    } else {
        CGFloat height = CGRectGetHeight(bounds) * STHNumber(@"EdgeFloatHeightFraction", 0.48);
        height = MAX(220.0, MIN(height, CGRectGetHeight(bounds) * 0.65));
        target.size.height = MIN(height, CGRectGetHeight(bounds));
        target.origin.y = top <= bottom ? 0 : CGRectGetHeight(bounds) - target.size.height;
        target.origin.x = MIN(MAX(CGRectGetMidX(frame) - CGRectGetWidth(target)/2.0, 0), CGRectGetWidth(bounds) - CGRectGetWidth(target));
    }
    self.snapping = YES;
    [UIView animateWithDuration:0.24 delay:0 usingSpringWithDamping:0.86 initialSpringVelocity:0.2 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{
        w.frame = target;
        w.layer.cornerRadius = 14.0;
        w.clipsToBounds = YES;
    } completion:^(__unused BOOL finished) {
        self.snapping = NO;
        self.lastCenter = w.center;
    }];
}
@end

static NSMutableDictionary<NSValue *, SthenoEdgeFloatController *> *STHControllers;
static void STHInstallForWindow(UIWindow *w) {
    if (!w || ![w isKindOfClass:NSClassFromString(@"Stheno.SthenoWindow")]) return;
    if (!STHControllers) STHControllers = [NSMutableDictionary dictionary];
    NSValue *key = [NSValue valueWithNonretainedObject:w];
    if (!STHControllers[key]) STHControllers[key] = [[SthenoEdgeFloatController alloc] initWithWindow:w];
}

%hook UIWindow
- (void)setFrame:(CGRect)frame {
    %orig;
    STHInstallForWindow(self);
    SthenoEdgeFloatController *c = STHControllers[[NSValue valueWithNonretainedObject:self]];
    [c observeFrameChange];
}
%end

%ctor {
    STHControllers = [NSMutableDictionary dictionary];
}
