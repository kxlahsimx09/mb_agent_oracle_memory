---
title: W1 twenty-seventh pass (amend of PR #506) — #509 + #505 NEUTRAL across the 49-te
tags: [tester, repo:mobiz-payment-gateway, current, w1, no-op, wallet-log, payout, bank-account, w1-twenty-seventh-baseline]
created: 2026-06-01
source: controllers/BankAccountController.go::UpdateBankAccount@88506f3 + controllers/PayoutController.go + PayoutRequestController.go + WalletChangeLogController.go@a9a3acb + docs/test-index.md (PR #506 amend, twenty-seventh pass)
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 twenty-seventh pass (amend of PR #506) — #509 + #505 NEUTRAL across the 49-te

W1 twenty-seventh pass (amend of PR #506) — #509 + #505 NEUTRAL across the 49-test suite, 0 status flips

Extended the open tester-validate PR #506 from baseline bf57c0e -> a9a3acb, absorbing TWO new production-surface commits (range bf57c0e..a9a3acb). Both classified NEUTRAL after static analysis; cumulative range now a011daf..a9a3acb (11 production-surface commits over the twenty-sixth + twenty-seventh passes). Suite unchanged: 44 VALID / 1 STALE / 0 WRONG-SETUP / 0 FLAKY / 2 SUPERSEDED / 2 ON_HOLD / 0 UNKNOWN. VALID rows' last-verified bumped bf57c0e->a9a3acb (44 rows).

#509 88506f3 feat(bank-account): admin can edit any account. controllers/BankAccountController.go::UpdateBankAccount gains an isAdmin (user_type=="admin") branch that bypasses 2FA + the owner-match check + the pending-only-status guard, so super_admin can fix approved/rejected accounts; owner-side (partner/client/sub-client) semantics are byte-for-byte unchanged (the purpose/duplicate checks now read owner_type/owner_id off the account doc instead of the caller, so the same code runs for both). Test impact = none: grep -rnE "bank-account|/api/v1/bank-accounts" integration-tests/test-*.sh returns only pools.bank_accounts (the pool-linking payload, a different field). No integration test exercises the /api/v1/bank-accounts update surface at all. New untested surface -> 🟢 coverage-gap row appended.

#505 a9a3acb fix(wallet-log): consistent entity for payout refund + OR-match in list. Two-part diff, controllers-only (no services/ touched): (A) 3 payout-refund write sites — PayoutController.go::UpdatePayoutStatus ~939, ::CancelPayout ~1175, PayoutRequestController.go::CancelPayout ~754 — flip the wallets_change_logs entity from entity_type=client/entity_id=clientID to entity_type=wallet/entity_id=wallet._id (EntityName falls back to payout.ClientName for legacy wallets). operation, reference_type, reference_id, amount, balance_before/after are ALL unchanged. (B) WalletChangeLogController.go list endpoints (GetAllWalletChangeLogs + buildEntityLogFilter via extracted resolveWalletEntityIDs) now $in-match entity_id across {wallet._id, owner_id}, and a new resolveSearchToReferenceID maps PAY/DEP/TOP/STL search strings to the indexed reference_id — both read-path only.

Why NEUTRAL: the only tests that assert on wallets_change_logs are (1) test-payout-admin-cancel.sh — counts by reference_type='payout' + reference_id + operation='add' (the three fields #505 leaves untouched); (2) test-payout-auto-reconcile.sh + test-payout-confirm-completed.sh — both ON_HOLD, and they assert operation:'payout_refund' written by the processPostCompletion goroutine in services/withdrawalQueue.go, which #505 does NOT modify (the diff is controllers-only); (3) test-deposit-refund.sh — deposit path (operation deposit_refund_debit), untouched. None asserts on the changed entity_type/entity_id. SUPERSEDED test-payout-cancel.sh relates to client-cancel (PayoutRequestController) but no longer asserts. So 0 flips. The entity-consistency fix itself is unverified by any test -> 🟢 coverage-gap row appended.

Telegram (Step 7b) again could not send: mcp__tester-telegram__telegram_send is still not registered in this session (ToolSearch "tester-telegram telegram_send" -> no match) — same condition as the twenty-sixth pass. Filed separately under #telegram-failed; did not fall back to the writer-fleet generic telegram MCP, did not block the pass.

Related: 2026-06-01_telegram-failed-w1-twenty-sixth-pass-step-7b-cou (prior pass, same Telegram condition + the 9-commit a011daf..bf57c0e NEUTRAL determination this pass builds on).

---
*Added via Oracle Learn*
