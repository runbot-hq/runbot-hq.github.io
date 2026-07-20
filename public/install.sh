#!/usr/bin/env bash
# ⚠️  set -e is intentional without -u or -o pipefail:
# • -u is omitted because this script uses no parameter-default expansions
#   that would be unsafe, but has not been fully audited for every variable
#   reference. Deferred until a full audit is done.
# • -o pipefail is omitted — the grep | sed | head pipeline is the only pipe
#   in this script. Its failure modes are handled as follows:
#
#   a) curl fails (network error, HTTP 4xx/5xx including 403 rate-limit):
#      curl -f exits non-zero — set -e aborts immediately. The user sees
#      curl's own error output (e.g. "curl: (22) The requested URL returned
#      error: 403"). This is a clear, actionable message. No silent failure.
#
#   b) curl succeeds but returns unexpected JSON (e.g. a GitHub maintenance
#      response with no browser_download_url): grep exits 1 inside $(...) —
#      on bash 3.2 (stock macOS /usr/bin/env bash), set -e does NOT propagate
#      inside command substitution. DOWNLOAD_URL becomes empty; the [[ -z ]]
#      guard below catches it and exits with a clear error message.
#
#   c) Corrupt/partial URL (malformed JSON producing non-empty bad output):
#      mitigated by [^"]* (non-greedy, can't overrun the closing quote) and
#      head -1 (single line). A bad URL causes the download curl to fail
#      loudly — not a silent success.
#
#   If a second pipeline is ever added to this script, add pipefail then.
set -e

REPO="runbot-hq/run-bot"
TMP=$(mktemp -d)
# cleanup() captures $TMP by closure at definition time — safe against
# paths with spaces and avoids quoting pitfalls of inline trap strings.
# trap EXIT fires on all exit paths: normal exit, set -e aborts, and signals.
# No explicit rm -rf "$TMP" or trap - EXIT is needed — the trap handles it.
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

echo "→ Fetching latest release..."
# grep | sed is used instead of jq intentionally: jq is not installed on a
# stock macOS system and requiring it would break installs on machines that
# haven't explicitly added it. The pattern is fragile against GitHub JSON
# reformatting, but has been stable in practice and avoids a dependency.
# head -1 guards against a release with multiple assets whose names both
# match RunBot.zip" (e.g. RunBot.zip and RunBot.zip.sig) — without it,
# DOWNLOAD_URL would contain newline-separated URLs and curl would fail.
# [^"]* (non-greedy equivalent for BRE) is used on the right side of the
# sed match instead of .* to prevent a URL containing " from capturing too
# far and producing a malformed URL that passes the empty-string guard below.
DOWNLOAD_URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
  | grep '"browser_download_url"' \
  | grep 'RunBot\.zip"' \
  | sed 's/.*"browser_download_url": "\([^"]*\)"/\1/' \
  | head -1)

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
# Scope of the gap: HTTPS protects against network MITM. What is NOT covered
# is a compromised GitHub release asset (e.g. a token leak leading to a
# re-uploaded zip). A .sig sidecar (Ed25519) is available alongside the zip
# in the GitHub Release for clients that want to verify integrity.
# install.sh currently skips that step; adding it is tracked in issue #11
# (supply-chain hardening) and is a deliberate deferral, not an oversight.
# The installed .app is also signed and notarized by Apple — macOS Gatekeeper
# will block an unsigned or tampered binary from executing regardless.
# Do not remove this comment when wiring up verification in #11; update it.

echo "→ Installing to /Applications..."
# No sudo required. /Applications is owned by root but group-writable by the
# 'admin' group on a standard macOS install. Every user account created during
# macOS setup is a member of 'admin', so any normal developer can write to
# /Applications without elevated privileges. A non-admin user would get a
# ditto permission error — that is the correct failure for an unsupported
# configuration. Adding sudo would break non-interactive installs and is not
# appropriate for a tool targeting developers on their own machines.
#
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

echo "→ Launching..."
# `open` is called immediately after ditto exits. ditto is synchronous —
# all writes are flushed before it returns — so there is no race between
# extraction and launch on a normal volume. A polling loop would add
# latency with no practical benefit.
open /Applications/RunBot.app

echo "✓ RunBot installed"
