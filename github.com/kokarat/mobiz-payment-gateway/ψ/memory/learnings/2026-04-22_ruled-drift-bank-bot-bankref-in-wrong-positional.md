---
title: ruled-drift — bank-bot bankRef in wrong positional slot of safeMarkSuccess (sing
tags: [technical-writer, repo:mobiz-payment-gateway, current, followup, ruled-drift, bank-bot, withdrawal-queue, single-transfer, ktb, bankref-slot, cross-repo-resolve]
created: 2026-04-22
source: bank-bot commit e3db48a (2026-04-19) + verification at bank-bot origin/main HEAD + original drift 2026-04-18_drift-bank-bot-bankref-in-wrong-positional-slot
project: github.com/kokarat/mobiz-payment-gateway
---

# ruled-drift — bank-bot bankRef in wrong positional slot of safeMarkSuccess (sing

ruled-drift — bank-bot bankRef in wrong positional slot of safeMarkSuccess (single-transfer) — resolved at e3db48a, 2026-04-19. Drift original filed 2026-04-18 in `github.com/kokarat/bank-bot/ψ/memory/learnings/2026-04-18_drift-bank-bot-bankref-in-wrong-positional-slo.md` is resolved. The single-transfer branches now pass `bankRef` in the correct third positional slot of `safeMarkSuccess`. Fix commit: `e3db48a` — "fix: bankRef in wrong positional slot of safeMarkSuccess (single-transfer)" (kokarat/bank-bot, 2026-04-19 GMT+7). Verified at HEAD (bank-bot `origin/main`): `app.js:1642` (batch branch) and `:1711` (single branch) both call `safeMarkSuccess(itemId, '', result.bankRef || '')`, correctly occupying the third slot defined at `app.js:353` (`async function safeMarkSuccess(itemId, bankTxnId, bankRef)`). Downstream effect for post-fix KTB payouts: `withdrawal_queue.bank_reference = <bankRef>`, `bank_transaction_id = ''`; via `dfafa78` #213 mirror rule, `ts_payouts.bank_transaction_id` for post-fix completions is correctly empty and `bank_reference` carries the KTB reference. Pre-fix payouts (completed before 2026-04-19) still carry the reference in `bank_transaction_id` — the mirror rule is permanent, and operators debugging those legacy rows must know to look at `bank_transaction_id` semantically as "reference" rather than a true transaction id. Closure note: no Oracle thread was opened for this drift on the mobiz side (thread #15 remained a carry-forward anchor from the flow doc); closure is based on code evidence at bank-bot origin/main plus the originating commit. Sibling ruled-drift learning for drift #2 (`waiting_to_review` lost in app-layer dispatch) filed on the bank-bot side on 2026-04-21 as `2026-04-21_ruled-drift-bank-bot-waitingtoreview-lost-i.md`; both drifts from the 2026-04-18 authoring pass are now closed. How to apply: when adding new single-transfer-bank integrations (beyond KTB), consumer code MUST call `safeMarkSuccess(itemId, bankTxnId, bankRef)` positionally per the signature at `app.js:353`; if the bank only returns one identifier (as KTB does), pass it in `bankRef` and leave `bankTxnId` as empty string.

---
*Added via Oracle Learn*
