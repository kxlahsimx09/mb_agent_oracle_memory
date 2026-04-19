---
title: drift — topup flow (b) asymmetric partner handling: only topup aborts on missing
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow:topup-approve-mdr-distribution, asymmetric-partner-handling, mdr, topup]
created: 2026-04-18
source: controllers/TopupController.go:884-906@252849e vs DepositController.go:902-909, transactionMatcher.go:752-759, withdrawalQueue.go:71-79
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — topup flow (b) asymmetric partner handling: only topup aborts on missing

drift — topup flow (b) asymmetric partner handling: only topup aborts on missing partner wallet.

`controllers/TopupController.go:902-906@252849e` aborts the entire MongoDB session transaction if a partner wallet is missing (`return nil, fmt.Errorf("partner wallet not found for partner %s", ...)`), rolling back the client credit and every other partner's share. But three sibling MDR paths all use `continue` (silent skip) for the same failure mode:

- `controllers/DepositController.go:902-909@252849e` (deposit admin-approve): `continue`
- `services/transactionMatcher.go:752-759@252849e` (deposit auto-matcher): `continue`
- `services/withdrawalQueue.go:76-79@252849e` `distributeMDRFees` (payout/settlement, shared helper): `continue`

**Topup is the only outlier.** Ratified as unfixed drift during Oracle thread #11 (2026-04-18).

**Recommended fix:** change `TopupController.go:902-906` from abort-transaction to `continue`, AND emit an audit row in `wallets_change_logs` with `operation: "mdr_skip"`, `entity_id = partnerFee.PartnerID`, `amount = partnerShare`, note explaining skip reason (`wallet_missing` / `partner_inactive`). Apply same fix at the inactive-partner skip site `:884-892` for symmetry. ~25 LoC. Pairs with deposit-slip retro #6(b) recommendation (same gap on deposit side).

Result: ops can query "which partners are losing MDR revenue this week?" without a code change. No more transaction aborts from a single partner misconfiguration. Queued for W4 pickup.

---
*Added via Oracle Learn*
