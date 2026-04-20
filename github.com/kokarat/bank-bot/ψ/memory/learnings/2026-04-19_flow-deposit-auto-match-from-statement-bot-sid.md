---
title: flow — deposit-auto-match-from-statement — bot-side intent at a glance.
tags: [technical-writer, repo:bank-bot, current, flow, flow:deposit-auto-match-from-statement, scb, ktb, statement, playwright, cursor, reverse-engineered, ratification-pending]
created: 2026-04-19
source: docs/flows/deposit-auto-match-from-statement.md@5755b9a (bank-bot); mobiz sibling at 212f36c
project: github.com/kokarat/bank-bot
---

# flow — deposit-auto-match-from-statement — bot-side intent at a glance.

flow — deposit-auto-match-from-statement — bot-side intent at a glance.

Purpose: BankBot runs a long-lived scraper (Viewer loop every 30s, or idle branch of main poll, or post-batch of maker/approver/transfer) that watches one bank account's statement page on SCB Business Anywhere or KTB Business, normalizes rows into a shared JSON shape, and POSTs them to mobiz-payment-gateway so the matcher can pin statements to pending deposits. Bot owns the scrape + normalize + POST; mobiz owns dedup + match + finalize + callback. Bot-side contract has two correctness guarantees: (a) preserve the portal's raw description verbatim in `description` / `raw_text` so the matcher's KTB full-account regex (`NNN-NNNNNNN`) or SCB last4 + source-bank regex can extract; (b) direction-aware cursor via `core/cursor.js` so withdrawals at 08:15 do not mask unscraped deposits at 07:36.

Mode: reverse-engineered at bank-bot 5755b9a (this pass); ratification pending via thread #20. Mobiz sibling doc `docs/flows/deposit-auto-match-from-statement.md@212f36c` ratified via mobiz thread #17 on 2026-04-19.

Loop-wrapped mermaid form chosen (first bot-side use; prior `scb-dual-control-withdrawal` used linear). Decomposition asymmetry: mobiz's three bot-owned crossings (its steps 1, 2, 3) unpack to 10 bot steps inside an outer `loop Every POLL_INTERVAL` container with an inner `alt rows found / else no new rows` branch.

Source files: banks/scb/statement.js, banks/ktb/statement.js (REST API primary + UI fallback), banks/ktb/index.js (scrapeStatement orchestration + KTB_SESSION_DEAD sentinel), core/api.js (getLastStatementDate + saveBankStatements + updateBalance), core/cursor.js (direction-aware cursor + day-boundary reset), app.js (scrapeStatementSafe + viewer loop + idle branch + single-transfer path).

Endpoints bot calls: GET /api/v1/bot/bank-statements/last/:account_number (cursor read), POST /api/v1/bot/bank-statements (ingest batch), PUT /api/v1/bot/balance (balance snapshot every tick).

Bot W8 trace: 1cfc65ab-7964-4872-9c46-d3edb0c903f4. Mobiz W8 trace: b9e04355-1599-4bfb-b001-ac7697e9586b.

---
*Added via Oracle Learn*
