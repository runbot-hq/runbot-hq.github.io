---
title: "Why local runners over cloud runners"
date: 2026-07-20
summary: "Cloud CI made sense before AI-assisted development. At 100–300 commits a day, local runners are 5× faster, nearly free, and the only practical way to run serious AI reviews on every commit."
tags: [runners, ci]
---

Let's break it down.

## 1. Cheaper

GitHub-hosted macOS runners bill at 10× the Linux rate. At 100–300 commits a day with 10–20 checks per commit, you burn through a generous minutes budget in two days. A Mac mini on your desk has no per-minute cost. Neither does the MacBook you're already working on — register it as a runner and your existing hardware becomes your CI infrastructure. Nothing to buy.

## 2. Faster

Two things make local CI dramatically faster.

First, the hardware. GitHub's hosted macOS runners are shared virtual machines on aging infrastructure. Your modern MacBook or Mac mini is bare metal Apple Silicon running nothing else. Unit tests that take 40 seconds on a GitHub runner finish in under 10 on local hardware. Build times follow the same pattern — roughly 5× faster in practice, with warm incremental builds pulling even further ahead because the derived data cache persists between runs.

Second, no queue. Cloud CI queues don't fit high-velocity development. A 45-second wait per run is fine at 10 commits a day. At 200 it becomes the bottleneck. Local runners have no queue — your hardware is yours.

Then there are headed UI tests. On GitHub's hosted runners, there is no screen. Getting UI tests to run at all requires virtual display workarounds, special entitlements, and flaky timing hacks that you spend more time maintaining than the tests themselves are worth. On local hardware with a real display, UI tests just work — no workarounds, no flakiness from missing window context, no debugging why a test passes locally and fails in CI for reasons unrelated to your code.

## 3. AI reviews at scale are expensive on cloud

This is the one that actually changes the economics.

Greptile charges around $1 per review. That sounds reasonable until you understand how a real PR actually grows. The "spec to production in one shot" premise is a fantasy — you never see the full spec upfront. The real spec emerges over time, through feedback, through hardening, through the battle scars that only appear when you actually build the thing. A PR starts at 10 commits and grows to 100 as it hardens. Reviews at every touchpoint. That's where the value is — and at $1 per review, 100–300 commits a day gets expensive fast.

Local AI changes the math entirely. A 70B model — DeepSeek, Qwen, CodeGeeX — running on a Mac mini M4 with 64 GB unified memory, or a MacBook Pro M4 Max, gives you Greptile-quality reviews on every single commit, for free, with no data leaving the machine, no rate limits, no API costs. Instant feedback at every touchpoint. That's not an incremental improvement. That's a different category of tool.

Cloud runners make this impractical. The VM specs are too limited for a serious model. Local runners make it table stakes.

## Faster. Cheaper. Better.

Local runners are 5× faster, nearly free — you pay for electricity, which is negligible — and they unlock a quality of AI-assisted CI that cloud simply can't match at any reasonable price.

The compounding effect is the real story. Faster feedback loops mean more iterations. More iterations mean better code. AI reviews on every commit — not just on final PRs — means problems get caught at the moment they're introduced, not after they've hardened into the codebase. The gap between "what I shipped" and "what I meant to ship" closes continuously, one commit at a time.

That's not a tooling choice. That's a different way of working.
