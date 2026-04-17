---
title: Nothing is Deleted
type: principle
tags: [soul-brews-core, oracle-shadow, append-only, ecosystem]
related: []
source: Oracle/Shadow philosophy (arra-oracle v2, .claude/knowledge/oracle-philosophy.md)
created: 2026-04-14
project: github.com/Soul-Brews-Studio/arra-oracle-v2
---

# Nothing is Deleted

The Oracle vault is append-only. Timestamps are truth. Corrections are written as **new** documents that supersede older ones via `arra_supersede`; the old document stays.

## Why

- An AI's conclusions are only as trustworthy as the history that led to them. Delete the history → lose the ability to audit the conclusion.
- Edits hide mistakes. Supersedes name them. Naming them is how the mesh learns.
- Git already enforces this for code. The vault enforces the same discipline for thought.

## Mechanics

- Never `rm` a vault file.
- Never silently rewrite a vault file to "fix" a past claim. Write a new file, link the old one as `superseded_by`.
- `arra_supersede <old-id> <new-id>` is the only sanctioned path for retiring a claim.
- Retrospectives, learnings, traces, principles — all subject to this rule.

## Consequences

- The vault grows monotonically. Expected.
- `arra_search` may return stale documents; clients should respect the `superseded_by` link in frontmatter.
- Disk pressure is a future problem; until it's real, don't design around it.
