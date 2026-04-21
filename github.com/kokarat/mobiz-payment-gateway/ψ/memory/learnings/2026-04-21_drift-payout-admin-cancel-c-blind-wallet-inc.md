---
title: drift — payout-admin-cancel (c) blind wallet $inc with silent failure mode. Step
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow:payout-admin-cancel, wallet-refund, silent-failure, admin-cancel, payout]
created: 2026-04-21
source: docs/flows/payout-admin-cancel.md + controllers/PayoutController.go:1019-1061@aff85e1 + thread #34 closed 2026-04-21
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — payout-admin-cancel (c) blind wallet $inc with silent failure mode. Step

drift — payout-admin-cancel (c) blind wallet $inc with silent failure mode. Step 7b of `CancelPayout` at `controllers/PayoutController.go:1026-1033@aff85e1` calls `walletCollection.UpdateOne(ctx, {owner_type: "client", owner_id: payout.ClientID}, {$inc: {balance, available: refundAmount}})` with no `MatchedCount` check. Two silent failure modes:

(1) **Wallet row missing** (deleted client, partial migration, manual cleanup): `UpdateOne` with a non-matching filter is a no-op in MongoDB — no document created, no error returned, `MatchedCount=0`. The handler does not inspect `result.MatchedCount`, so the refund is effectively lost.

(2) **Optimistic log line** (lines 1037): `log.Printf("[Payout] Refunded %.2f to client %s wallet (payout %s cancelled by %s)", ...)` prints **before** the write result is checked — so it fires even when no wallet row was updated. The log claims success that didn't happen.

(3) **Discarded error** (lines 1034-1036): when the `$inc` itself errors (context timeout, transient Mongo unavailability), `refundErr` is only `log.Printf`'d as a warning and then discarded. No response-body signal to the admin, no drift flag on the `ts_payouts` row for later reconciliation — the handler returns 200 with a "cancelled and refunded" message even when the refund failed.

Shape paired with `payout-auto-cancel-pending-timeout` (b) (learning `2026-04-21_drift-payout-auto-cancel-pending-timeout-b-can.md`, ruled drift via thread #31 2026-04-21) — same "discarded error" shape, same fix pattern. Ruled drift via thread #34 on 2026-04-21.

Fix sketch: (i) check `result.MatchedCount` on the refund `UpdateOne`; (ii) on `MatchedCount=0` or `refundErr != nil`, propagate the error into the HTTP response body (downgrade the response from 200 to 500 or add a `refund_status: "failed"` field) OR surface as a flag on the payout row (e.g., `refund_failed: true` + `refund_error: "<details>"`) for admin re-review; (iii) downgrade the success log line to only fire on `MatchedCount=1` AND `refundErr == nil`; (iv) skip the `wallets_change_logs` insert on zero-match/error (current code already does this correctly via the `err != nil` guard at line 1034, but the `MatchedCount=0` case still falls through to the insert today). Fold into (a)'s transactional wrapper — inside a transaction the zero-match aborts the whole transaction cleanly and the payout flip-to-cancelled also rolls back, which is the desired behavior (admin sees an error response; payout stays `pending`; admin can retry or investigate).

W4 pickup context: fold into (a)'s PR; the transaction simplifies (c)'s fix from "propagate error + mark flag + skip write" to "let the transaction abort the whole sequence". When W4 picks up both (a) and (c), the combined PR's delta is smaller than fixing (c) alone under the non-transactional status quo.

---
*Added via Oracle Learn*
