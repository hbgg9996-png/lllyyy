#!/bin/sh
# 重新生成 Packages / Packages.gz / Packages.bz2 / Release
# 用法：把 .deb 放进 deb/ 目录，然后运行 ./add-packages.sh
set -e
cd "$(dirname "$0")"

REPO_NAME="lllyyy"
REPO_DESC="Cydia/Sileo jailbreak repository"
ARCHS="iphoneos-arm iphoneos-arm64 iphoneos-arm64e"

# 1. 扫描 deb/ 生成 Packages
dpkg-scanpackages -m deb /dev/null > Packages

# 2. 压缩索引
gzip -9 -c Packages > Packages.gz
bzip2 -9 -c Packages > Packages.bz2

# 3. 生成 Release（含校验和）
{
  echo "Origin: $REPO_NAME"
  echo "Label: $REPO_NAME"
  echo "Suite: stable"
  echo "Version: 1.0"
  echo "Codename: stable"
  echo "Architectures: $ARCHS"
  echo "Components: main"
  echo "Description: $REPO_DESC"
  echo "MD5Sum:"
  for f in Packages Packages.gz Packages.bz2; do
    [ -f "$f" ] || continue
    printf ' %s %s %s\n' "$(md5sum "$f" | cut -d' ' -f1)" "$(stat -c%s "$f")" "$f"
  done
  echo "SHA1:"
  for f in Packages Packages.gz Packages.bz2; do
    [ -f "$f" ] || continue
    printf ' %s %s %s\n' "$(sha1sum "$f" | cut -d' ' -f1)" "$(stat -c%s "$f")" "$f"
  done
  echo "SHA256:"
  for f in Packages Packages.gz Packages.bz2; do
    [ -f "$f" ] || continue
    printf ' %s %s %s\n' "$(sha256sum "$f" | cut -d' ' -f1)" "$(stat -c%s "$f")" "$f"
  done
} > Release

echo "OK -> Packages, Packages.gz, Packages.bz2, Release"