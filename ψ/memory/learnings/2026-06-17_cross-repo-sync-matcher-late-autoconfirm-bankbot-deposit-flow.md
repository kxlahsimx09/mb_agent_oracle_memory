---
title: cross-repo-sync — matcher late-statement auto-confirm (#530) extends bank-bot deposit-auto-match flow contract
tags:
  - technical-writer
  - repo:cross
  - current
  - deposit
  - bank-bot
  - cross-repo-sync
created: 2026-06-17
source: services/transactionMatcher.go finalizeCheckingDeposit @ e1964b8 (mobiz) ↔ bank-bot/docs/flows/deposit-auto-match-from-statement.md:105
related:
  - 2026-06-17_drift-19-slip-fraud-late-autoconfirm
project: github.com/kokarat/mobiz-payment-gateway
---

# cross-repo-sync — mobiz matcher #530 affects bank-bot deposit-auto-match flow doc

Triggered by W2 Step 2c §Sibling-flow-doc citation case (no-defer branch): a mobiz file changed this range is cited in a bank-bot flow doc.

- **Citation:** `bank-bot/docs/flows/deposit-auto-match-from-statement.md:105` cites mobiz `services/transactionMatcher.go:1126` (`MatchNewStatements`) and states the contract: *"A pending `ts_deposits` row matching the statement will be flipped to `paid` + wallet-credited + callback-fired within seconds of the bot's POST."*
- **What changed (mobiz `e1964b8` #530, 2026-06-15):** that contract now also covers **`checking`-status** deposits. New `finalizeCheckingDeposit` auto-confirms a `checking` deposit (one that escalated because no statement landed within `slip_review_timeout_minutes`) to `paid` when a late statement matches — single-candidate only, with fraud-guard CAS (`!is_matched`, no `slip_duplicate_of`, `slip_dest_status!="mismatch"`). The matcher was also refactored (`finalizeDeposit`→`finalizeDepositFrom`), so the cited `transactionMatcher.go:1126` line pointer has likely shifted.

**Action for bot-writer (handoff filed in ψ/inbox/handoff/):** update `deposit-auto-match-from-statement.md` to note that late statements now auto-confirm matched `checking` deposits (not just `pending`), and refresh the `MatchNewStatements` line pointer. Mobiz side does not edit bank-bot docs (cross-repo ownership rule, AGENTS.md §5a).

No bot-facing API contract (`/api/v1/bot/**`, OTP-log POST, statement-report/balance-update JSON shapes) changed in this range — only the downstream matcher behavior the bot's reported statements feed into.
