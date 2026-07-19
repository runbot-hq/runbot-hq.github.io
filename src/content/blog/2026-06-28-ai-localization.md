---
title: "AI localization action ships"
date: 2026-06-28
summary: "Automatically generate localised string files for your Swift app across 30+ languages on every push to main."
tags: [actions]
---

The AI localization action is now available. On every push to `main`, RunBot scans your `.xcstrings` file and generates localized variants for 30+ languages using your local model.

## How it works

The action reads your base `Localizable.xcstrings`, passes each string to the local LLM with context about your app, and writes the translated output back into the strings catalog format. No API costs, no third-party services.

## Supported languages

All 38 languages supported by App Store Connect are available out of the box. You can restrict to a subset using the `languages` input in your workflow file.
