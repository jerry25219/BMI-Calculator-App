#!/usr/bin/env bash
set -euo pipefail

# 项目根目录
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

# 检查 Flutter 环境
if ! command -v flutter >/dev/null 2>&1; then
  echo "[ERROR] Flutter 未安装或不可用，请先安装 Flutter 并配置 PATH。"
  exit 1
fi

# 解析 pubspec.yaml 的 version 字段：形如 1.2.3+45
# 处理可能的 CRLF（\r）换行符，避免输出文件名出现回车字符
VERSION_LINE=$(grep -E "^version:" pubspec.yaml | sed -E 's/^version:[[:space:]]*//')
VERSION_LINE=$(echo "$VERSION_LINE" | tr -d '\r')
VERSION_NAME="${VERSION_LINE%%+*}"
VERSION_CODE="${VERSION_LINE##*+}"

if [[ -z "$VERSION_NAME" || -z "$VERSION_CODE" || "$VERSION_NAME" == "$VERSION_LINE" ]]; then
  echo "[ERROR] 无法从 pubspec.yaml 解析版本号，请确保存在形如: version: 1.2.3+45 的行。"
  exit 1
fi

DIST_DIR="$ROOT_DIR/dist"
mkdir -p "$DIST_DIR"

DEBUG_INFO_DIR="$ROOT_DIR/build/debug-info"
mkdir -p "$DEBUG_INFO_DIR"

echo "[INFO] 开始构建 Release APK..."
flutter build apk --release --obfuscate --split-debug-info="$DEBUG_INFO_DIR"
echo "[INFO] 构建完成。"

# 兼容不同 Flutter 版本下的 APK 输出路径
APK_PRIMARY="$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk"
APK_LEGACY="$ROOT_DIR/build/app/outputs/apk/release/app-release.apk"

BASE_NAME="bmi_${VERSION_NAME}_${VERSION_CODE}"

if [[ -f "$APK_PRIMARY" ]]; then
  NEW_PATH="$DIST_DIR/${BASE_NAME}.apk"
  cp -f "$APK_PRIMARY" "$NEW_PATH"
  echo "[INFO] APK 输出: $NEW_PATH"
  exit 0
elif [[ -f "$APK_LEGACY" ]]; then
  NEW_PATH="$DIST_DIR/${BASE_NAME}.apk"
  cp -f "$APK_LEGACY" "$NEW_PATH"
  echo "[INFO] APK 输出: $NEW_PATH"
  exit 0
else
  # 如果开启了 split-per-abi，则会生成多份 ABI 的 release 包，如：app-arm64-v8a-release.apk
  ABI_FILES=$(find "$ROOT_DIR/build/app/outputs" -type f -name "app-*-release.apk" 2>/dev/null || true)
  if [[ -n "$ABI_FILES" ]]; then
    echo "[INFO] 检测到 ABI 分包，开始分别重命名..."
    for f in $ABI_FILES; do
      abi=$(basename "$f" | sed -E 's/^app-([^-]+)-release\.apk$/\1/')
      NEW_PATH="$DIST_DIR/${BASE_NAME}_${abi}.apk"
      cp -f "$f" "$NEW_PATH"
      echo "[INFO] APK($abi) 输出: $NEW_PATH"
    done
    exit 0
  fi
fi

echo "[ERROR] 未找到 Release APK 输出文件，请检查构建是否成功以及输出路径。"
exit 1