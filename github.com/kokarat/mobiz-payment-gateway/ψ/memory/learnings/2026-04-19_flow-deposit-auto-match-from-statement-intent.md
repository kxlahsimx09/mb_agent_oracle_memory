---
title: flow — deposit-auto-match-from-statement — intent at a glance.
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, deposit-auto-match-from-statement, reverse-engineered, ratification-pending, deposit, bank-statement, matcher, mdr, callback, bank-bot]
created: 2026-04-19
source: docs/flows/deposit-auto-match-from-statement.md@37dfb26
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — deposit-auto-match-from-statement — intent at a glance.

flow — deposit-auto-match-from-statement — intent at a glance.

Actor-visible contract: one client API call (`POST /api/v1/deposit-request`) eventually produces one client callback (`status="completed"`) with zero additional client API calls in between. The Gateway's job in the gap is ingest + dedup of BankBot-scraped statement rows, bank-specific description parsing (KTB full-account or SCB last4 + source bank code), and an atomic commit that flips `ts_deposits → paid`, credits the client wallet net of MDR, fans MDR shares to partner wallets, logs every balance movement in `wallets_change_logs`, records a `transactions` row, snapshots the distribution into `mdr_shared`, and fires the completion callback.

Three matcher triggers converge on the same `matchDeposit → finalizeDeposit` pipeline:
- BankBot-initiated async kick (primary path, drawn in the mermaid diagram)
- 30-second retry ticker (`MatcherScheduler` — one hour look-back on `match_status ∈ {pending, unmatched}`)
- Admin manual re-match (`POST /api/v1/bank-statements/match`)

This flow is the zoom-in on `deposit-qr-request.md` Step 7 and is sibling to `deposit-slip-upload-admin-approve.md` (the admin-assisted alternative when auto-match cannot confirm).

Ratification thread: #17 (folds Q1 actor-contract, Q2 scope-boundary, Q3 single-trigger diagram, and Q4a–Q4d open questions into one human-facing message per precedent threads #6 / #8 / #11 / #13). Claim strength S4 until ratified.

W8 root trace: b9e04355-1599-4bfb-b001-ac7697e9586b.

---
*Added via Oracle Learn*
