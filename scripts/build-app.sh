#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIGURATION="${CONFIGURATION:-release}"
APP="$ROOT/build/TidyUp.app"
CONTENTS="$APP/Contents"

cd "$ROOT"
swift build -c "$CONFIGURATION" --product TidyUp
BINARY="$(swift build -c "$CONFIGURATION" --show-bin-path)/TidyUp"

rm -rf "$APP"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"
cp "$BINARY" "$CONTENTS/MacOS/TidyUp"

xcrun actool "$ROOT/Resources/TidyUp.icon" \
    --compile "$CONTENTS/Resources" \
    --platform macosx \
    --minimum-deployment-target 26.0 \
    --app-icon TidyUp \
    --output-partial-info-plist "$ROOT/build/icon-info.plist" \
    --output-format human-readable-text \
    --errors > /dev/null

cp "$ROOT/Resources/Info.plist" "$CONTENTS/Info.plist"
if [[ -n "${VERSION:-}" ]]; then
    plutil -replace CFBundleShortVersionString -string "$VERSION" "$CONTENTS/Info.plist"
fi
if [[ -n "${BUILD_NUMBER:-}" ]]; then
    plutil -replace CFBundleVersion -string "$BUILD_NUMBER" "$CONTENTS/Info.plist"
fi

codesign --force --sign - "$APP"
echo "$APP"
