---
title: "Why we built RunBot"
date: 2026-07-21
summary: "CI became the choke point of agentic coding. GitHub's UI wasn't built for it. Local runners were unmanageable. So we built the smallest thing that could fix both."
tags: [product]
---

When agentic coding took off, CI became the choke point.

Agents don't write code the way humans do — they iterate fast, commit constantly, and trigger workflows on everything. What used to be a handful of CI runs a day became a thundering herd. Dozens of jobs running in parallel, failing, retrying, queuing. And monitoring any of it was nearly impossible.

GitHub's Actions UI was designed for how software teams worked in 2015. One engineer, one PR, one workflow. You could follow the timeline. In 2026, with agents pushing on every branch, that same UI is a wall of noise. Workflows, jobs, and steps are flattened into a single scrolling timeline with no hierarchy, no priority, no signal — just an undifferentiated stream of things that may or may not matter.

And it got expensive fast. Agentic coding uses CI an order of magnitude more than traditional development. Every vibe-coded change needs a reality check — CI is what keeps the agents honest. But cloud runners at that volume will empty your billing account in days. Local runners are the obvious solution. Except managing local runners in 2026 still meant terminal incantations, GitHub docs from 2019, and zero visibility into what was actually running or why.

## What we wanted

Not a dashboard. Not a fleet management SaaS. Something minimal — because we didn't need to watch CI all the time, just catch it when it mattered.

Two things, really:

1. **Ordered, hierarchical monitoring.** Workflows → jobs → steps. A collapsed tree you can scan in two seconds, not a timeline you have to read.
2. **One-click runner management.** Provision a runner, tear it down, see what's active — without touching a terminal or a GitHub settings page.

The smallest thing that could do both? A macOS menu bar app. It's where macOS puts things that need to be glanced at without interrupting you. Battery, Wi-Fi, time. Why not your runners?

So we built it. A dropdown list. A settings view. An app that sits in the menu bar, shows you what's running, surfaces failures the moment they happen, and lets you manage your runners without opening a browser. No background tabs. No context switches.

Run it on your MacBook and it's your personal CI dashboard. Your machine is a runner while it's open — jobs wait or find another runner if you close the lid. Run it on a Mac mini and it's always-on infrastructure for bigger pipelines, teams, and the things that can't wait for your laptop to wake up. Same app, same setup, different commitment.

## Then we realised the machine could do more

Once your runners are local, something shifts. The machine is yours. It's Apple Silicon. It has a Neural Engine. It can run models — fast, private, at zero per-run cost.

GitHub-hosted runners give you a clean Ubuntu environment. They don't give you Apple Intelligence, or a local Ollama model, or a GPU that belongs to you. For a macOS app team, that gap is real.

We started building actions to close it:

- **AI release notes** — generates release notes from your commit history using on-device Apple Intelligence. No API key. No cloud call. The model runs on the same machine that built the binary.
- **AI PR review** — reviews pull request diffs using a local Ollama model (Qwen, CodeGeeX, your choice) and posts structured review comments back to GitHub.
- **AI localization** — translates `.xcstrings`, `.strings`, and Markdown files using Apple's on-device translation framework.

None of them have a per-run cost. All of them compose with any action on the GitHub Actions Marketplace — hook them into Slack, analytics, whatever your pipeline already does.

## What this opens up

The economics of CI change when compute is local. Tasks you'd avoid on GitHub-hosted runners because of cost or latency — running a model on every PR, generating localizations on every merge, reviewing every diff — become cheap enough to just do.

Your MacBook is already sitting there. The machine you already have is already capable. RunBot turns it into infrastructure — a runner, a model host, and a CI dashboard, all in one menu bar icon.

RunBot isn't trying to replace GitHub. It's trying to make the machine you already have a first-class part of your pipeline.
