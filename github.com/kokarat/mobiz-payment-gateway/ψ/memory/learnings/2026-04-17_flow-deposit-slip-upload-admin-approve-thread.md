---
title: flow — deposit-slip-upload-admin-approve — thread #7 ratified: wallets_change_lo
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, deposit-slip-upload-admin-approve, ratified, wallet, mdr, decision, deposit]
created: 2026-04-17
source: docs/flows/deposit-slip-upload-admin-approve.md@post-edit + thread #7 + trace ce4a4242
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — deposit-slip-upload-admin-approve — thread #7 ratified: wallets_change_lo

flow — deposit-slip-upload-admin-approve — thread #7 ratified: wallets_change_logs.operation is intentionally bimodal.

Human ruling (2026-04-17 GMT+7, thread #7 answer = "intentional" to a binary Reading A / Reading B question): the admin-approve code path writes `wallets_change_logs.operation = "deposit"` (`controllers/DepositController.go:867@c5270b3`) and the auto-matcher code path writes `operation = "deposit_match"` (`services/transactionMatcher.go:627-660`) on purpose. This is not drift — it is ops-reporting signal. Downstream queries can filter `operation = "deposit"` to count admin-confirmed credits vs `operation = "deposit_match"` to count matcher-automatic credits.

Consequences:
- Doc `docs/flows/deposit-slip-upload-admin-approve.md` §Success criteria bullet 4 and §Implementation pointers Step 8 now carry `// verified-via-thread:7` citations and describe this as recorded behavior, not drift.
- Any future W4 (drift reconciliation) pass must **not** propose converging the two strings — that would break ops reporting.
- Companion flow `docs/flows/deposit-qr-request.md` already documents the matcher-side `deposit_match` value; cross-reference is now ratified.

Evidence:
- controllers/DepositController.go:862-882@c5270b3 — admin path log write, operation="deposit"
- services/transactionMatcher.go:627-660 — matcher path log write, operation="deposit_match"
- Oracle thread #7 message 2 (human): "intentional"
- W8 resolution child trace: ce4a4242-a14a-4e8a-a9e9-7193ca370201 (parent 4b076751-86c5-42b6-ba5a-e3dfea9ea6b3)

Thread #6 (overall ratification of the reverse-engineered spec) remains open; doc header claim strength stays S4 until #6 answers.

---
*Added via Oracle Learn*
