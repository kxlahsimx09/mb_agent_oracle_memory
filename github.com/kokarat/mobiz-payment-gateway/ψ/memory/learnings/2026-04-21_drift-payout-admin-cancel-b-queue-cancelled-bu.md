---
title: drift — payout-admin-cancel (b) queue-cancelled-but-payout-not-pending race wind
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow:payout-admin-cancel, race-window, compensation, queue, payout]
created: 2026-04-21
source: docs/flows/payout-admin-cancel.md + controllers/PayoutController.go:913-1079@aff85e1 + thread #34 closed 2026-04-21
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — payout-admin-cancel (b) queue-cancelled-but-payout-not-pending race wind

drift — payout-admin-cancel (b) queue-cancelled-but-payout-not-pending race window. In `CancelPayout` at `controllers/PayoutController.go:913-1079@aff85e1`, step 5a (queue CAS `pending → cancelled` at line 972-992) runs before step 6a (payout CAS `pending → cancelled` at line 996-1014). If step 5a succeeds but step 6a's CAS zero-matches — because a concurrent admin action (`/override`, `/confirm-completed`, another `/cancel` racing, or the timeout scheduler's `PayoutExpiryScheduler`) flipped the payout out of `pending` in the ~sub-millisecond window between the step-3 guard read (line 946) and the step-6 CAS write — the handler returns 400 "Payout is no longer pending" but leaves the queue row in `cancelled` state while the payout sits in some terminal state other than `pending` (`completed`, `failed`, `waiting_to_review`, or `cancelled` via a different path).

Originally classified "narrow, not drift" in the W8 first-pass doc (per `docs/current-system.md` §3.2.3 judgment) because the observable outcome to the client is a terminal callback regardless of which admin path committed. Human **upgraded** to drift on 2026-04-21 via thread #34 — the ground-truth mismatch between queue and payout is a reconciliation smell that will bite during later audits even if the client-facing callback is correct.

Fix sketch (two options, (i) subsumes (ii)):

(i) **Transactional boundary from (a)**: the fix in companion drift `2026-04-21_drift-payout-admin-cancel-a-non-transactional-writes.md` wraps steps 5a/6a/7b/8 in one `session.WithTransaction`. Inside the transaction, step 6a's zero-match aborts the whole transaction including step 5a's queue CAS — the race window closes entirely at source, no defensive code needed.

(ii) **Explicit compensation write**: if (a) has not yet landed, add a compensation write after step 6b's zero-match abort that flips the queue row back from `cancelled` to `pending`. Requires a second CAS on `withdrawal_queue` (filter: `{source_type, source_id, status: "cancelled"}`) and careful handling of the SSE event (the `cancelled` event already fired would need a corrective `updated` event). Belt-and-braces but strictly weaker than (i).

W4 pickup recommendation: if (a) is scheduled, (b) auto-resolves as a side-effect — close (b) as "resolved by (a)" once (a)'s PR merges, deliverable reduces to a regression test confirming the race window is closed. If (a) is deferred, ship (b)'s option (ii) as a standalone PR. Do not ship option (ii) after option (i) lands — redundant and adds unreachable compensation code.

---
*Added via Oracle Learn*
