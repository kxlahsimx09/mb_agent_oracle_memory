---
title: W9 pass 2026-06-02 (amend PR #508) — bb02f02 #510 confirm/override wallet-log reference_id = Class B line-shift folds into held over-threshold backlog, no new flow drift
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - flow-track
  - w9
  - amend
  - flow:payout-confirm-completed
  - flow:payout-request
  - no-new-drift
  - pointer-staleness-backlog
created: 2026-06-02
source: docs/flows/payout-confirm-completed.md, docs/flows/payout-request.md, docs/flows/.baseline (held 9aebabb)
related:
  - 2026-05-23_w9-over-threshold-escalation-2026-05-24-range-9a
  - 2026-06-01_flow-track-w9-amend-bf57c0e-a9a3acb
project: github.com/kokarat/mobiz-payment-gateway
---

W9 amend pass over `a9a3acb..bb02f02` (1 new commit beyond PR #508's prior frontier). Extends PR #508 (cumulative `9aebabb..bb02f02`).

## Triage of bb02f02 (#510)

`bb02f02` added `ReferenceID = payout.ID` + `ReferenceType = "payout"` to four `wallets_change_logs` writes in `controllers/PayoutController.go` (OverridePayoutStatus ×2: `mdr_distribution_reversed`, `payout_override_refund`; ConfirmPayoutCompleted ×2: `payout_confirm_completed` deduct, per-partner `mdr_distribution`), plus two compound indexes in `db/indexes.go`.

Flow-territory effect:

- **`payout-confirm-completed`** — the two ConfirmPayoutCompleted `ReferenceID` insertions (~+2 lines each at the deduct + mdr writes) shift the Step 5/6/7 `// impl:` pointers (`PayoutController.go:1950-1985 / 1992-2055 / 2057-2083 @d2a2738`). This is **Class B (line relocation)**. The flow's postconditions (L68–70) and impl notes describe the change-log rows by `operation` + `note`-prefix + amount — none claim `reference_id` absent — so adding the field is **not** Class C semantic drift.
- **`payout-request`** — broad pointer `PayoutController.go:1820-2123@d2a2738` (ConfirmPayoutCompleted, waiting_to_review variant) covers the same region; same Class B shift.
- **OverridePayoutStatus** `ReferenceID` additions + **`db/indexes.go`** compound indexes — **flow-uncovered** (no `// impl:` pointer targets them) → no marker, no `#uncovered-surface` (not a greenfield actor-crossing).

## Decision: fold into held backlog, no pointer edit

`docs/flows/.baseline` is held at `9aebabb` under the documented **OVER-THRESHOLD escalation** (see `2026-05-23_w9-over-threshold-escalation`): the confirm-completed/payout-request `1820-2123@d2a2738` pointers are already part of the deferred 8-flow line-shift backlog (PR #508 folded #505's identical shifts there). `bb02f02` adds +2 more line-shifts to that **same** deferred region. No new drift class (no C/D/E/F), no pointer refresh this pass (the whole backlog refreshes together when the held baseline drains — a partial drain would be inconsistent). Baseline stays `9aebabb`.

Step 0.5: no fresh bank-bot `#cross-repo-sync` learnings since the 2026-05-22 baseline. Step 2c: no cross-repo signal (bb02f02 has no callback/signature/OTP contract surface). W9 trace `5d5d928b`, chained `a0a128bd` (today's W2) → `5d5d928b`.
