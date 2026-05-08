---
title: W8 handoff: uncovered surface — DirectTransfer admin manual status override path
tags: [technical-writer, repo:mobiz-payment-gateway, current, w8-handoff, uncovered-surface, flow:direct-transfer-admin-status-override, direct-transfer]
created: 2026-05-07
source: controllers/DirectTransferController.go:771-879@06ce544
project: github.com/kokarat/mobiz-payment-gateway
---

# W8 handoff: uncovered surface — DirectTransfer admin manual status override path

W8 handoff: uncovered surface — DirectTransfer admin manual status override path is not covered by any current flow doc.

Surface: `controllers/DirectTransferController.go::UpdateDirectTransferStatus` (`PUT /api/v1/direct-transfers/:id/status`). Used by the `/direct-transfer` admin page's "Mark Success / Mark Failed" buttons when admin reconciles a `waiting_to_review` row. After `68fbb18` #414 (2026-05-07) this handler now has materially more behavior than a status flip:
- reads existing transfer first (404 if missing)
- syncs withdrawal_queue with same status guard PayoutController uses
- fires `services.SyncDepositRefundStatus` for refund DTs (transfer_type=="refund")
- publishes withdrawal-queue SSE event

Suggested W8 authoring: `flow:direct-transfer-admin-status-override` (or extend the existing direct-transfer family if that's how it's organized in W8 thinking).

Why this isn't a class D undocumented-step: the closest existing flow is `payout-admin-cancel`, which handles the payout-side admin cancellation path — a different actor, different source type, different semantics. There is no DirectTransfer flow at HEAD; the admin manual-override path is brand-new W8 territory.

Sibling-affected flow: `withdrawal-queue-dispatch-and-claim.md` and `withdrawal-queue-single-bot-transfer.md` document the bot-driven withdrawal-queue lifecycle but not the admin-side overrides. The admin override path now interacts with the queue (sync + SSE) so a future W8 may want to either co-extend those flows or author a new direct-transfer family.

Filed by W9 pass 2026-05-07 (range 6e10032..06ce544); no flow doc updated for this surface (W9 cannot author flows).

---
*Added via Oracle Learn*
