---
title: flow-drift — payout-admin-cancel refund change-log re-keyed entity=client → entity=wallet (#505)
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, flow-drift, flow:payout-admin-cancel, step:8, wallet, payout, w9]
created: 2026-06-01
source: docs/flows/payout-admin-cancel.md
related:
  - 2026-06-01_wallet-log-payout-refund-entity-wallet-keyed-or-match-indexed-search
  - 2026-05-05_payout-admin-cancel-reason-validation-tightened
project: github.com/kokarat/mobiz-payment-gateway
---

W9 pass 2026-06-01 (range `bf57c0e..a9a3acb`). Flow `payout-admin-cancel` step 8
(the `wallets_change_logs` insert inside `CancelPayout`) **drifted** at `a9a3acb`
(#505).

**Flow claim (stale):** §Postconditions L109 + §Implementation pointers Step 8
(`controllers/PayoutController.go:1124-1144@d2a2738`) say the refund row is written
with `entity_type="client"`, `entity_id=payout.client_id`.

**Code now (`controllers/PayoutController.go:1169-1200@a9a3acb`, the
`EntityType:"wallet"` write at line 1182):** the admin-cancel refund row is written
with `entity_type="wallet"`, `entity_id=wallet._id`, `EntityName` falling back to
`payout.ClientName` when the wallet doc has no `owner_name`. This matches the
deduct side so the admin "filter by wallet" dropdown surfaces the deduct + refund
pair on the same `wallet._id`. `operation="add"` / `amount` / `reference_type` /
`reference_id` / `note` are unchanged.

This compounds the existing Step-8 `[DRIFT]` (`cd48052` #404 reason-field + line
shift). Marked `[DRIFT]` in §Postconditions and `[DRIFT-2]` on the Step 8 pointer;
pointer held at `@d2a2738` to mark the verification gap. Class C — queued for W4 /
W8 revision (not re-authored in W9). `docs/flows/.baseline` held at `9aebabb`
(prior pass's inherited deferral, unchanged).

Sibling sites also re-keyed by #505 but **not** flow-covered: `PayoutController`
UpdatePayoutStatus→failed refund (line ~948) and `PayoutRequestController`
client-cancel refund (line ~757) — no flow pointer references them, so no W9
marker. The admin `MaintenanceCancelScheduler` refund was NOT touched by #505 and
may still be client-keyed.
