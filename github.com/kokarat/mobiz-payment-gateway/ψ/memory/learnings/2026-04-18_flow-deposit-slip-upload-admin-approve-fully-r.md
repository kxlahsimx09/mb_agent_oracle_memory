---
title: flow — deposit-slip-upload-admin-approve — fully ratified (S4 → S2 via threads #
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, deposit-slip-upload-admin-approve, ratified, revision, deposit, admin-approve, thunder, mdr, callback]
created: 2026-04-18
source: docs/flows/deposit-slip-upload-admin-approve.md@c5270b3 + threads #6 #7 closed
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — deposit-slip-upload-admin-approve — fully ratified (S4 → S2 via threads #

flow — deposit-slip-upload-admin-approve — fully ratified (S4 → S2 via threads #6 + #7).

Both ratification threads now closed:
- Thread #7 (2026-04-17): wallet-change-log operation divergence — intentional. `wallets_change_logs.operation = "deposit"` on admin-approve path vs `"deposit_match"` on matcher path is by-design so ops can filter on operation to count human-curated credits. Documented as recorded behaviour.
- Thread #6 (2026-04-18): spec ratified accurate; (a) admin transRef bypass + (b) silent skip of inactive-partner MDR + (c) reject branch missing approved_by audit fields all classified as gaps to fix later. Three separate #drift+#followup learnings filed.

Ratified intent (one paragraph):

When `deposit-qr-request`'s automatic path can't confirm a payer's transfer, the client uploads the payer's slip image to POST /api/v1/deposit/:txnId/upload-slip (API-Key auth). The gateway uploads the image to CDN, calls Thunder API /v2/verify, persists slip fields onto `ts_deposits`, flips status pending → checking (which removes the deposit from the matcher's queue per services/transactionMatcher.go:594), and publishes an SSE event slip_uploaded. The deposit then parks indefinitely until an admin (JWT + deposit:approve permission) calls PUT /api/v1/deposits/:id/status with status=paid OR a non-paid status. The paid branch runs an atomic Mongo session: CAS-flip status pending|checking → paid, persist 3 reviewer audit fields (approved_by, approved_by_type, approved_at), $inc client wallet, distribute MDR to partners (silent-skip on inactive partners — drift b), insert transactions row, and queue a "completed" callback. The non-paid branch is lighter: status + updated_at + free-text notes only — no reviewer audit fields, no callback (drift c), wallet refund only if status was previously paid. Admin-only transRef duplicate bypass (drift a) lets ops attach the same slip to multiple deposits with no log.

Three known gaps queued for W4 (filed today, separate learnings):
- 2026-04-18_drift-flowdeposit-slip-upload-admin-approve-a (admin transRef bypass with no audit)
- 2026-04-18_drift-flowdeposit-slip-upload-admin-approve-b (silent skip of inactive-partner MDR — system-wide, also affects matcher path)
- 2026-04-18_drift-flowdeposit-slip-upload-admin-approve-c (reject branch missing reviewer audit fields — pairs with payout-request c)

Source: docs/flows/deposit-slip-upload-admin-approve.md@&lt;ratification-commit&gt; + threads #6 (closed) + #7 (closed)
W8 root trace: 4b076751-86c5-42b6-ba5a-e3dfea9ea6b3
Supersedes: learning_2026-04-17_flow-deposit-slip-upload-admin-approve-intent (ratification-pending tag was the live state at that point; now fully ratified)

---
*Added via Oracle Learn*
