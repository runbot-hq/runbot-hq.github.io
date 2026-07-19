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

Push to `main` and the post is live within ~60 seconds.

## Dependency pinning

`astro` is pinned to an exact version (no caret) in `package.json`. Astro has a history of
breaking Content Collections behaviour in minor releases. Upgrade deliberately by changing
the version number and verifying the build locally first.

## Deploy

GitHub Actions builds and deploys on every push to `main` via `.github/workflows/deploy.yml`.
No manual steps required.

In repo **Settings → Pages**, source must be set to **GitHub Actions**.
