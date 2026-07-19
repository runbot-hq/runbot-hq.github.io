---
title: "AI release notes — first look"
date: 2026-06-14
summary: "Let RunBot draft your GitHub release notes from commit history using your local LLM. Editable before publish."
tags: [releases]
---

RunBot can now draft GitHub release notes for you. Point it at a tag range, and it summarises the commit history into a readable changelog — entirely on-device.

## The workflow

Open the Releases panel in RunBot, select your new tag and the previous release as a baseline, and hit **Draft notes**. The LLM reads the commit messages and PR titles in that range and produces a structured summary grouped by change type.

## Editing before publish

The draft appears in an editable text view before anything is posted. You can tweak wording, reorder sections, or cut anything irrelevant — then publish directly to the GitHub release from the same panel.
