---
title: flow — withdrawal-queue-dispatch-and-claim — shared-infrastructure intent.
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, withdrawal-queue-dispatch-and-claim, reverse-engineered, ratification-pending, withdrawal-queue, dispatcher, bank-bot, maker-checker, payout, settlement, pullout, direct-transfer, cross-repo]
created: 2026-04-18
source: docs/flows/withdrawal-queue-dispatch-and-claim.md@252849e
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — withdrawal-queue-dispatch-and-claim — shared-infrastructure intent.

flow — withdrawal-queue-dispatch-and-claim — shared-infrastructure intent.

Payouts, settlements, pullouts, and direct transfers all converge on one shared work list (`withdrawal_queue`). This flow documents the lifecycle of ONE row on that list from `status=pending` (already enqueued by the source flow; enqueue itself is out of scope) to terminal status (`success` / `failed` / `waiting_to_review` / `cancelled`). Two-stage handshake separates dispatcher concerns from bot concerns: dispatcher assigns `system_bank_id` to pending items and atomically flips `system_banks.working_status: ready → busy`, but does NOT flip the queue row's status; the bot then claims items *for that bank* in an atomic pending → processing transition. Bot runs an internal maker-checker pair (maker: `claim` + execute transfer + `set-txn-id`; approver: `success`/`failed`/`waiting-to-review`) — from this repo's perspective BankBot is one external actor. Terminal transition is transactional (MongoDB session wrapping queue + source + bank-balance updates); post-commit async goroutine runs `processPostCompletion` (wallet refund on failure for payout/settlement, callback dispatch, MDR distribution on payout-success). Bank lock releases via `onBankItemDone` → `unlockBank` only when zero pending+processing items remain for that bank. Safety nets: `tryReconcileAfterMarkFailed` request-id-gated recovery (PR #189), 15-min stale-lock auto-release, >10-min stale-processing auto-fail via `MarkFailed`.

Claim strength: S4 (reverse-engineered at 252849e) pending ratification via Oracle thread #12. Three open questions threaded: (a) admin-marks-terminal alt-path coverage, (b) pullout/direct-transfer wallet semantics on failure, (c) waiting_to_review resolution handoff.

W8 root trace: 383d3a2d-5a90-4581-8dec-354c7b8318b3. Cross-repo scope (mobiz ↔ bank-bot). Foundational layer beneath payout-request, settlement, pullout-task, direct-transfer — all four source flows terminate by enqueueing and resume on terminal cascade.

---
*Added via Oracle Learn*
