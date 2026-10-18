#!/usr/bin/env python3
from PIL import Image, ImageDraw

SIZE = 1024
img = Image.new('RGB', (SIZE, SIZE))
d = ImageDraw.Draw(img)

# 垂直渐变背景：蓝 -> 紫
top = (37, 99, 235)
bottom = (139, 92, 246)
for y in range(SIZE):
    t = y / (SIZE - 1)
    r = int(top[0] + (bottom[0] - top[0]) * t)
    g = int(top[1] + (bottom[1] - top[1]) * t)
    b = int(top[2] + (bottom[2] - top[2]) * t)
    d.line([(0, y), (SIZE, y)], fill=(r, g, b))

# 圆角方形 alpha
mask = Image.new('L', (SIZE, SIZE), 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=224, fill=255)

# 白色字母 L（几何笔画，不依赖字体）
L = Image.new('L', (SIZE, SIZE), 0)
ld = ImageDraw.Draw(L)
ld.rounded_rectangle([360, 290, 470, 700], radius=40, fill=255)   # 竖笔
ld.rounded_rectangle([360, 590, 720, 700], radius=40, fill=255)   # 横笔

rgba = img.convert('RGBA')
rgba.putalpha(mask)
white = Image.new('RGBA', (SIZE, SIZE), (255, 255, 255, 255))
white.putalpha(L)
rgba = Image.alpha_composite(rgba, white)

rgba.resize((512, 512), Image.LANCZOS).save('/var/minis/workspace/cydia-repo/CydiaIcon@2x.png')
rgba.resize((256, 256), Image.LANCZOS).save('/var/minis/workspace/cydia-repo/CydiaIcon.png')
print('icons generated OK')