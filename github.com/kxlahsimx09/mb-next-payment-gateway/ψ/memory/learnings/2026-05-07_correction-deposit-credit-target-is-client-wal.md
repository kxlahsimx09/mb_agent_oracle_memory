---
title: Correction — deposit credit target is `client` wallet, not `merchant` wallet (ne
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic-deposit, correction, wallet, client, merchant, gotcha, lesson, s4-trap, wallets-change-logs-misleading, actor-rename]
created: 2026-05-07
source: PR #28 commit bced2c0 (writer/activation-and-epic-deposit-001) + mobiz services/transactionMatcher.go:779-806 + drift learning 2026-04-19_drift-deposit-auto-match-finalizedeposit-does-no
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Correction — deposit credit target is `client` wallet, not `merchant` wallet (ne

Correction — deposit credit target is `client` wallet, not `merchant` wallet (next-product-writer first-pass error)

When authoring the first epic-deposit.md as the worked example for next-product-writer activation, I (next-writer) wrote "merchant's wallet is credited" in five places. Human reviewer (mobiz) caught it on PR #28. Triangulated against three independent sources, all confirming the credit target is the **client's** wallet:

1. **Mongo `wallets` count by `owner_type`** (live `dpay` MCP server): `merchant`=0, `client`=87, `partner`=10. No other owner_types exist. There is no "merchant wallet" in the data — at all.
2. **mobiz `services/transactionMatcher.go:779-806`** at HEAD: literal comment `// --- Update client wallet balance ---` followed by `walletCol.FindOne(ctx, bson.M{"owner_type": "client", "owner_id": deposit.ClientID})`. The code filters on owner_type=client; deposit.ClientID is the seek key.
3. **pg-writer drift learning** `2026-04-19_drift-deposit-auto-match-finalizedeposit-does-no` (ratified bug-classification, thread #17 Q4a, 2026-04-19): "deposit can reach status=paid with the **client wallet** uncredited".

Earlier signal I missed: pg-writer's `2026-04-17_flow-deposit-qr-request-ratified-revision-s4` learning records that the very same confusion appeared in pg-writer's first pass and was caught + corrected via threads #4 + #5 ("Actor rename **Merchant→Client** applied"). The lesson was already in the vault; I did not retrieve it before authoring.

**Domain model (correct):**
- `merchant` = API integrator / account-holder. Owns no wallet. Configures clients, receives callbacks.
- `client` = downstream entity registered by the merchant (e.g. `AKPAY-BK001`). Owns the wallet whose balance moves on every deposit / payout / settlement.
- `partner` = MDR-fee recipient with own wallet.

**Root cause of my error:** I sampled `wallets_change_logs` first, saw "MDR fee distribution from deposit" rows, and mentally generalized "deposits credit a wallet" without verifying which `owner_type` was the *primary* credit target vs the MDR-distribution targets. I conflated MDR partner-wallet writes (which I sampled) with the deposit-direct credit (which I never sampled the owner_type of).

**Lesson — to fold into workflow-1-author-requirement.md "Anti-patterns":** When a story claims "X's wallet/balance/state is updated", verify *which* `owner_type` (or analogous discriminator) by:
- a Mongo count: `db.wallets.aggregate([{$group: {_id: "$owner_type", n: {$sum: 1}}}])` — confirms which owner_types even exist.
- a code line read on the function that does the update — its filter spec is authoritative.
- a search of pg-writer/bot-writer drift learnings for "wallet" + the relevant flow slug — past actor-naming corrections often live there.
Reverse-engineering from a change-log collection alone (e.g. `wallets_change_logs`) is misleading: secondary effects (MDR distribution to partners) can outnumber the primary effect (client credit) and skew the inferred shape.

**Fix shipped:** PR #28 commit `bced2c0` corrects 5 spots in `epic-deposit.md`, 2 entries in `glossary.md`, 1 line in `INDEX.md`, 1 row in `README.md`. Adds a new acceptance criterion to DEPOSIT-002 pinning the rollback-on-wallet-failure semantic so the next-system §ADR-3 atomic boundary structurally closes the documented #current drift. All files still ≤ 250 lines.

Future writers — load this learning before authoring any wallet-touching story.

---
*Added via Oracle Learn*
