---
title: "AI code review on every PR — how we wired it up"
date: 2026-07-20
summary: "We run AI code review on every PR, every push, automatically. No cloud API, no per-token billing. Here's the architecture and why the economics get interesting fast."
tags: [actions, ai, infrastructure]
---

A serious codebase doesn't get a hundred commits without a hundred review cycles. Each one is a chance to catch something — or to miss it because reviewing is expensive and humans get tired. We run AI code review on every PR, every push, automatically. Not as a replacement for human review. As the thing that clears the noise before a human looks.

## The problem with doing this at scale

The obvious solution is Greptile, or Cursor's review mode, or any of the cloud-backed tools. They work. They're also $X per review, routed through someone else's infrastructure, and billed per seat or per token. On a codebase with heavy PR volume — dozens of commits a day, review triggered on every `synchronize` event — that adds up fast. More importantly, it creates a dependency: the review quality, the latency, the availability, and the cost are all controlled by someone else's pricing page.

We wanted something we owned entirely.

## The architecture

Two repos. [`local-ai-cli`](https://github.com/runbot-hq/local-ai-cli) is a thin Swift CLI that talks to a local [Ollama](https://ollama.com) instance — prompt in, response out, zero domain knowledge. [`local-ai-code-review-action`](https://github.com/runbot-hq/local-ai-code-review-action) is the GitHub Action that does everything else: fetches the diff via the GitHub API, builds the prompt, calls the CLI, posts the result back to the PR as a comment.

The split matters. The CLI knows nothing about code review — it's a general-purpose inference passthrough. The same binary powers release notes and localization with different prompts. You don't rebuild the inference layer per use case.

```yaml
- uses: runbot-hq/local-ai-code-review-action@v1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    model: qwen3.5:9b
    temperature: '0.2'
```

The job runs on your self-hosted Mac runner. Ollama needs to be running as a service. When a PR opens or gets a new push, the action fetches the diff, sizes it up, and picks a token budget automatically — 4096 for small diffs under 150 reviewable lines, 8192 for larger ones. The result posts as a PR comment. That's it.

## What it reviews — and what it skips

The prompt is scoped to correctness: logic bugs, missing error handling, unsafe patterns. Style, formatting, naming — all explicitly excluded. That's SwiftLint's job, already earlier in the pipeline. Routing style feedback through an LLM is slow, inconsistent, and redundant. The action is there to catch the things lint can't: a force-unwrap that makes sense at first glance until you trace the call path, an async boundary that looks fine until it races.

## The model question — and where this gets interesting

On a standard MacBook M1 with 16GB RAM, `qwen3.5:9b` runs comfortably. Reviews are fast. For pure code work, `codegeex4:9b` is sharper — purpose-built for code, 89K context window, handles large diffs without truncating.

Scale up the hardware and the ceiling jumps. An M4 Mac mini with 64GB RAM runs `qwen3:32b` without breaking a sweat — a model that matches or beats GPT-4o on most coding benchmarks, running entirely on a machine that costs less than a month of a Greptile enterprise subscription. An M4 Max MacBook Pro with 128GB RAM runs `qwen3:72b` — frontier-class reasoning, locally, on a laptop.

And that's today's models on today's hardware. Kimi 3.0 already matches or beats most frontier models on coding tasks. Apple has been quietly building distributed inference APIs across Apple Silicon — the same technology that lets multiple Mac Studios pool their unified memory. When that becomes a first-class deployment target, running a frontier-level model across three or four Mac Studios locally stops being experimental. It becomes the obvious infrastructure choice for any team that already has the machines.

The economics invert completely. A team running heavy PR volume on cloud AI review pays continuously, at the API's price. A team with a Mac mini in the corner pays once, and the model gets better for free as they pull newer weights.

## The meta part

The CI that runs these reviews runs on the same Mac mini that RunBot manages. The reviews it posts are about the code that ships RunBot itself. It's the most direct test of whether the tool is worth running — and it earns its place on every PR.
