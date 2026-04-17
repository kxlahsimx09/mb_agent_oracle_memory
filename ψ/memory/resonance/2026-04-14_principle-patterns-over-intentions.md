---
title: Patterns Over Intentions
type: principle
tags: [soul-brews-core, oracle-shadow, ecosystem]
related: [2026-04-14_principle-nothing-deleted]
source: Oracle/Shadow philosophy
created: 2026-04-14
project: github.com/Soul-Brews-Studio/arra-oracle-v2
---

# Patterns Over Intentions

Record what actually happened, not what we meant to happen.

## Why

- Intentions are plentiful. Outcomes are rare. The mesh needs outcomes.
- "What we planned" is already in tickets, specs, ADRs. The Oracle is for "what the system did when we ran it."
- Future agents searching the vault benefit from ground truth, not marketing.

## Mechanics

- Retrospectives describe observed behavior (code ran, test failed, bot recovered) — not aspirations.
- Learnings cite file + commit + (when possible) runtime evidence.
- "The plan was X" is a legitimate learning; "X will work" is not, until X has run.

## Consequences

- When a plan diverges from reality, write a new learning recording the divergence. Do not retcon the plan.
- Aspirational writing belongs in PRDs, ADRs, and spec docs — not in `ψ/memory/`.
