---
title: **Payout admin-override syncs withdrawal_queue row (mobiz-payment-gateway, 2026-
tags: [payout, withdrawal-queue, admin-override, sync, double-execution]
created: 2026-04-27
source: W2 backlog repair 2026-04-27, commit 41744fe #312
project: github.com/kokarat/mobiz-payment-gateway
---

# **Payout admin-override syncs withdrawal_queue row (mobiz-payment-gateway, 2026-

**Payout admin-override syncs withdrawal_queue row (mobiz-payment-gateway, 2026-04-27)**

Commit `41744fe` #312. `PUT /payouts/:id/status` (admin override) now also issues a `queueCol.UpdateOne` to mirror the new status onto the matching `withdrawal_queue` row, but only when the queue item is in a transient state (`{pending, processing, waiting_to_review}`).

**Why:** before this fix, an admin approving or rejecting a payout via the dashboard left the queue row in `pending/processing`, causing the dispatcher to re-pick it and potentially double-execute the bank transfer.

**Scope:** only applied to transient states — terminal states (`success`, `failed`, `cancelled`) are never overwritten by the admin path.

// verified: controllers/PayoutController.go@41744fe

---
*Added via Oracle Learn*
