---
title: cross-repo-sync — flow `withdrawal-queue-dispatch-and-claim` crosses into bank-b
tags: [technical-writer, repo:cross, current, flow, cross-repo-sync, withdrawal-queue-dispatch-and-claim, bank-bot, withdrawal-queue, maker-checker]
created: 2026-04-18
source: docs/flows/withdrawal-queue-dispatch-and-claim.md@252849e + W8 trace 383d3a2d-5a90-4581-8dec-354c7b8318b3
project: github.com/kokarat/mobiz-payment-gateway
---

# cross-repo-sync — flow `withdrawal-queue-dispatch-and-claim` crosses into bank-b

cross-repo-sync — flow `withdrawal-queue-dispatch-and-claim` crosses into bank-bot territory.

Flow `withdrawal-queue-dispatch-and-claim` (authored in mobiz-payment-gateway at 252849e, pending ratification via Oracle thread #12) has BankBot as a first-class actor. Step 5 (`BankBot → Bank: login + submit transfer`) is `// ext: kokarat/bank-bot` — its implementation lives entirely in the sibling repo. Steps 4, 6, 7 are HTTP calls FROM BankBot TO Gateway; the client-side of those calls (BankBot's request-construction, retry behaviour, maker-checker role split between bot sessions) is also bank-bot territory.

Expected counterpart when `bot-writer-oracle` gains W8: `kokarat/bank-bot/docs/flows/withdrawal-queue-consumer.md` (or equivalent slug — bot-writer chooses). When that lands, link the two traces:

    arra_trace_link(
      prevTraceId="383d3a2d-5a90-4581-8dec-354c7b8318b3",  # this W8
      nextTraceId="<bot-writer's W8 trace id>"
    )

Cross-repo contract points this flow defines (these are what bot-writer's counterpart must match):
- `POST /api/v1/bot/queue/claim` — request: `{system_bank_id}`; response: array of queue items with `batch_id` stamped. Status precondition on server: rows already assigned `system_bank_id` by dispatcher + `status=pending`. Atomicity: pending→processing is server-side `FindOneAndUpdate` loop with status guard — bot must NOT assume claim is idempotent at retry time (a retry after partial success can double-process).
- `PUT /api/v1/bot/queue/:id/set-txn-id` — maker saves `bank_transaction_id` on a `status=processing` row before approver finalises. Not terminal.
- `PUT /api/v1/bot/queue/:id/success` — body `{bank_transaction_id, bank_reference}`. Terminal. Cascades to source status + MDR + callback.
- `PUT /api/v1/bot/queue/:id/failed` — body `{error_message, error_screenshot_url}`. Terminal. Cascades to source failure + wallet refund (payout/settlement) + callback. Race safety net: `tryReconcileAfterMarkFailed` with request-id gate can flip failed→success if bank actually completed.
- `PUT /api/v1/bot/queue/:id/waiting-to-review` — body `{reason, error_screenshot_url}`. Terminal-for-queue-but-not-for-source. No refund, no callback; admin resolves.
- `POST /api/v1/bot/queue/fetch-processing` — read-only; approver fetches maker's work-in-progress. Max 20 FIFO.

Bank lock semantics (bot-visible): the gateway's `system_banks.working_status` field gates which bank the dispatcher will assign next items to. Bot does NOT manage this lock directly; it is released server-side in `onBankItemDone` after every terminal call, which triggers `unlockBank` when no pending+processing remain for that bank. Stale-lock release happens server-side after 15 min.

Known risks requiring bank-bot-side mitigation: (1) bot crash between `set-txn-id` and `success`/`failed` leaves row in `processing` with `bank_transaction_id` set but no terminal call; gateway's stale-processing >10min auto-fail covers this but triggers a refund+callback on an item that may have actually transferred — hence the `tryReconcileAfterMarkFailed` safety net. (2) bot must not retry `claim` on timeout without first calling `fetch-processing` to check if a prior claim succeeded server-side.

---
*Added via Oracle Learn*
