# Handoff to bot-writer — transactionMatcher payment_details.transaction_date semantic change

**From:** pg-writer W2 pass 2026-04-27  
**To:** bot-writer-oracle (kokarat/bank-bot)  
**Priority:** P2 — doc accuracy; not blocking

## What changed

Mobiz commit `b31866f` (PR #317) changed how `finalizeDeposit` in `services/transactionMatcher.go:586-609` sets `payment_details.transaction_date`:

- **Before:** `stmtTime = stmt.ScrapedAt.Time()` — the moment the bot's scrape landed in Mongo
- **After:** `stmtTime = helpers.TimeFromDateTimeBKKInt(stmt.TransactionDateBKK)` — bank's own reported minute-resolution time (YYYYMMDDHHMM int); falls back to ScrapedAt only when TransactionDateBKK = 0

This means `payment_details.transaction_date` now reflects when the customer actually transferred the money, not when the bot scraped it.

## What needs updating in your repo

**File:** `kokarat/bank-bot/docs/flows/deposit-auto-match-from-statement.md`  
**Section:** §Postconditions (the mobiz-side paragraph that cites `services/transactionMatcher.go:1126`)

The existing sentence "A pending `ts_deposits` row matching the statement will be flipped to `paid` + wallet-credited + callback-fired within seconds of the bot's POST" is still accurate. But a follow-up note should be added:

> `payment_details.transaction_date` is now set to the bank's reported transfer time (reconstructed from `transaction_date_bkk`), not the scrape timestamp. The deposit admin badge's "โอน vs Match" gap now shows real latency (typically 30-90s). Fallback to ScrapedAt when `transaction_date_bkk = 0`.

## Cross-repo signal

Your flow doc cites `services/transactionMatcher.go:1126`. That line (MatchNewStatements trigger) is unchanged. The semantic change is in `finalizeDeposit` (L586). The flow doc's §Implementation pointers Step 7 already lists `transaction_date_bkk` as a field in the bot's POST body — adding this annotation closes the loop on what mobiz does with that field.

## W2 trace

pg-writer W2 trace: `a4f2d137-01ce-46ba-9fcd-4069d35a1057`

No action required from pg-writer. Pick up on your next W9/W8 pass.