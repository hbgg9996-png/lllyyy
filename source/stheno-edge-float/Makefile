ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:14.0
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SthenoEdgeFloat
SthenoEdgeFloat_FILES = Tweak.xm
SthenoEdgeFloat_CFLAGS = -fobjc-arc
SthenoEdgeFloat_FRAMEWORKS = UIKit QuartzCore
SthenoEdgeFloat_PRIVATE_FRAMEWORKS = SpringBoard
SthenoEdgeFloat_EXTRA_FRAMEWORKS = CydiaSubstrate
SthenoEdgeFloat_PLIST_FILES = SthenoEdgeFloat.plist:Library/MobileSubstrate/DynamicLibraries/SthenoEdgeFloat.plist

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
