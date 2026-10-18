# lllyyy — Cydia / Sileo 越狱源

越狱源地址：

```
https://hbgg9996-png.github.io/lllyyy/
```

## 添加源

- **Sileo / Zebra**：软件源 → 右上角 `+` → 粘贴上面的地址
- **Cydia**：`Sources` → `Edit` → `Add` → 粘贴上面的地址

## 目录结构

| 文件 | 说明 |
| --- | --- |
| `deb/` | 打包好的 `.deb` 文件放这里 |
| `Packages` | 包索引（自动生成） |
| `Packages.gz` / `Packages.bz2` | 压缩索引（自动生成） |
| `Release` | 仓库元信息（自动生成） |

## 添加新包

1. 把 `.deb` 文件放进 `deb/` 目录
2. 在仓库根目录运行：

```bash
./add-packages.sh
```

3. 提交并推送：

```bash
git add -A && git commit -m "add package xxx" && git push
```

## 签名（可选）

未签名的源在 Sileo 中会显示「未签名」警告，但可正常添加和使用。
如需签名，可生成 GPG 密钥后对 `Release` 签名（`gpg -abs -o Release.gpg Release`），并把 `Release.gpg` 一并推送。