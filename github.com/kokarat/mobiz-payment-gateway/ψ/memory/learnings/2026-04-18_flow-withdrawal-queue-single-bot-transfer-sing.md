---
title: flow — withdrawal-queue-single-bot-transfer — single-session bot variant intent.
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, withdrawal-queue-single-bot-transfer, reverse-engineered, ratification-pending, withdrawal-queue, bank-bot, ktb, single-transfer, cross-repo, sibling-flow]
created: 2026-04-18
source: docs/flows/withdrawal-queue-single-bot-transfer.md@252849e + kokarat/bank-bot@bbd1616
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — withdrawal-queue-single-bot-transfer — single-session bot variant intent.

flow — withdrawal-queue-single-bot-transfer — single-session bot variant intent.

Sibling to `withdrawal-queue-dispatch-and-claim`. Covers the single-Playwright-session variant where one bot identity claims, drives the bank portal, and reports terminal — all in one context. Used by banks whose portals do not require dual-control (today: KTB only, per `bank-bot/banks/ktb/index.js:33-34`). Gateway-side machinery is identical to sibling (`services.EnqueueWithdrawal` / `ClaimByBank` / `MarkSuccess` / `MarkFailed` / `onBankItemDone` / safety nets) — this flow only diverges in §Actors (one `BankBotSingle` vs two maker+approver) and §Sequence (no `/set-txn-id`, no `/fetch-processing`).

6 actors, 9 actor-crossing messages. Claim strength S4 at mobiz `252849e` + bank-bot `bbd1616`; ratification pending Oracle thread #13.

Two bank-bot drifts surfaced + documented in §Error paths (both filed as `#drift + #repo:bank-bot` for bot-writer): (I) `safeMarkSuccess(itemId, bankRef, '')` passes bankRef in the bankTransactionId positional slot — single-transfer has no separate bankTxnId so the correct call is `safeMarkSuccess(itemId, '', bankRef)`. (II) KTB transfer layer returns `status: "waiting_to_review"` for post-OTP ambiguity (`banks/ktb/transfer.js:159`) but the app-layer single-transfer dispatcher at `app.js:1628-1635,1694-1700` only branches on `success` — non-success (including `waiting_to_review`) falls through to `safeMarkFailed`. Consequence: `waiting_to_review` is unreachable from single-transfer at HEAD; post-OTP ambiguity on KTB is reported as `failed` with `tryReconcileAfterMarkFailed` as the only recovery path (payout-source only).

W8 root trace: `6afbf4f9-e19e-4b63-8a9e-26e23f941154` (child of sibling trace `383d3a2d-5a90-4581-8dec-354c7b8318b3`). Stacked PR on top of PR #220 per W8 Step 10 stacked-PR clause. Cross-link added to `docs/current-system.md §6.1` listing both flow variants (dual-control and single-session).

---
*Added via Oracle Learn*
