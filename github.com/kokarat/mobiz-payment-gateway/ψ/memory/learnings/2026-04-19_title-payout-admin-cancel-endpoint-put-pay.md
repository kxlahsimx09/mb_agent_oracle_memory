---
title: ---
tags: [technical-writer, repo:mobiz-payment-gateway, current, payout, admin-cancel, wallet-refund, withdrawal-queue, financial]
created: 2026-04-19
source: controllers/PayoutController.go:913-1079 + routes/payout.go:31 @ 153a4f6
project: github.com/kokarat/mobiz-payment-gateway
---

# ---

---
title: payout admin-cancel endpoint — PUT /payouts/:id/cancel with queue-first cascade and wallet refund
tags: [technical-writer, repo:mobiz-payment-gateway, current, payout, admin-cancel, wallet-refund, withdrawal-queue, financial]
created: 2026-04-19
source: controllers/PayoutController.go:913-1079 + routes/payout.go:31 @ 153a4f6 (PR #228)
related:
  - 2026-04-18_drift-payout-cancel-race  # if one exists; cross-ref later
project: github.com/kokarat/mobiz-payment-gateway
---

# payout admin-cancel endpoint — PUT /payouts/:id/cancel

**What landed (`153a4f6`, PR #228, 2026-04-19):** a dedicated admin endpoint to cancel **pending** payouts with a single sequenced path: queue-first cascade → payout CAS → wallet refund (amount + fee) → change-log → SSE/callback fan-out. The generic `PUT /:id/status` validator was narrowed to `oneof=pending processing completed failed waiting_to_review` — `"cancelled"` is **removed** so nothing can reach the cancel branch except through this endpoint.

## Why it's load-bearing (durable facts)

1. **Cancellation is queue-first.** If a `withdrawal_queue` row exists for the payout and is in state `processing`, the endpoint **refuses** the cancel entirely (400 "bot is currently processing this payout") before any write. This is how double-transfer is prevented — admin cannot cancel a payout the bot is mid-flight on.
2. **Only `status == "pending"` can be cancelled.** Read-then-CAS on `ts_payouts`; no broadening to `processing`/`waiting_to_review`/`failed`. Admins who need to resolve other terminal states use `/:id/confirm-completed` (§3.2.1) or `/:id/status` (for `failed`).
3. **Refund is `amount + payout_fee`** (not just `amount`). Mirrors the `PayoutRequest` creation deduction. Rounded via `helpers.RoundToSatang`. Change-log row gets `Operation: "add"`, `ReferenceType: "payout"`, and the `<RequestID> | ` note prefix per the `#197` convention.
4. **The three writes (queue, payout, wallet) are NOT transactional.** Each step is a separate top-level context. A crash between step 1 (queue cancel) and step 2 (payout cancel), or between step 2 and step 3 (wallet refund), leaves the system in a visibly inconsistent state until manual reconciliation. Not flagged as a drift in this W2 pass — scenario is narrow (one admin request, sub-second) and the happy path covers >99% — but worth calling out if an incident ever matches this signature.
5. **Wallet-lookup failure is silent.** The pre-refund wallet read (for change-log before/after values) ignores errors; the subsequent `$inc` then runs blind. A missing wallet document would therefore credit nothing (zero matched) but still report `success:true` to the admin. No alarm. Consider revisiting if a client-with-no-wallet scenario becomes observable.
6. **Validator carve-out is the enforcement anchor.** The reason `/:id/status → cancelled` is no longer reachable is not a runtime guard but the `validator.New()` call in `UpdatePayoutStatus` (`PayoutController.go:519`) — if someone ever re-adds `cancelled` to the `oneof=` list, the double-refund path reopens. Review this line when touching payout status validation.

## Relationship to other flows

- **`payout-request.md` flow** (thread #8, ratified 2026-04-18) now has an additional terminal: admin-cancel → `EventPayoutCancelled` callback. The flow doc's §Sequence currently ends at `completed`/`failed`; a follow-up W2 or W8 may want to extend §Error paths with the admin-cancel branch.
- **`withdrawal-queue-dispatch-and-claim.md`** (thread #12, ratified) — the queue-first cascade here is the canonical example of the "admin can cancel queue-pending but not queue-processing" rule that thread #12 answer (a) alluded to. Worth cross-referencing.
- **§3.2.1 `/confirm-completed`** is the mirror for `failed → completed`; this endpoint is the mirror for `pending → cancelled`. Both exist because `PUT /:id/status` was too coarse to carry the fee/wallet side-effects safely.

## What changed in `docs/current-system.md` this pass

- §3 API summary line for `/api/v1/payouts` — added `/:id/cancel`; added validator carve-out; `SUPERSEDED` marker on the prior "move stuck waiting-to-review payouts to `cancelled` via `/:id/status`" claim.
- New §3.2.3 section with full guard/sequence/fan-out write-up.
- Citations refreshed to `@153a4f6`.

---
*Added via Oracle Learn*
