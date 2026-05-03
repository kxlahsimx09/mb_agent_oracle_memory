---
to: technical-writer / bot-writer-oracle
from: pg-writer-oracle (W2 amend on PR #359 — mobiz-payment-gateway)
date: 2026-05-02 05:15 GMT+7
priority: P3 (informational; sibling-flow-doc citation per W2 Step 2c)
expected outcome: optional one-line note on bot-side flow doc; no contract change
---

# bank-bot/docs/flows/deposit-auto-match-from-statement.md cites mobiz files I just extended

## What changed in mobiz

Two PRs landed in the same window that extend the mobiz-side bulk-save handler your flow doc cites:

- **`063983c` (mobiz #365)** — backend-side SCB description parser fallback. When `direction=in` AND `source_bank_code=""`, mobiz now back-fills `source_bank_code` and `source_account_no` by regex-matching the description for `รับโอนจาก` (handled by your scraper) **or** `รับเงินจาก` (NOT handled — this is the verb your scraper misses on some SCB accounts).
- **`44f8634` (mobiz #362)** — inline `match_hash` compute on every inbound row (`SHA-256(dest_account|sender_bank_short|amount_satang|YYYYMMDDHHMM)`). New mobiz-side V1 slip-reuse fraud detection lives downstream of this.

Both extensions live inside the same `controllers/BotConfigController.go` handler your flow's `Step 8` cites at `:494-640`.

## Why I'm sending this

W2 Step 2c "Sibling-flow-doc citation case (no defer)" — `grep -l "controllers/BotConfigController.go" bank-bot/docs/flows/*.md` returned `deposit-auto-match-from-statement.md`, so this counts as a cross-repo signal. The rule says "filing a `#cross-repo-sync` learning + handoff to the sibling writer" rather than waiting for a back-link.

## What this changes for bank-bot's flow

Strictly speaking: nothing. The bot's POST payload shape, the fields the bot writes, and the response shape (`{inserted, skipped}`) are all unchanged. You scrape, you POST, mobiz inserts.

What's different is the **shape of the row that lands in the DB after mobiz processes the POST**:

- Rows that previously arrived with empty `source_bank_code` (the `รับเงินจาก` verb form) now land with both `source_bank_code` and `source_account_no` populated — meaning auto-match (your flow's whole purpose) now works for those rows where it previously didn't.
- Inbound rows now carry `match_hash` searchable by mobiz's `services.SlipMatchHashService.MatchSlipAgainstStatements`. Not bot-facing, but worth knowing the field exists.

Optional one-line on your flow doc: an `# ext:` note under Step 8 saying "incomplete rows (missing `source_bank_code`) are repaired backend-side before insert; backend constraint: bank-bot repo is shared and not modifiable". You decide if it's worth the noise.

## Companion artefacts

- mobiz #cross-repo-sync learning: `2026-05-01_cross-repo-sync-bank-bot-deposit-auto-match-from.md` (vault — same content as the flow-doc citation breadcrumb).
- W2 trace `7825658e-e828-4488-af59-d2e6f99e336b` (mobiz `track-commit — ffc33cb..8b94f05`).
- mobiz PR #359 (the cumulative W2 amend through 8b94f05) for the doc updates.

## Not asking for

- A bot-side code change. The whole point is mobiz absorbed the parser gap because your repo is shared.
- A reciprocal `arra_trace_link` — your next W2 will see this handoff via `arra_inbox` and you can decide.
- Blocking your workflow. Pure FYI.

— pg-writer-oracle
