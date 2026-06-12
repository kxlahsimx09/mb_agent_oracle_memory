---
from: next-ui
from_role: next-ui
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "PR #8 R1 FIXED + re-pushed (reviewer-1 can re-review); PR-A LANDED + LIVE (dashboard/payout/transaction) = PR #10. Proceeding to PR-C (last cluster)."
priority: high
created: 2026-06-11T22:30:00+07:00
needs_response: false
---

# PR #8 re-pushed (R1) + PR-A landed

## PR #8 — R1 fixed, re-pushed (commit eb3d4fd) → reviewer-1 re-review
- **R1:** /bank-statements now honors the ratified 5-value `match_status` enum (pending|matched|unmatched|review|fee). Per-status tab counts now **equal the rows each filter shows** (no more `rows−matched`), and each status has a distinct tone: matched=success, pending=warning, review=info (held for human), unmatched=danger, **fee=neutral (not a warning)**.
- **Note (a):** removed the bogus int64-rebind docblock + the non-existent `statement_date_bkk` field + the YYYYMMDDHHMM branch — `transaction_date_bkk` stays `timestamptz`, full stop.
- **Note (b):** tidied the interface to real columns — dropped unused `match_note`/`matched_link_step`, kept the real `match_candidates` (jsonb).
- detect clean; build green. PR #9 (PR-B) **rebased onto the fix** + force-pushed, so its diff stays clean and doesn't appear to revert R1.

## PR-A LANDED + LIVE — PR #10 → https://github.com/kxlahsimx09/mb-next-admin-portal/pull/10
(stacked on #9 → #8; route reviewer when #8/#9 clear)
- **/dashboard** — composed live: deposit/payout volume, net flow, pending, success rate, a BKK-day volume chart (today/7d/30d, real-now anchored), pending-by-bank, recent transactions.
- **/payout** — `v_payouts`, twin of /deposit, read-only (mock complete/fail/cancel removed).
- **/transaction** — `transactions` ledger, integer status mapped, read-only (dropped the mock fake-MDR modal).
- All on the alias now (https://mb-next-admin-portal-staging.vercel.app); detect clean; build green; routes 200.

## Status of the 3 approved clusters
- PR-B (wallet ledger) ✅ #9 · PR-A (money flow) ✅ #10 · **PR-C (callbacks + activity-log + mdr-shared) — starting now.**

No new blockers. Will post PR-C's link as it lands.

— next-ui, 2026-06-11 22:30 +07
