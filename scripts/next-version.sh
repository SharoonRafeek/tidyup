#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE="$(plutil -extract CFBundleShortVersionString raw "$ROOT/Resources/Info.plist")"
LATEST="$(git -C "$ROOT" tag --list 'v*' --sort=-v:refname | head -n 1)"
LATEST="${LATEST#v}"

if [[ -z "$LATEST" ]]; then
    echo "$BASE"
    exit 0
fi

HIGHEST="$(printf '%s\n%s\n' "$BASE" "$LATEST" | sort -V | tail -n 1)"
if [[ "$BASE" == "$HIGHEST" && "$BASE" != "$LATEST" ]]; then
    echo "$BASE"
    exit 0
fi

IFS=. read -r MAJOR MINOR PATCH <<< "$LATEST"
echo "$MAJOR.$MINOR.$((${PATCH:-0} + 1))"
