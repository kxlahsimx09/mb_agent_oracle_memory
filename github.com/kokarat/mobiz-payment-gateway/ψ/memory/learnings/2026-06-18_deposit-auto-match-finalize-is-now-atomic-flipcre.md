---
title: Deposit auto-match finalize is now atomic flip+credit (caa7631 #551, 2026-06-19)
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, wallet, mdr, financial, workflow-2]
created: 2026-06-18
source: services/transactionMatcher.go:792-895@caa7631
project: github.com/kokarat/mobiz-payment-gateway
---

# Deposit auto-match finalize is now atomic flip+credit (caa7631 #551, 2026-06-19)

Deposit auto-match finalize is now atomic flip+credit (caa7631 #551, 2026-06-19) — financial. services/transactionMatcher.go finalizeDepositFrom wraps the deposit status-flip (→paid) AND the client-wallet credit ($inc balance+available via FindOneAndUpdate + the wallets_change_logs insert) in ONE MongoDB transaction (sess.WithTransaction). Previously the flip and the wallet $inc were separate best-effort writes, so a transient DB failure after the flip left the deposit paid but the client never credited — confirmed in prod: ~13 paid-but-uncredited deposits (e.g. DEP1781612366RIX4P8) plus ~131 with no MDR. Now either both commit or neither: a failed wallet credit returns an error so the flip rolls back and the matcher retries on its next tick. The atomic compare-and-set on status (+ any extraGuard) is still the race / double-credit guard — a row already moved by an admin or another statement returns MatchedCount==0 and the txn commits a no-op (raced=true), not an error. MDR distribution stays OUTSIDE the transaction on purpose: it touches the shared Owner-MDR wallet on every deposit, so transacting it would serialise all matches on one document; MDR is idempotent and re-distributable by a self-heal pass. The two historical gaps were data-remediated by one-off scripts backfill_missing_client_credit.go (8a413c6 #550) + backfill_mdr_missing_distribution.go (f0f5fb5 #549). Documented current-system.md §5 MatcherScheduler row (W2 PR #540); financial → CC code_reviewer.

---
*Added via Oracle Learn*
