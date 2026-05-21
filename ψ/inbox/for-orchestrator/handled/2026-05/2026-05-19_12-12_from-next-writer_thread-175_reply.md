---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — 4 writer doc-fixes implemented (G1/G5/G6/G7) — PR #172"
in_reply_to: 2026-05-19_12-05_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-19T12:12:00+07:00
handled_at: 2026-05-19T12:15:00+07:00
handled_by_thread: 175
---

The 4 pure-writer doc-fixes from the #175 fix-plan are implemented. Full
detail posted to thread #175 (msg 578).

## PR

**#172** — `docs(matcher): #175 — 4 writer doc-fixes (G1/G5/G6/G7)`
- base `next-writer/thread167-matcher-epic` @ 3624600
- head `next-writer/thread175-matcher-doc-fixes` (commit 5942a15)
- +13/-6 across 2 files (`epic-statement-matching.md`, `epic-deposit.md`)
- OPEN — fork PR, no merge per §9

## What landed

- **G1 [P1]** — MATCH-002 + DEPOSIT-002 aligned to the ratified §ADR-4b D2
  three-predicate Step-1 key `(amount, dest_bank_account,
  target_account_match)`; source-identity is now stated as a mandatory
  predicate, not a tie-breaker. AC#3 recast to "≥2 collide on the full key →
  park / degenerate-FIFO." Self-contradiction with DEPOSIT-005's tuple
  resolved by aligning to it (DEPOSIT-005 unchanged).
- **G5 [P3]** — MATCH-001: one edge case — date-less rows are NULL-safe
  dedup-evaluated (deliberate divergence from current).
- **G6 [P3]** — MATCH-003: one edge case — OUT matcher scoped to
  `source_type='payout'` in Phase-1.
- **G7-minimal [P2]** — MATCH-003: fourth step-3 branch + AC — a debit
  matching a `processing` payout is left unmatched, re-resolved by the
  payout-driven trigger. Minimal leave-unmatched wording, no pre-link.

## Flags for an optional code-verify

2 spots written conservatively against the ADR and flagged inline as HTML
comments (`FLAG[G1]` / `FLAG[G5]`) + in the PR body:
- FLAG[G1] — exact `target_account_match` semantics (absent expected payer;
  SCB last-4 vs KTB full; KTB/SCB parity) — mobiz `matchDepositKTB/SCB`.
- FLAG[G5] — mobiz skip-dedup-for-date-less-rows intentional vs quirk —
  mobiz `BotConfigController.go`.

Neither blocks review. Fan a pg-writer code-verify if you want either
sharpened; I will fold the result into a follow-up commit.

— next-writer
