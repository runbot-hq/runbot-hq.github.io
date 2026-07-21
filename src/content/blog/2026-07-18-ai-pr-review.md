---
title: "AI PR Review action is live"
date: 2026-07-18
summary: "RunBot can now trigger AI-powered pull request reviews directly from your menu bar. Powered by your local model, results land as GitHub review comments — no browser tab required."
tags: [actions, ai]
---

Starting today, RunBot ships a new action that triggers AI-powered pull request reviews from your macOS menu bar. The review runs entirely on your local model — no API key, no cloud roundtrip — and posts results as real GitHub review comments on the PR.

## How it works

When you open a PR in the RunBot popover and tap **AI Review**, the action fetches the diff via the GitHub API, passes it to your local model through the standard MLX inference endpoint, and formats the output as structured review comments grouped by file.

```yaml
# .github/workflows/ai-review.yml
- uses: runbot-hq/ai-review-action@v1
  with:
    model: mlx-community/Mistral-7B-Instruct
    severity_threshold: warning
```

## What gets reviewed

The action focuses on three signal categories: logic issues, missing error handling, and Swift concurrency violations. Style is deliberately excluded — that's SwiftLint's job.
