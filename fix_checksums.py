#!/usr/bin/env python3
"""修正 Packages 里的 MD5/SHA1/SHA256/Size 为文件真实值。
本环境 dpkg-scanpackages 的 SHA1/SHA256 输出有 bug（MD5 正常），
Sileo 依赖 SHA256 校验，必须用真实值覆盖。"""
import re, hashlib, os, sys

pkgfile = sys.argv[1] if len(sys.argv) > 1 else 'Packages'
txt = open(pkgfile, encoding='utf-8', errors='replace').read()
paras = [p for p in txt.split('\n\n') if p.strip()]
out = []
fixed = 0
for p in paras:
    m = re.search(r'^Filename:\s*(\S+)$', p, flags=re.M)
    if m and os.path.exists(m.group(1)):
        data = open(m.group(1), 'rb').read()
        md5 = hashlib.md5(data).hexdigest()
        sha1 = hashlib.sha1(data).hexdigest()
        sha256 = hashlib.sha256(data).hexdigest()
        size = len(data)
        newp = re.sub(r'^MD5sum:\s*\S+$', 'MD5sum: ' + md5, p, flags=re.M)
        newp = re.sub(r'^SHA1:\s*\S+$', 'SHA1: ' + sha1, newp, flags=re.M)
        newp = re.sub(r'^SHA256:\s*\S+$', 'SHA256: ' + sha256, newp, flags=re.M)
        newp = re.sub(r'^Size:\s*\S+$', 'Size: %d' % size, newp, flags=re.M)
        if newp != p:
            fixed += 1
        p = newp
    out.append(p)
open(pkgfile, 'w', encoding='utf-8').write('\n\n'.join(out) + '\n')
print('fixed checksums in %d/%d entries' % (fixed, len(out)))
