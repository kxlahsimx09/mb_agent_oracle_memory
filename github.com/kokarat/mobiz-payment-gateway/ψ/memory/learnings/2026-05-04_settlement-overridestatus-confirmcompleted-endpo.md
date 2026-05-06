---
title: Settlement OverrideStatus + ConfirmCompleted endpoints (b327f46 #398, 2026-05-05
tags: [technical-writer, repo:mobiz-payment-gateway, current, settlement, admin-action, override, confirm-completed, withdrawal-queue, wallet]
created: 2026-05-04
source: controllers/SettlementController.go:1574-1905@b327f46 + routes/settlement.go:34-35@b327f46
project: github.com/kokarat/mobiz-payment-gateway
---

# Settlement OverrideStatus + ConfirmCompleted endpoints (b327f46 #398, 2026-05-05

Settlement OverrideStatus + ConfirmCompleted endpoints (b327f46 #398, 2026-05-05) — admin recovery surface mirroring payout's `/:id/override` + `/:id/confirm-completed`. Override flips success(1)→failed(2) and refunds wallet by `amount + fee`; ConfirmCompleted flips failed(2)→success(1) and re-deducts. Both use `session.WithTransaction` (status flip + wallet write + change-log + queue-mirror in one), `FindOneAndUpdate(SetReturnDocument(After))` so change-log before/after derive from the post-update doc, and permanent-audit fields (`override_reason`, `confirm_completed_reason`) that reject double-action. ConfirmCompleted folds the insufficient-balance check into the wallet filter (`available: $gte deductAmount`) so concurrent confirms can't both win. Permission: PermApprove("settlement"). Wallet log operations: `settlement_override_refund`, `settlement_confirm_completed`. Withdrawal_queue mirror: override→`status:overridden`; confirm-completed→`status:success` + stamp `completed_at` + `$unset failed_at, error_message`. SSE events on settlements channel: `overridden`, `confirmed_completed`. Insufficient-balance error mapped to 400 (string match on "insufficient"/"deduct wallet"). Field naming aligned with payout (confirmed_completed_at/by/by_username) so dashboard widgets read both. No MDR fan-out — settlements never distribute MDR via these transitions (ApproveSettlement is the only MDR-distributing settlement path).

---
*Added via Oracle Learn*
