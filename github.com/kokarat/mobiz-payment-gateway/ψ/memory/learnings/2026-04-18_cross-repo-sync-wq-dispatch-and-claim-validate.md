---
title: cross-repo-sync — wq-dispatch-and-claim — validated against bank-bot.
tags: [technical-writer, repo:cross, current, flow, cross-repo-sync, withdrawal-queue-dispatch-and-claim, bank-bot, withdrawal-queue, maker-checker, validated, revision]
created: 2026-04-18
source: docs/flows/withdrawal-queue-dispatch-and-claim.md@252849e + kokarat/bank-bot@HEAD verification (2026-04-18)
project: github.com/kokarat/mobiz-payment-gateway
---

# cross-repo-sync — wq-dispatch-and-claim — validated against bank-bot.

cross-repo-sync — wq-dispatch-and-claim — validated against bank-bot.

Revises `2026-04-18_cross-repo-sync-flow-withdrawal-queue-dispatch` after read-only verification against `kokarat/bank-bot` at HEAD on 2026-04-18 GMT+7. Supersedes the initial version.

**What the initial version got right (confirmed by bank-bot code):**
- The maker-checker split inside BankBot is **operationally real** — two concurrent Playwright browser sessions, each with its own login + bank portal context, spawned at `bank-bot/app.js:403-405` as `Promise.all([makerLoop(maker), approverLoop(approver)])`. Maker hands items to approver via an in-memory Map + signal (`app.js:40-95`). Collapsing both into one diagram participant remains correct because gateway does not enforce maker ≠ approver — but the gateway-side spec now cites this evidence.
- `/bot/queue/claim` → `pending→processing` atomic flip, batch_id stamped, mirrored to source. Matches `bank-bot/core/api.js` + gateway's `ClaimByBank`.
- `/bot/queue/:id/set-txn-id` called by maker after transfer-submit, before approver finalises. Verified at `bank-bot/app.js:480`.
- `/bot/queue/:id/fetch-processing` used by approver for cross-check against what maker submitted. Verified inside approver flow.
- `/bot/queue/:id/{success,failed,waiting-to-review}` called exactly once per item — no double-marking. Verified at `bank-bot/app.js:942-969`.
- Bot has **zero bank-lock logic** — `system_banks.working_status` is purely server-managed; bot's `claimItems()` has no lock check. Verified at `bank-bot/app.js:2073-2085` + explicit comment at `bank-bot/core/api.js:136-138`.
- Auth: `X-Bot-Secret` header on every request, single shared `process.env.BOT_SECRET`.

**What the initial version got wrong / incomplete (corrected here):**

1. **`/failed` payload.** Initial claim: body is `{error_message, error_screenshot_url}` — implies both required. Reality: body is `{error_message, error_screenshot_url?}` — the URL field is optional. When omitted, bank-bot (the actual consumer) uses a separate `POST /bot/queue/:id/screenshot` multipart endpoint to upload the raw image file; gateway pushes the file to DigitalOcean Spaces and writes the resulting CDN URL onto the queue row. Both mechanisms coexist. Gateway's `UploadScreenshot` handler lives at `controllers/WithdrawalQueueController.go:438-490@252849e`. The contract this learning documents to bot-writer is: **either inline URL in terminal body OR separate multipart to /screenshot — the bot chooses; gateway supports both.**

2. **`/waiting-to-review` payload.** Same correction: `{reason?, error_screenshot_url?}` — both optional; `reason` defaults to `"Bot unsure — needs manual review"` when empty (controller `:418-420`). Screenshot uses same dual mechanism as `/failed`.

3. **Retry guard on `/claim` timeout (aspirational → factual).** Initial claim: "bot must NOT retry `/claim` without first calling `/fetch-processing` to check if a prior claim succeeded." This was **aspirational, not actual behaviour**. Bank-bot's `claimMoreItems()` at `app.js:786-811` has zero retry-guard logic — on timeout it catches + log-warns + retries directly on next loop. **Corrected framing:** gateway's `ClaimByBank` is atomically guarded server-side via status-gated `FindOneAndUpdate` (`pending→processing` transition), which means retry-after-timeout is *safe* but may return an empty batch (the prior call already flipped the items, subsequent call finds nothing matching `status=pending`). No data loss. The bot's lack of retry guard is not a bug — the server-side atomicity covers it.

**Full contract points (this is the canonical list for bot-writer's future W8):**
- `POST /api/v1/bot/queue/claim` — body `{system_bank_id}`; response: array of queue items with `batch_id` stamped. Server atomically flips assigned pending items to processing. Safe to retry.
- `PUT /api/v1/bot/queue/:id/set-txn-id` — body `{bank_transaction_id}`; maker saves the bank's transaction id onto a `processing` row before approver finalises. Not terminal.
- `POST /api/v1/bot/queue/fetch-processing` — body `{system_bank_id}`; read-only. Approver fetches maker's work-in-progress (max 20 FIFO).
- `PUT /api/v1/bot/queue/:id/success` — body `{bank_transaction_id, bank_reference}`. Terminal. Cascades to source status + MDR distribution (payout) + callback.
- `PUT /api/v1/bot/queue/:id/failed` — body `{error_message, error_screenshot_url?}`. Terminal. Cascades to source failure + wallet refund (payout/settlement only) + callback. Race safety net: `tryReconcileAfterMarkFailed` with request-id gate can flip failed→success if bank statement later proves transfer completed.
- `PUT /api/v1/bot/queue/:id/waiting-to-review` — body `{reason?, error_screenshot_url?}`; `reason` defaults to `"Bot unsure — needs manual review"`. Terminal-for-queue, non-terminal-for-source. No refund, no callback.
- `POST /api/v1/bot/queue/:id/screenshot` — multipart form (`screenshot` field) — alternative to inline URL for attaching error screenshots to `/failed` or `/waiting-to-review` items. Gateway uploads to CDN. Diagnostic-only; never gates state transition.

**Bank lock semantics (unchanged from initial version):** `system_banks.working_status` server-managed; bot has no involvement. Released via `onBankItemDone` → `unlockBank` after every terminal call. Stale-lock auto-release after 15 min of `busy`. Stale-processing auto-fail after 10 min without terminal call (triggers `MarkFailed` server-side → refund + callback).

**Known bot-side divergence (filed as separate `#drift` learning for bot-writer):** `bank-bot/app.js:1244` single-transfer flow passes `bankRef` as the 2nd positional param of `safeMarkSuccess()`, which maps to `bankTransactionId` in the API signature. Approver flow at `app.js:957` is correct; only single-transfer path is wrong. Not pg-writer territory; flagged only.

**Trace chain:** W8 root `383d3a2d-5a90-4581-8dec-354c7b8318b3`. This learning supersedes `learning_2026-04-18_cross-repo-sync-flow-withdrawal-queue-dispatch`. When bot-writer lands W8 on bank-bot side, chain: `arra_trace_link(prev="383d3a2d-…", next=<bot-W8>)`.

---
*Added via Oracle Learn*
