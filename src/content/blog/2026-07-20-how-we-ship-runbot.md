---
title: "How we ship RunBot using RunBot"
date: 2026-07-20
summary: "We distribute RunBot outside the App Store with no Developer ID, no notarization, and no Gatekeeper ceremonies — just ad-hoc signing, Ed25519 verification, and a fully public CI pipeline."
tags: [releases, infrastructure]
---

RunBot is a macOS menu bar app distributed outside the App Store. We ship it entirely via GitHub Actions, running on a self-hosted Mac mini managed by RunBot itself. This post covers the full pipeline — and why almost every conventional assumption about macOS distribution doesn't apply here.

## Distributing a macOS app without Apple

Distributing a macOS app the conventional way means:

- **$99/year** for an Apple Developer ID certificate
- **Apple's notary service** — submit your binary, wait, hope it passes
- **Sandbox and entitlements** — a maze of capabilities, hardened runtime flags, and Gatekeeper ceremonies that change with every macOS release
- **App Review** — human reviewers who can pull your app at any moment for reasons that are rarely clear and sometimes never explained

We skip all of it.

The approach is proven. Cursor, Warp, the Qwen CLI, Google's internal tooling — a growing number of bleeding-edge Mac tools distribute this way. The infrastructure to support it has been nascent and scattered. We built ours in the open.

Here's how it works: the install script downloads the release zip from GitHub and runs `codesign --sign -` on the end user's machine. Ad-hoc signing on the local machine satisfies macOS's ARM64 requirement without involving Apple at all. Because the binary was signed locally — not downloaded pre-signed — Gatekeeper's quarantine check never fires. The app opens immediately, no dialog, no "unverified developer" warning.

The security story doesn't come from Apple. It comes from transparency and cryptography. The source code is public. Every release is created in a public CI run with a full audit trail. The zip and a `.sig` sidecar are attached to the GitHub Release. The sidecar is a raw Ed25519 signature of the zip, produced in CI using a private key that lives only as a GitHub Actions secret. The install script verifies the signature against a public key before accepting the binary. A tampered zip produces a signature mismatch and is rejected. The code that runs on your machine is the code that was built from the public repo — and you can verify that cryptographically, not on trust.

## The build

`build.sh` does four things:

- Compiles an arm64-only release binary (`swift build -c release --arch arm64`)
- Assembles the `.app` bundle manually from the binary and `Info.plist`
- Ad-hoc signs it (`codesign --sign -`) — required for Apple Silicon, no Developer ID needed
- Zips with `ditto -c -k --keepParent` — a zip produced by standard `zip` or `unzip` silently strips macOS extended attributes and resource forks, corrupting the bundle on extraction. We learned this the hard way.

## Integrity without Apple: Ed25519

Without notarization, we need our own integrity story. Every release ships two assets: `RunBot.zip` and `RunBot.zip.sig`. The `.sig` is a raw 64-byte Ed25519 signature produced in CI with `openssl pkeyutl -sign -rawin`. The private key lives only as a GitHub Actions secret — never written to disk. The public key is embedded in the app binary at compile time. Before any in-app update installs, [AppUpdater](https://github.com/runbot-hq/AppUpdater) verifies the signature using `CryptoKit.Curve25519.Signing`. A mismatch hard-fails the install.

This is what makes the whole unsigned distribution story coherent. Every other update library that supports unsigned apps — there's essentially one, and it has no signature check — trusts the download entirely. Sparkle has excellent EdDSA support but requires a Developer ID. [AppUpdater](https://github.com/runbot-hq/AppUpdater) is the only library that combines unsigned/Gatekeeper-bypass distribution with Ed25519 authenticity verification. That combination — no Apple account required, no quarantine dialog, cryptographically verified — is what we built it for.

## The release pipeline

The whole release is triggered from a single GitHub Actions `workflow_dispatch` menu — a WYSIWYG dropdown in the GitHub UI. You select the branch (`release` or `beta`), optionally toggle dry run to exercise every step without publishing anything, and hit Run. That's the entire publish UX.

The changelog is generated automatically from the commit history by our [AI release notes action](https://github.com/runbot-hq/run-bot), entirely on-device. You can override it with a manual one if you want. From there, `publish.yml` takes over: it computes the next semver tag automatically from git history (no manual version bumping ever), patches `Info.plist` in the CI artifact only, builds, verifies the zip, generates the SHA-256 sidecar, tags, and creates the GitHub Release with both assets attached.

## In-app updates

After install, RunBot updates itself. [AppUpdater](https://github.com/runbot-hq/AppUpdater) polls GitHub Releases every 24 hours, does a full semver comparison including `beta.N` ordering, downloads the zip silently in the background, and verifies the Ed25519 signature. The update installs automatically on the next app restart — no interaction needed. If you'd rather not wait, an "Install & Relaunch" button is available in Settings → About the moment the download is ready. Either way, the install is an atomic `FileManager.replaceItem` bundle swap — a rename-based operation that preserves the old bundle as a backup until success.

## The meta part

The CI that builds and ships RunBot runs on the self-hosted Mac mini that RunBot manages. The AI that writes the release notes runs on the same machine — entirely on-device, no external API calls. The tool is load-bearing in its own release process, and the workflows it enables are exactly what it was built to run.
