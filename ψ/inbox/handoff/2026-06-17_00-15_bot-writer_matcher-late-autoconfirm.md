---
title: handoff → bot-writer — mobiz matcher #530 extends the deposit-auto-match contract your flow doc cites
to: bot-writer-oracle
from: pg-writer-oracle
priority: P2
tags:
  - technical-writer
  - repo:cross
  - current
  - deposit
  - bank-bot
  - cross-repo-sync
  - handoff
created: 2026-06-17
project: github.com/kokarat/bank-bot
related:
  - 2026-06-17_cross-repo-sync-matcher-late-autoconfirm-bankbot-deposit-flow
---

# Handoff to bot-writer — refresh `deposit-auto-match-from-statement.md` for mobiz matcher #530

Filed by pg-writer during the 2026-06-17 mobiz W2 pass (Step 2c, sibling-flow-doc-citation, no-defer branch). Fire-and-forget — your pass does not block on mine.

**Sibling flow doc to revise:** `bank-bot/docs/flows/deposit-auto-match-from-statement.md`

**The citation that fired:** line ~105 cites mobiz `services/transactionMatcher.go:1126` (`MatchNewStatements`) with the contract: *"A pending `ts_deposits` row matching the statement will be flipped to `paid` + wallet-credited + callback-fired within seconds of the bot's POST."*

**Mobiz fix commit:** `e1964b8` #530 "Auto-confirm checking deposits when a matching statement arrives late" (2026-06-15).

**Expected semantic change to document:**
1. The "flipped to paid" contract now also covers **`checking`-status** deposits, not just `pending`. New `finalizeCheckingDeposit` auto-confirms a `checking` deposit (one that escalated because no statement landed within `slip_review_timeout_minutes`) to `paid` when a late statement matches — **single-candidate only** (`len(pool)==1`), with fraud-guard CAS (`is_matched!=true`, no `slip_duplicate_of`, `slip_dest_status!="mismatch"`). Multi-candidate stays link-only for admin review.
2. The matcher was refactored (`finalizeDeposit` → `finalizeDepositFrom`), so the cited line pointer `transactionMatcher.go:1126` for `MatchNewStatements` has likely **shifted** — refresh the `// impl:` pointer.

**No bot-facing API contract changed** (`/api/v1/bot/**`, OTP-log POST, statement-report/balance-update JSON shapes are untouched) — this is downstream matcher behavior only. Cross-repo ownership rule (AGENTS.md §5a): pg-writer does not edit bank-bot docs; this handoff is the forcing function.
