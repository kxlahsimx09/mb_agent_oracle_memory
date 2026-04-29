---
title: **settlements collection must not receive status:"processing" string from bot-cl
tags: [withdrawal-queue, settlements, bson, bot-claim, status-type]
created: 2026-04-27
source: W2 backlog repair 2026-04-27, commit 909d5a3
project: github.com/kokarat/mobiz-payment-gateway
---

# **settlements collection must not receive status:"processing" string from bot-cl

**settlements collection must not receive status:"processing" string from bot-claim (mobiz-payment-gateway)**

Commit `909d5a3`. `services/withdrawalQueue.go` bot-claim update object conditionally writes `status: "processing"` only when `item.SourceCollection != "settlements"`.

**Why:** `settlements.status` is an integer field (`0=pending,1=completed,2=failed,3=cancelled`). Writing the string `"processing"` into it causes a BSON decode error (HTTP 500) on any subsequent read of the settlement document. Other source types (`ts_payouts`, `pullout_logs`, etc.) use a string `status` field, so they can accept `"processing"`.

**Pattern:** whenever adding a new source type to the withdrawal queue, verify whether its model's `status` field is `int` or `string` before adding it to the bot-claim update object.

// verified: services/withdrawalQueue.go@909d5a3

---
*Added via Oracle Learn*
