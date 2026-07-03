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
unzip -qo "$TMP/RunBot.zip" -d /Applications

rm -rf "$TMP"

echo "→ Launching..."
open /Applications/RunBot.app

echo "✓ RunBot installed"
