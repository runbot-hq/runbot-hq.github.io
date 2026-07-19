---
title: "Local runner provisioning in one click"
date: 2026-07-10
summary: "Spin up org or repo self-hosted runners without leaving the app. Supports both GitHub-hosted and custom machine targets."
tags: [runners]
---

RunBot now lets you provision self-hosted runners for any organization or repository directly from the menu bar — no terminal, no YAML edits required.

## What's new

The runner provisioning panel walks you through selecting a scope (org or repo), choosing a machine target (GitHub-hosted or custom), and generates the registration token automatically via the GitHub API.

## Custom machine targets

If you manage your own build machines, you can now register them as runners from RunBot. Paste your machine's address, choose the OS, and RunBot handles the rest — including injecting the runner token securely.
