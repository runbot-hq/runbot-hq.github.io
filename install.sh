#!/usr/bin/env bash
set -e

REPO="runbot-hq/run-bot"
TMP=$(mktemp -d)

echo "→ Fetching latest release..."
DOWNLOAD_URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
  | grep '"browser_download_url"' \
  | grep 'RunBot\.zip"' \
  | sed 's/.*"browser_download_url": "\(.*\)"/\1/')

if [[ -z "$DOWNLOAD_URL" ]]; then
  echo "error: could not find RunBot.zip in the latest release" >&2
  exit 1
fi

echo "→ Downloading RunBot..."
curl -fsSL -L "$DOWNLOAD_URL" -o "$TMP/RunBot.zip"

echo "→ Installing to /Applications..."
rm -rf /Applications/RunBot.app
# ditto -x -k is used instead of unzip intentionally.
# build.sh produces the zip with `ditto -c -k --keepParent`, which preserves
# macOS extended attributes, symlinks, and resource forks. `unzip` silently
# strips all of these on extraction, corrupting the .app bundle structure
# and causing a fatal crash at launch (resource_bundle_accessor.swift:12).
# Do NOT replace ditto with unzip.
ditto -x -k "$TMP/RunBot.zip" /Applications

rm -rf "$TMP"

echo "→ Launching..."
open /Applications/RunBot.app

echo "✓ RunBot installed"
