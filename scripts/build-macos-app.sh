#!/usr/bin/env bash

set -euo pipefail

root_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root_dir"

version="${VERSION:-}"
if [[ -z "$version" ]]; then
  version="$(sed -n 's/^var Version = "\([^"]*\)"/\1/p' version/version.go)"
fi
if [[ -z "$version" ]]; then
  echo "cannot read version" >&2
  exit 1
fi

version_number="${version#v}"
app_dir="dist/Qzone History.app"
contents_dir="$app_dir/Contents"
macos_dir="$contents_dir/MacOS"
archive="dist/qzone-history_${version_number}_darwin_arm64_app.zip"

rm -rf "$app_dir" "$archive"
mkdir -p "$macos_dir"

sed "s/__VERSION__/$version_number/g" packaging/macos/Info.plist > "$contents_dir/Info.plist"

CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build \
  -trimpath \
  -ldflags="-s -w -X qzone-history/version.Version=$version" \
  -o "$macos_dir/qzone-history" \
  ./cmd/main.go

chmod +x "$macos_dir/qzone-history"
codesign --force --deep --sign - --timestamp=none "$app_dir"
codesign --verify --deep --strict "$app_dir"
ditto -c -k --sequesterRsrc --keepParent "$app_dir" "$archive"

file "$macos_dir/qzone-history"
echo "Created $archive"
