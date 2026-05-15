---
title: W2 cleanup-requirements workflow codified for next-product-writer (2026-05-14).
tags: [next-product-writer, repo:mb-next-payment-gateway, workflow-2, cleanup, plain-english, hygiene, codification, brew-ops-handoff, 2026-05-14]
created: 2026-05-14
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W2 cleanup-requirements workflow codified for next-product-writer (2026-05-14).

W2 cleanup-requirements workflow codified for next-product-writer (2026-05-14).

brew-ops drafted `workflow-2-cleanup-requirements.md` (243 lines, under 250 budget) at `.agent/skills/next-product-writer/references/`. SKILL.md workflows table updated: W2 = cleanup, W3+ = TBD refresh-on-amendment / handoff. W2 was previously TBD as "refresh-on-amendment" — that shape moves to W3 when the first ADR amendment lands post-Phase-1.

## Why this shape

The user's framing was load-bearing: **"requirement document ต้องสะอาด อ่านง่าย และไม่มี programming term / ตัวแปล / สิ่งไม่จำเป็น แต่ความหมายเดิมยังคงอยู่"** — prose-level plain-English cleanup that demotes engineering jargon from story bodies to Sources blocks, preserving meaning. W1's "Plain-English discipline" (Step 3) and "Anti-pattern: don't paraphrase ADR text into the story body" was the codified rule; ad-hoc passes recorded in `epic-deposit-revision-log.md` were the practice. W2 codifies the practice.

## Structure (9 steps)

- Step 0 — Source-of-truth pre-flight (arra_stats, recent retros, principle check)
- Step 1 — Inventory pass (read-only — line count, anchored markers, kramdown traps, bare-brace MDX traps, missing Sources heuristic)
- Step 2 — Category triage (10-row table — jargon hits FIRST, then size/MDX/orphan/INDEX/glossary)
- Step 3a — Revision-log archival (precedent: `docs/adr/revision-log-archive-2026-05.md`)
- Step 3b — Cluster-split (proposal only, never auto-execute — file thread to human first)
- Step 3c — **Plain-English prose cleanup (the core W2 step)** — four moves: (1) move to Sources block, (2) backtick as proper noun, (3) paraphrase preserving meaning, (4) drop incidental. Fabrication co-detection during the same walk.
- Step 4 — Orphan AWAITING_THREAD sweep (mirrors brew-ops W5 §13c at smaller scale)
- Step 5 — INDEX + glossary sync (story-id diff, glossary first-occurrence link check)
- Step 6 — Cross-repo coordination check
- Step 7 — Apply fixes (one PR per category — plain-english / archive / mdx / orphan / index / split-proposal)
- Step 8 — Revision-log + arra_learn
- Step 9 — Retro

## Key disciplines baked in

- **P-001 meaning preservation:** every Step 3c rewrite has a before/after table in the PR description. The G/W/T criteria read identically before/after.
- **W1 boundary respect:** if a story is missing Sources/trust label, W2 does NOT invent — files thread to writer. Cleanup never promotes trust.
- **Pending vs closed thread discriminator:** W4 uses `arra_thread_read` to verify status before stripping; pending markers stay.
- **No auto cluster-split:** structural reshapes go through `arra_thread` to human first.
- **Product-facing vs engineering jargon test:** `Idempotency-Key` header + `MDR` (terms on invoices) stay inline-backtick; `ts_deposits` + `pg_cron` + `compound SQL join` demote to Sources.

## Reference inventory state used to ground the worked-example

`docs/requirements/` at 2026-05-14:
- epic-deposit.md = 559 lines (over budget by 309)
- 0 orphan AWAITING_THREAD/RATIFICATION_PENDING (all 4 ratified in PRs #83 + #85)
- 0 kramdown {#anchor} traps
- 0 bare {a, b} traps outside backticks
- DEPOSIT-001..008 + DEPOSIT-012 stories (DEPOSIT-006 was removed via §ADR-4b amendment defer-to-Phase-2)

So the first real W2 pass on epic-deposit would fire Step 3c (plain-English) + Step 3b (cluster-split proposal: auto vs admin path). Worked-example in the doc uses DEPOSIT-001 user-journey step 3 (the `expires_at = now() + ...` sentence) as the before/after sample.

## File location + commit

`mb_agent_oracle_memory/github.com/kxlahsimx09/mb-next-payment-gateway/.agent/skills/next-product-writer/references/workflow-2-cleanup-requirements.md` — single-author convention per AGENTS.md §3a. Edit-in-place; commit-to-main OK; no PR needed for `.agent/` edits.

Tags: next-product-writer, repo:mb-next-payment-gateway, next, workflow, cleanup, hygiene, plain-english, W2, codification

---
*Added via Oracle Learn*
