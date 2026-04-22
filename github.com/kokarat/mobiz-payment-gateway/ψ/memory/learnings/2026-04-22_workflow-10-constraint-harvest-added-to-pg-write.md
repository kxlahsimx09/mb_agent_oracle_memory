---
title: Workflow-10 "Constraint Harvest" added to pg-writer (technical-writer) skill in 
tags: [brew-ops, workflow-edit, workflow-10, constraint, technical-writer, repo:mobiz-payment-gateway, repo:cross, current, target-system-feed, 2026-04-22]
created: 2026-04-22
source: brew-ops session 2026-04-22 GMT+7, user asked to add constraint-harvesting workflow to pg-writer
project: github.com/kokarat/mobiz-payment-gateway
---

# Workflow-10 "Constraint Harvest" added to pg-writer (technical-writer) skill in 

Workflow-10 "Constraint Harvest" added to pg-writer (technical-writer) skill in mobiz-payment-gateway on 2026-04-22 (GMT+7) — brew-ops session.

**What it is:** A new re-runnable workflow for the `technical-writer` instance in `kokarat/mobiz-payment-gateway`. Catalogues externally-imposed, hard-to-change facts (bank portals, regulators, 3rd-parties, browser/OS) into a single append-only register at `docs/constraints.md`. Covers both mobiz-payment-gateway AND bank-bot in one doc (register lives in mobiz repo; bot-writer sibling does NOT mirror — feeds in via normal arra_learn stream).

**Why:** Target-system (new) design decisions kept re-discovering the same hard limits one at a time, mid-design, at high cost. Front-loads that pain by pre-cataloguing what reality forces on us. Explicit antidote to the "greenfield rewrite fixes this" fallacy when the limit is externally imposed and would survive any rewrite.

**How to apply:**
- Run before any target-system ADR (W3 or migration-notes architecture edit).
- Run quarterly. A pass with zero new entries is still valuable (re-verification stamp).
- Also run when W2/W8/W9 surfaces a drift note that smells like a constraint.
- Re-run discipline: workflow is dedup-aware via `docs/constraints.md` register (keyword fingerprints per entry) + `docs/.constraints-cursor` (scan bounds for git / PR / memory). Each pass rotates through a 15-theme wheel to prevent monoculture.

**Seed example that motivated this:** bank portals silently drop idle sessions — bot must keep session warm or re-auth (OTP-gated). Not our choice; survives any rewrite.

**Scope decision (this session):**
- Workflow file: `kokarat/mobiz-payment-gateway/.agent/skills/technical-writer/references/workflow-10-constraint-harvest.md` (new, ~380 lines).
- SKILL.md registered at `.agent/skills/technical-writer/SKILL.md` — workflow table row added, `docs/constraints.md` added to the "What I own" artifact table.
- Single owner = pg-writer. Bot-writer (bank-bot side) does not get a parallel W10 for now; future decision if/when the register splits.
- Output doc lives in mobiz repo at `docs/constraints.md`, NOT a cross-repo doc in `mb_agent_oracle_memory` (tradeoff accepted: sibling drift risk vs single-source simplicity).
- First real run pending — file is draft until validated.

**Files touched (via symlinked `.agent/` → `mb_agent_oracle_memory`):**
- `github.com/kokarat/mobiz-payment-gateway/.agent/skills/technical-writer/SKILL.md` (modified, W10 row + constraints register row)
- `github.com/kokarat/mobiz-payment-gateway/.agent/skills/technical-writer/references/workflow-10-constraint-harvest.md` (new)

**Related:**
- `learning_2026-04-17_name-gotcha-anti-detection-ranges-and-viewp` (canonical example of a hard constraint: anti-detection constants load-bearing).
- `learning_2026-04-16_architecture-correction-2026-04-16-gmt7-corr` (earlier brew-ops session that clarified mobiz ↔ bank-bot ↔ mock-bank topology).
- SKILL.md §Two-instance deployment (target-system phase = `#target`, current = `#current`; constraints are implicitly `#current` but have `Target-system implication:` per-entry pointers).

Tags: brew-ops, workflow-edit, workflow-10, constraint, technical-writer, repo:mobiz-payment-gateway, repo:cross, current, 2026-04-22

---
*Added via Oracle Learn*
