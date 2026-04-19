---
title: settlement waiting_to_review resolution — new `/settlements/:id/confirm-review` 
tags: [technical-writer, repo:mobiz-payment-gateway, current, settlement, waiting-to-review, confirm-review, withdrawal-queue, thread-14-partial-answer, admin-action, int-status-carveout]
created: 2026-04-18
source: controllers/SettlementController.go:1394-1493@596ddc0 + services/withdrawalQueue.go:1078-1094@5a99588 + routes/settlement.go:32@596ddc0
project: github.com/kokarat/mobiz-payment-gateway
---

# settlement waiting_to_review resolution — new `/settlements/:id/confirm-review` 

settlement waiting_to_review resolution — new `/settlements/:id/confirm-review` endpoint + int-3 carve-out.

Commit `596ddc0` (#225, 2026-04-18) + `5a99588` (#224, 2026-04-18) together answer the settlement slice of Oracle thread #14 ("how does admin resolve `waiting_to_review`?"). Before these commits, `services.MarkWaitingToReview` wrote the string `"waiting_to_review"` onto every source document uniformly, which crashed the settlement list page (`Settlement.Status` is `int`, MongoDB decode error → 500). The fix is a two-part carve-out:

1. `services/withdrawalQueue.go:1078-1094` — the source-document mirror now branches on `item.SourceType == models.SourceTypeSettlement` and writes **int 3** to `settlements.status` (vs string `"waiting_to_review"` to everything else). Settlement is the only source that now uses int 3 for this state; payouts, direct_transfers, pullout_logs keep the string convention. This extends the "Status codes" split documented in `docs/current-system.md §2.1`: Settlement was already the int-operation-convention odd-one-out (0/1/2), and now also carries 3=waiting_to_review in the same int field.

2. `controllers/SettlementController.go:1394-1493` + `routes/settlement.go:32` — new `PUT /api/v1/settlements/:id/confirm-review` (permission `PermApprove("settlement")`), body `{status: "success"|"failed", reason?: string}`. CAS-guards `settlement.Status == 3`. `success` → status 3→1 + completed_at. `failed` → status 3→2 + refund `Amount+Fee` to the entity wallet + insert `wallets_change_logs` row (`operation=settlement_refund`). Both branches mirror the new status onto `withdrawal_queue`. Answers thread #14's "Option 3 — dedicated source endpoint" for the settlement source specifically; payout still uses `/payouts/:id/confirm-completed` (§3.2.1); direct_transfer and pullout have no documented admin-resolve path at HEAD.

Observations worth filing as follow-up `#drift + #followup`:

- **Non-transactional.** The `settlements` UpdateOne, the wallet `$inc`, the change-log insert, and the queue-mirror write are four independent MongoDB calls. A crash between any two leaves partial state. Compare `/payouts/:id/confirm-completed` which runs its equivalent multi-write under a MongoDB session transaction.
- **Missing MDR distribution on success branch.** `ApproveSettlement` (the pre-existing success path) fans out per-partner MDR shares; the new `confirm-review` success branch does not. Gap: settlement that reaches `status=1` via confirm-review skips partner crediting entirely. Could be intentional (the bot already paid MDR at the original queue success, and confirm-review is just admin ratification) or a drift. Not yet classified.
- **No idempotency guard beyond the CAS.** Re-running `confirm-review` on an already-failed settlement (`status=2`) is caught by the `status != 3` 400; but the body parser is silent (`c.BodyParser(&input)` ignores error), so a request with `status: "bogus"` falls to the `else` branch (refund + change-log) **and** writes `status: "bogus"` verbatim onto `withdrawal_queue` in the mirror step.
- **Wallet lookup unchecked.** The `FindOne` into `wallet` discards its error; if no wallet matches the `{owner_type, owner_id}` pair, the `$inc` still runs (creating the wallet or erroring) and the change-log row is written with zero `BalanceBefore`/`BalanceAfter` — not a faithful audit.

Cross-flow implication: `docs/flows/withdrawal-queue-dispatch-and-claim.md` §Error paths bullet "Bot reports `waiting_to_review`" carries `[AWAITING_THREAD:14]` — thread remains pending (not `answered`) so the marker stays per workflow-thread-resolve discipline, but the settlement slice of the question is now code-backed. Single-transfer (KTB) still can't *produce* `waiting_to_review` at all due to the bot-side drift tracked in thread #16.

---
*Added via Oracle Learn*
