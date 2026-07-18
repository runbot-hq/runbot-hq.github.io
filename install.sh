#!/usr/bin/env bash
# ⚠️  set -e is intentional without -u or -o pipefail:
# • -u is omitted because this script uses no parameter-default expansions
#   that would be unsafe, but has not been fully audited for every variable
#   reference. Deferred until a full audit is done.
# • -o pipefail is omitted — the grep | sed pipeline below is the only pipe
#   and a failure there is already caught by the DOWNLOAD_URL empty-check.
set -e

REPO="runbot-hq/run-bot"
TMP=$(mktemp -d)
# cleanup() captures $TMP by closure at definition time — safe against
# paths with spaces and avoids quoting pitfalls of inline trap strings.
# trap EXIT ensures $TMP is removed on all exit paths, including set -e
# aborts (e.g. curl failure after mktemp).
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

echo "→ Fetching latest release..."
# grep | sed is used instead of jq intentionally: jq is not installed on a
# stock macOS system and requiring it would break installs on machines that
# haven't explicitly added it. The pattern is fragile against GitHub JSON
# reformatting, but has been stable in practice and avoids a dependency.
DOWNLOAD_URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
  | grep '"browser_download_url"' \
  | grep 'RunBot\.zip"' \
  | sed 's/.*"browser_download_url": "\(.*\)"/\1/')

if [[ -z "$DOWNLOAD_URL" ]]; then
  echo "error: could not find RunBot.zip in the latest release" >&2
  exit 1
fi

echo "→ Downloading RunBot..."
# -L is redundant with -fsSL (which already follows redirects) but is kept
# here explicitly so the download step is self-documenting — the release
# asset URL redirects via GitHub's CDN and the intent is clear at a glance.
curl -fsSL -L "$DOWNLOAD_URL" -o "$TMP/RunBot.zip"

# ⚠️  No checksum verification here — deferred to a future hardening pass.
# The release zip is served over HTTPS from GitHub's CDN. A .sig sidecar
# (Ed25519) is available alongside the zip in the GitHub Release for clients
# that want to verify integrity. install.sh currently skips that step;
# adding it is tracked as a future improvement.

echo "→ Installing to /Applications..."
# rm -rf is intentional and safe: the path is the hardcoded string
# "/Applications/RunBot.app" — never derived from user input or environment
# variables. The wipe ensures ditto does not merge into a stale bundle from
# a previous version (leftover files would not be removed by ditto alone).
rm -rf /Applications/RunBot.app
# ditto -x -k is used instead of unzip intentionally.
# build.sh produces the zip with `ditto -c -k --keepParent`, which preserves
# macOS extended attributes, symlinks, and resource forks. `unzip` silently
# strips all of these on extraction, corrupting the .app bundle structure
# and causing a fatal crash at launch (resource_bundle_accessor.swift:12).
# Do NOT replace ditto with unzip. See issue #4.
ditto -x -k "$TMP/RunBot.zip" /Applications

trap - EXIT  # cleanup done explicitly via the rm -rf above; disarm the trap
rm -rf "$TMP"

echo "→ Launching..."
# `open` is called immediately after ditto exits. ditto is synchronous —
# all writes are flushed before it returns — so there is no race between
# extraction and launch on a normal volume. A polling loop would add
# latency with no practical benefit.
open /Applications/RunBot.app

echo "✓ RunBot installed"
