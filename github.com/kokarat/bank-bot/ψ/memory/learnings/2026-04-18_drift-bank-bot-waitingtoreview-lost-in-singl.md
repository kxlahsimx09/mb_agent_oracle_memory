---
title: drift — bank-bot — waiting_to_review lost in single-transfer app-layer dispatch 
tags: [technical-writer, repo:bank-bot, current, drift, bank-bot, withdrawal-queue, single-transfer, ktb, waiting-to-review-lost, for-bot-writer, cross-repo-validation]
created: 2026-04-18
source: kokarat/bank-bot/app.js:1628-1635,1694-1700 + banks/ktb/transfer.js:159 (HEAD bbd1616); surfaced during W8 authoring of docs/flows/withdrawal-queue-single-bot-transfer.md@252849e
project: github.com/kokarat/bank-bot
---

# drift — bank-bot — waiting_to_review lost in single-transfer app-layer dispatch 

drift — bank-bot — waiting_to_review lost in single-transfer app-layer dispatch (new finding).

**Not pg-writer territory — flagged for bot-writer pickup.**

**File:lines@head:** `kokarat/bank-bot/app.js:1628-1635` (batch branch) and `:1694-1700` (single-item branch) at HEAD `bbd1616` (2026-04-18 GMT+7).

**Divergence.** KTB's bank-layer transfer handler at `banks/ktb/transfer.js:159` returns `status: "waiting_to_review"` for post-OTP ambiguity:

```js
const isPostOTP = e?.code === 'KTB_POST_OTP';
const statusForPending = isPostOTP ? 'waiting_to_review' : 'failed';
```

However, the app-layer single-transfer dispatcher only distinguishes `success` vs else:

```js
if (r.status === 'success') {
  await safeMarkSuccess(r.id, r.bankRef || '', '');
  ...
} else {
  await safeMarkFailed(r.id, r.error || 'Transfer failed', batchResultScreenshot);
  ...
}
```

So `waiting_to_review` from the bank layer is collapsed to `failed` on the gateway — the dedicated `safeMarkWaitingToReview` wrapper exists at `app.js:336-351` but is only invoked by the dual-control maker/approver flows (`app.js:462,953`), never by single-transfer.

**Consequence.** Post-OTP ambiguity on KTB reports `failed` to the gateway. Gateway refunds the wallet (for payout/settlement) and sends a `failed` callback. If the bank actually completed the transfer, the race safety net `services.tryReconcileAfterMarkFailed` with request-id gate (PR #189) can flip queue + source from `failed → completed` on payout-source items — recoverable. Settlement/pullout/direct-transfer have no equivalent reconcile path, so a genuinely-succeeded-but-ambiguous KTB transfer from those sources would be doubly-debited (fund out of bank + wallet also refunded as if no transfer happened) unless the operator catches it via statement reconciliation manually.

**Why (speculation — bot-writer should confirm):** The single-transfer dispatcher was likely written before `waiting_to_review` was added to the queue state machine (PR #208, 2026-04-17). The dual-control handlers were retrofitted to dispatch `waiting_to_review` correctly but the single-transfer path was missed.

**How to apply (bot-writer's judgment):**
- Add the third branch: `else if (r.status === 'waiting_to_review') { await safeMarkWaitingToReview(r.id, r.error || 'Post-OTP ambiguity', screenshot); }` before the `else { safeMarkFailed }` fallthrough, in both locations.
- Integration test: synthesize a KTB post-OTP ambiguity (mock the `KTB_POST_OTP` error path) and assert the queue row lands in `waiting_to_review`, not `failed`.
- Regression risk: existing behaviour currently triggers `failed` → `tryReconcileAfterMarkFailed` for some subset of actual-successes; changing to `waiting_to_review` would instead require admin to resolve. This may increase operator workload short-term but aligns with the intent of `waiting_to_review` (bot doesn't know → human decides → no premature callback).

**Downstream impact on mobiz-gateway data:**
- `withdrawal_queue.status` for post-OTP-ambiguous KTB items currently ends `failed` (or `completed` after async reconcile for payout-source). With fix: would end `waiting_to_review` awaiting admin.
- Callback-side impact on clients: currently clients receive `failed` then (sometimes) `completed`. With fix: clients receive no callback until admin resolves — aligns with `payout-request.md`'s documented `waiting_to_review` semantics.

**Scope tag note:** tagged `#repo:bank-bot + #drift + #waiting-to-review-lost` (not `#repo:cross`) because the fix lives entirely in bank-bot. The gateway's `MarkWaitingToReview` endpoint is correct and available; it's just not invoked for this case. Filed from `pg-writer-oracle` during W8 authoring of `docs/flows/withdrawal-queue-single-bot-transfer.md`. Bot-writer should triage during next W1/W2 drift sweep.

**Related filing:** `learning_2026-04-18_drift-bank-bot-appjs1244-single-transfer-suc` (the `bankRef`-in-wrong-slot drift on the same file) will be superseded by a revision that corrects my original framing (there is no separate bankTxnId in single-transfer; the slot-swap argument differs).

---
*Added via Oracle Learn*
