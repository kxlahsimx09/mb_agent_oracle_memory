---
title: Code is Truth, Documents are Claims
type: principle
tags: [soul-brews-core, documentation, ecosystem, technical-writer, ratified]
related:
  - 2026-04-14_principle-patterns-over-intentions
  - 2026-04-14_principle-nothing-deleted
  - 2026-04-14_principle-external-brain-not-commander
  - 2026-04-14_vault-principle-provenance
source: >
  Proposed 2026-04-14 by technical_writer agent (Claude session on dev01) while
  designing the two-instance technical_writer role spanning mobiz-payment-gateway
  (current) and a target repo yet to be named. Builds on Oracle/Shadow philosophy
  from ~/.arra-oracle/.claude/knowledge/oracle-philosophy.md (which defines P-001
  through P-003) by adding an explicit doc-vs-code reconciliation rule.
origin: proposed-by-agent
ratified_by: Mobiz (human, payment-gateway owner)
ratified_at: 2026-04-14 (GMT+7)
ratified_in_repo: github.com/kokarat/mobiz-payment-gateway
ratification_note: >
  Human reviewed the proposed principle and accepted it as a core ecosystem rule.
  Elevation from "proposed-by-agent" to "ratified" at this date. Upstream proposal
  to ~/.arra-oracle/.claude/knowledge/oracle-philosophy.md is optional and out of
  scope for technical_writer; filed as a future action, not a blocker.
created: 2026-04-14
project: github.com/Soul-Brews-Studio/arra-oracle-v2
---

# Code is Truth, Documents are Claims

When code and documentation disagree about what a system does, the **code wins** for "what the system does." The **document wins** for "what we intended." Treat them as two different questions, not the same question with two answers.

## Why

- Code executes. Documents narrate.
- Users and operators are impacted by code, not by docs. A doc that misleads is worse than a doc that's silent.
- Agents downstream (future sessions, peer nodes) will trust the document unless something tells them not to. That trust must be earned per-claim, not granted wholesale.

## Mechanics

- Every non-trivial doc claim cites a file + commit hash — the version it was verified against.
- When code changes in a way that invalidates a claim, the doc is marked `[DRIFT]` until reconciled. It is **not** silently patched.
- Drift is logged as a learning (`tags: [#drift]`) with a trace linking commit → doc section → resolution PR.
- Diagrams are generated from / justified by code. Unsourced diagrams are guesses, marked as such.

## Consequences

- Doc-code drift becomes a countable, trackable thing. The vault holds the history of drift events.
- Writers cannot "polish" a doc to look coherent if the code contradicts it — they must either fix the doc against code, or file an issue that the code violates the doc's stated invariant.
- Readers learn to trust a `[DRIFT]` marker more than they would trust silent prose — because silence is what liars sound like.

## Scope

This principle is core to the `technical_writer` role but applies to any agent producing narrative about a running system (retrospectives, ADRs, incident reports, runbooks).
