---
title: payout admin-cancel endpoint — PUT /payouts/:id/cancel with queue-first cascade 
tags: [technical-writer, repo:mobiz-payment-gateway, current, payout, admin-cancel, wallet-refund, withdrawal-queue, financial, recovered-from-double-wrap]
created: 2026-04-19
source: controllers/PayoutController.go:913-1079 + routes/payout.go:31 @ 153a4f6 (PR #228) — recovered 2026-04-19
project: github.com/kokarat/mobiz-payment-gateway
---

# payout admin-cancel endpoint — PUT /payouts/:id/cancel with queue-first cascade 

payout admin-cancel endpoint — PUT /payouts/:id/cancel with queue-first cascade and wallet refund

Admin-cancel path for a payout on mobiz-payment-gateway, implemented at `controllers/PayoutController.go:913-1079 @ 153a4f6` and routed at `routes/payout.go:31`. Single authenticated endpoint: `PUT /payouts/:id/cancel`. Landed in PR #228.

Behavior contract when the payout is in `PENDING`, `WAITING_FOR_DISPATCH`, or `QUEUED` terminal-eligible state:

1. Guard: only `PENDING` / `WAITING_FOR_DISPATCH` / `QUEUED` are cancellable. Any terminal state (`SUCCESS`, `FAILED`, `CANCELLED`) returns 409 with a state-specific error message.
2. Queue-first cascade: if the payout has an active row in `withdrawal_queue`, that row is marked `CANCELLED` first (lock acquired on the queue row, cursor advanced past). This ensures no bot picks up an admin-cancelled item mid-claim — the queue row's terminal transition wins the race.
3. Wallet refund: after queue cancellation, the payout's pre-deducted wallet amount is credited back to the project wallet via `walletLedger.CreditRefund(projectId, amount, "admin_cancel_payout")`. Idempotent on `payout_id` so a duplicate cancel-then-retry cannot double-credit.
4. Payout state transition: only after both the queue row is cancelled AND the wallet is refunded, the payout row transitions to `CANCELLED` with `cancelled_at`, `cancelled_by_admin_id`, and `cancel_reason` fields populated.
5. Callback dispatch: the cancellation triggers the project's outbound webhook with `status: "cancelled"` via the standard callback scheduler (reuses the same retry policy as other payout status transitions).

Financial-behavior note: the queue-first cascade is load-bearing. An earlier implementation that refunded the wallet first (before cancelling the queue row) had a race where a bot could claim the queue row between refund and queue-cancel, resulting in a payout that was paid out AND refunded. The current order guarantees at-most-once.

Error paths documented in code: 400 on malformed uuid; 401 on missing auth; 403 on cross-project cancellation attempt; 404 on unknown payout; 409 on terminal state (above). No 5xx expected under normal operation — a wallet-credit failure rolls the transaction back and returns 409 with `wallet_refund_failed`.

Audit trail: all five state transitions (guard check, queue cancel, wallet credit, payout cancel, callback enqueue) write to `audit_log` with `actor_type="admin"` + admin id. Replayable.

Related docs: `docs/flows/payout-request.md` covers the create path; this endpoint is the inverse. No flow-map doc yet for the admin-cancel path — the full W8 pass landed same day in PR #229 covers the non-admin cancellation cases. Consider extending that flow or authoring a dedicated `payout-admin-cancel.md` if the cascade becomes more complex.

RECOVERED 2026-04-19 from double-wrap file `2026-04-19_title-payout-admin-cancel-endpoint-put-pay.md`; supersedes `learning_2026-04-19_title-payout-admin-cancel-endpoint-put-pay`.

---
*Added via Oracle Learn*
