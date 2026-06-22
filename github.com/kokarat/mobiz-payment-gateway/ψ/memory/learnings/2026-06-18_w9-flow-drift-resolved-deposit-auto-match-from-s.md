---
title: W9 flow-drift RESOLVED — deposit-auto-match-from-statement finalize wallet-credi
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow-drift, flow:deposit-auto-match-from-statement, deposit, wallet, financial, workflow-9, drift-resolved]
created: 2026-06-18
source: docs/flows/deposit-auto-match-from-statement.md; services/transactionMatcher.go:829-896@caa7631
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 flow-drift RESOLVED — deposit-auto-match-from-statement finalize wallet-credi

W9 flow-drift RESOLVED — deposit-auto-match-from-statement finalize wallet-credit atomicity (caa7631 #551, 2026-06-19). The long-documented §Error-paths / §Resolved-question-(a) drift on this flow — pre-fix finalizeDeposit flipped ts_deposits.status→"paid" then credited the client wallet as SEPARATE best-effort writes, so a wallet-credit failure left the deposit paid-but-uncredited (and, since MDR ran after, partners-paid-but-client-uncredited) — is now RESOLVED at HEAD. caa7631 wraps the flip AND the client-wallet credit + wallets_change_logs insert in ONE MongoDB transaction (finalizeDepositFrom → sess.WithTransaction at services/transactionMatcher.go:829@caa7631); a failed credit returns an error so the flip rolls back (:867@caa7631) and the matcher retries next tick. MDR distribution stays OUTSIDE the transaction by design (:896@caa7631 — it touches the shared Owner-MDR wallet on every deposit, so transacting it would serialise all matches; MDR is idempotent/self-heal), and because client credit is now the gating commit the partners-first inversion is closed too. The ~13 historically-affected deposits were data-remediated by scripts/backfill_missing_client_credit.go (8a413c6 #550). W9 action: annotated the §Error-paths [DRIFT] as [DRIFT-(a) RESOLVED via caa7631] (Step 4b in-range-fix-closes-documented-drift; P-001 keeps original text, P-004 corrects tense). Supersedes drift-discovery 2026-04-19_drift-deposit-auto-match-finalizedeposit-does-no (thread #17 Q4a / W4 queue item). The §Step-7 pointers still cite the pre-caa7631 finalizeDeposit line layout — their A/B refresh stays in the owed over-threshold W8 revision; this records the behavioural resolution only. PR #545 (W9 8.A amend); flows-baseline HELD @9aebabb.

---
*Added via Oracle Learn*
