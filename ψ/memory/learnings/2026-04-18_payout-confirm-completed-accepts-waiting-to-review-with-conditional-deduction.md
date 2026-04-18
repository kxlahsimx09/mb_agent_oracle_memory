---
title: payout confirm-completed now accepts waiting_to_review with conditional wallet deduction (incident-driven)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - payout
  - waiting-to-review
  - confirm-completed
  - wallet
  - incident
  - decision
created: 2026-04-18
source: controllers/PayoutController.go:1618-1625,1682-1694,1696-1736@f44cf44
related:
  - 2026-04-17_waiting-to-review-payout-withdrawal-queue-semantics
project: github.com/kokarat/mobiz-payment-gateway
---

# Payout confirm-completed now accepts waiting_to_review with conditional wallet deduction

As of 2026-04-18 (commits `b7e8165` #212 → `550dc8d` → `f44cf44`), `PUT /api/v1/payouts/:id/confirm-completed` accepts both `failed` and `waiting_to_review` as valid source statuses. The guard check, the atomic `UpdateOne` filter, and the wallet step all had to be touched for the path to be correct.

## What changed across the three commits

1. **`b7e8165` (#212)** — outer guard at `controllers/PayoutController.go:1618-1625` widened from `payout.Status != "failed"` to `payout.Status != "failed" && payout.Status != "waiting_to_review"`. Error message updated to "Can only confirm failed or waiting_to_review payouts as completed".
2. **`550dc8d`** — #212 missed the inner atomic filter inside the session transaction at `controllers/PayoutController.go:1682-1694`. That filter was still `"status": "failed"` which meant the outer guard let waiting_to_review payouts in but the atomic `UpdateOne` matched zero documents. Fixed to `"status": {"$in": ["failed", "waiting_to_review"]}`.
3. **`f44cf44` (CRITICAL)** — the wallet deduction step (`controllers/PayoutController.go:1696-1736`) was unconditional. This caused double-deduction because `MarkWaitingToReview` (see `services/withdrawalQueue.go:1049-1117@76326c0`) is explicitly no-wallet: the payout stays debited at creation and the wallet is never refunded while waiting for review. Deducting again in confirm-completed took the money a second time.

## Behavior at HEAD

Handler branches on **previous** status (read before step 1 flips it to `completed`):

- `payout.Status == "failed"` — wallet was refunded at `MarkFailed` time, so confirm-completed re-deducts `amount + payout_fee` with a `balance >= totalDeduct` match. Writes a `payout_confirm_completed` row to `wallets_change_logs`.
- `payout.Status == "waiting_to_review"` — wallet was never refunded. Skip deduction. Still read the wallet doc (for MDR reference) and emit `log.Printf("[Payout] Confirm completed for waiting_to_review %s — skipping wallet deduction (already deducted at creation)", payout.RequestID)`. **No change-log row is written** for the client wallet in this branch — the only wallet-change-log writes in the transaction are the partner MDR shares in step 3.

MDR distribution in step 3 (inlined inside the session) runs in both branches.

## Observable artefact of the bug

Production incident on client `jaosua777`: 5 payouts ran through `MarkWaitingToReview` → admin confirm-completed. Each payout was debited twice (once at create, once at confirm-completed). Total overcharge: **19,527.80 THB**. The fix is in `f44cf44`; the refund to the client is a separate data-repair task (not covered by this W2 pass).

## Why this is worth remembering

- `waiting_to_review` is a terminal-but-non-final state for both the queue item (per `MarkWaitingToReview` semantics) **and** the payout (admin must decide). It is not symmetrical to `failed`: `failed` involves a wallet refund, `waiting_to_review` does not. Any code path that exits `waiting_to_review` must check whether the wallet was ever refunded before assuming it needs to be.
- The three-commit sequence is also a reminder that widening a state machine edge requires touching every guard along the path: outer-handler guard, atomic UpdateOne filter, and downstream financial step. #212 → #550dc8d → #f44cf44 is a canonical example — filing it together so the next contributor sees the full shape.
- CLAUDE.md §"Payout Management" does not yet document the `waiting_to_review` → `completed` transition path; this is §9 DRIFT-9 territory (undocumented features in CLAUDE.md) and will need a resolution learning when a pass reconciles CLAUDE.md.

## Cited doc updates (docs/current-system.md @ b886cc4 post-W2)

- §2 Payout row — status string list now includes `waiting_to_review`; existing "confirm-completed fields" paragraph retained.
- §3.2 endpoint list — note on the widened refund-filter atomic match.
- §3.2.1 — full rewrite with two-branch wallet logic + incident reference inline.
- §6.1 — MarkSuccess now mentions bank_transaction_id mirror (separate fact, see `2026-04-18_bank-transaction-id-mirror-on-marksuccess-payout.md`).
