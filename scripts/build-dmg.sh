#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/build/TidyUp.app"
STAGING="$ROOT/build/dmg"

"$ROOT/scripts/build-app.sh" > /dev/null

APP_VERSION="$(plutil -extract CFBundleShortVersionString raw "$APP/Contents/Info.plist")"
DMG="$ROOT/build/TidyUp-$APP_VERSION.dmg"

rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

hdiutil create \
    -volname "TidyUp" \
    -srcfolder "$STAGING" \
    -fs HFS+ \
    -format UDZO \
    -ov \
    "$DMG" > /dev/null

rm -rf "$STAGING"
echo "$DMG"
