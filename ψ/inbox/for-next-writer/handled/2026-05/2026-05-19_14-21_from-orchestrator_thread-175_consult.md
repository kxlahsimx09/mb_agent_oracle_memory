---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — re-land the stranded matcher epic onto main + re-point the PR stack"
context: see thread #175 msg 601 — stacked-PR recovery; re-land/retarget only, no merge
needs_response: true
priority: high
created: 2026-05-19T14:21:29+07:00
---

Stacked-PR recovery — re-land the matcher epic onto `main` and re-point the
PR stack. **§9 — re-land/retarget/rebase mechanics only; the user merges.**

## Diagnosis (verified via git/gh, repo `kxlahsimx09/mb-next-payment-gateway`)

- **PR #169** (matcher epic) — state MERGED, but base was the side branch
  `next-writer/thread167-p1-2-success-audit-acs`, **not `main`**. PR #168 had
  already merged that side branch into `main` *without* the matcher content.
  ⇒ `epic-statement-matching.md` is **stranded** on
  `next-writer/thread167-matcher-epic` — that branch is **1 commit ahead of
  `origin/main`**, and is NOT in `main`.
- **PR #172** (your doc-fixes G1/G5/G6/G7) and **PR #174** (next-architect's
  §FA1 amendment) are both OPEN with base `next-writer/thread167-matcher-epic`
  — so merging them as-is repeats the bug (into the stranded branch).

## Goal

Get the matcher epic + PR #172 + PR #174 onto a clean `main`-targeted state,
mergeable by the user in the order **re-PR → #172 → #174**.

## Steps — you own the HOW (rebase cascade, conflict resolution)

1. **Re-land the matcher epic.** PR #169 is already MERGED — cannot reuse it.
   Open a **fresh PR `next-writer/thread167-matcher-epic → main`**. Rebase
   `thread167-matcher-epic` onto current `origin/main` first if it does not
   merge clean — **a conflict on `epic-payout.md` PAYOUT-009 is likely** (PR
   #168 also edited PAYOUT-009; the matcher epic added an Engine-reference
   blockquote there). Resolve keeping both intents.
2. **Re-point PR #172 and PR #174** to base `main`. If you rebased
   `thread167-matcher-epic`, rebase the #172 and #174 head branches onto the
   new base so each PR's diff stays its own commits only.
3. Report: the re-PR number, and confirm #172 + #174 are retargeted to `main`
   with clean diffs.

Do **not** edit PR #174's `adr.md` content — next-architect flips the
`[RATIFICATION_PENDING:175]` marker separately once you have settled #174's
branch. Just rebase/retarget it mechanically.

Reply on thread #175 — `parent_session`/`parent_thread` route it back to me.
