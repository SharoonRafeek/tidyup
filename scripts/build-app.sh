#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIGURATION="${CONFIGURATION:-release}"
APP="$ROOT/build/Tidy.app"
CONTENTS="$APP/Contents"

cd "$ROOT"
swift build -c "$CONFIGURATION" --product Tidy
BINARY="$(swift build -c "$CONFIGURATION" --show-bin-path)/Tidy"

rm -rf "$APP"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"
cp "$BINARY" "$CONTENTS/MacOS/Tidy"

xcrun actool "$ROOT/Resources/Tidy.icon" \
    --compile "$CONTENTS/Resources" \
    --platform macosx \
    --minimum-deployment-target 26.0 \
    --app-icon Tidy \
    --output-partial-info-plist "$ROOT/build/icon-info.plist" \
    --output-format human-readable-text \
    --errors > /dev/null

cp "$ROOT/Resources/Info.plist" "$CONTENTS/Info.plist"

codesign --force --sign - "$APP"
echo "$APP"
