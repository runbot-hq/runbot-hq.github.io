# runbot-hq.github.io

Marketing site and blog for [RunBot](https://github.com/runbot-hq/run-bot) — a macOS menu bar app for managing GitHub Actions runners.

Built with [Astro](https://astro.build). Deploys automatically to GitHub Pages on every push to `main`.

## Development

```bash
npm install
npm run dev
```

## Writing a post

Add a `.md` file to `src/content/blog/`:

```
src/content/blog/YYYY-MM-DD-your-post-slug.md
```

With frontmatter:

```yaml
---
title: "Your post title"
date: 2026-07-19
summary: "One sentence shown in the blog index."
tags: [releases]
---
```

`tags` is free-form — it is stored in the content schema but not currently used for filtering or display. Add whatever values make sense; they’re available for future use.

Push to `main` and the post is live within ~60 seconds.

## Utilities

Two small helpers live in `src/lib/`:

- **`postPath.ts`** — single source of truth for building post URLs from a content ID. Used by the blog index, the `[...slug]` route, and the RSS feed. If you need a post URL anywhere, use this.
- **`fmtDate.ts`** — formats a `Date` as a human-readable string, pinned to `timeZone: 'UTC'` so frontmatter dates (which are UTC midnight) don’t shift back a day on machines in negative-offset timezones.

## Dependency pinning

`astro` and `@astrojs/rss` are both pinned to exact versions (no caret) in `package.json`.
Astro has a history of breaking Content Collections behaviour in minor releases
(e.g. `post.slug` → `post.id` in 4.x). Upgrade deliberately by changing the version number
and verifying the build locally first.

No `package-lock.json` is committed. This is intentional — see the comments in
`.github/workflows/deploy.yml` for the full rationale. Do not add one without reading those first.

## Astro version

This project uses Astro 4.x, not the latest Astro 5.x. The upgrade is a deliberate future task,
not an oversight. Astro 5 changed the Content Collections API in ways that require a migration.
When ready, follow the [official upgrade guide](https://docs.astro.build/en/guides/upgrade-to/v5/).

## Deploy

GitHub Actions builds and deploys on every push to `main` via `.github/workflows/deploy.yml`.
No manual steps required.

In repo **Settings → Pages**, source must be set to **GitHub Actions**.

## install.sh

`public/install.sh` is the one-line install script promoted on the homepage:

```bash
curl -fsSL https://runbot-hq.github.io/install.sh | bash
```

It fetches the latest `RunBot.zip` from the [run-bot](https://github.com/runbot-hq/run-bot)
release assets, extracts it with `ditto`, and opens the app. It uses `ditto` (not `unzip`) to
preserve macOS extended attributes — see the inline comments for details.

Checksum verification is deferred to issue #11 (supply-chain hardening). The installed `.app`
is Apple-signed and notarized, so Gatekeeper provides a backstop in the interim.
