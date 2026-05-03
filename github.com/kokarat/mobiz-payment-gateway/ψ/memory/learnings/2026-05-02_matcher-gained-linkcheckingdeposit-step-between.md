---
title: Matcher gained `linkCheckingDeposit` step between bank-qualified passes (matchDe
tags: [technical-writer, repo:mobiz-payment-gateway, current, matcher, deposit, checking-deposit, linkCheckingDeposit, v1-fraud, slipMatchHash]
created: 2026-05-02
source: services/transactionMatcher.go:108-130,340-475@20b6fa3
project: github.com/kokarat/mobiz-payment-gateway
---

# Matcher gained `linkCheckingDeposit` step between bank-qualified passes (matchDe

Matcher gained `linkCheckingDeposit` step between bank-qualified passes (matchDepositKTB/SCB) and the `linkPaidDeposit` fallback at `20b6fa3` (#384, 2026-05-03). The new step is wired only into the deposit cascade in `services/transactionMatcher.go::matchDeposit`. Scopes candidates by `system_bank_account_number + amount + status="checking" + is_matched != true`; filters by source-identity overlap on the statement's full-account regex `(\d{3})-(\d{7,15})` (priority 2) or last4 fallback from `[xX](\d{4})` / `SourceAccountNo` tail (priority 1); ties broken by minimum minute-delta between `stmt.TransactionDateBKK` and `dep.CreatedDateBKK / 100`. Refuses to act when no source identity can be extracted (returns false rather than guessing). Writes `bank_statements.match_status="matched" + matched_request_id` only — wallet, callback, and `deposit.status` are untouched (admin still approves). Pre-#384 a slip-uploaded deposit moving to `status=checking` was invisible to `matchDepositKTB/SCB` (they filter `status=pending`), so a fresh statement fell through to `linkPaidDeposit` and silently attached to the OLDEST `status=paid` deposit of the same dest+amount+lock-4 — the V1 fraud hash check at admin-approve time then resolved the slip to the wrong statement and blocked the legitimate approval ("สลิปนี้ถูกใช้กับรายการ ... ไปแล้ว"). Reproduced on DEP17777364940AC8L3 + DEP1777733674IBGAQO on 2 พ.ค. 2026; the fix prevents NEW occurrences only. The pre-existing rule that `status=checking` deposits are excluded from auto-approval (#185) still holds — the new step is purely a statement-linking layer that resolves the cross-reference so admin approval works correctly.

---
*Added via Oracle Learn*
