# SthenoEdgeFloat

这是一个独立加载的 Stheno 扩展原型，不修改原始 `Stheno.dylib`。

功能：当 `Stheno.SthenoWindow` 的分屏窗口被拖到屏幕边缘，并在短暂延迟内停止移动时，将窗口吸附到最近边缘并缩小为悬浮窗尺寸。

默认行为：
- 吸附距离：屏幕短边的 4.5%
- 停止判定：180 ms
- 左/右边吸附宽度：屏幕宽度的 42%，限制 280–60%
- 上/下边吸附高度：屏幕高度的 48%
- 触发时不改变原 Stheno 配置和原始 dylib

## 配置键

写入 `/var/mobile/Library/Preferences/com.nx.stheno.plist` 可调整：

```text
EdgeFloatEnabled = YES
EdgeFloatThreshold = 0       // 0 使用默认值，单位 pt
EdgeFloatDelay = 0            // 0 使用 0.18 秒
EdgeFloatWidthFraction = 0    // 0 使用 0.42
EdgeFloatHeightFraction = 0   // 0 使用 0.48
```

实现限制：此版本通过 `Stheno.SthenoWindow` 的 frame 层实现视觉及交互上的悬浮化，尚未直接调用 Stheno 私有的 `ReflectManager` 内部状态切换。因此在部分版本上，窗口可能在下一次原插件布局刷新时被还原；要完全持久化，需要继续针对对应版本的 `ReflectManager`/Scene 状态函数做 ABI 级适配。
