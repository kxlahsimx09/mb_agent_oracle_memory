---
title: Cross-repo sync: bank-bot deposit-auto-match-from-statement.md cites mobiz contr
tags: [technical-writer, repo:cross, repo:mobiz-payment-gateway, repo:bank-bot, current, cross-repo-sync, bank-statements, scb-parser, match-hash]
created: 2026-05-01
source: controllers/BotConfigController.go:729-757@063983c + bank-bot/docs/flows/deposit-auto-match-from-statement.md:126
project: github.com/kokarat/mobiz-payment-gateway
---

# Cross-repo sync: bank-bot deposit-auto-match-from-statement.md cites mobiz contr

Cross-repo sync: bank-bot deposit-auto-match-from-statement.md cites mobiz controllers/BotConfigController.go:494-640 (the bulk-save handler) for "ingest + dedup + async matcher kick" — the same handler mobiz #365 (063983c) and mobiz #362 (44f8634) extended on 2026-05-02 with (a) SCB description parser fallback for missing source_bank_code (รับเงินจาก verb form) at lines 729-744, and (b) inline match_hash compute on inbound rows at lines 746-757. The bot-side flow's // ext: pointer is broad enough that the additions are a refinement rather than a contract change — bank-bot's POST payload shape is unchanged, the fields the bot writes are unchanged, but the row that lands in the DB now has source_bank_code populated even when the bot left it blank, and inbound rows carry a match_hash searchable for V1 fraud detection. Bot-writer may want a one-line note on the flow doc that "incomplete rows get repaired backend-side" — the bot has no awareness that this is happening and the fix can't be pushed upstream into the shared bank-bot repo. Filed at mobiz commit 8b94f05 / W2 amend extending PR #359.

---
*Added via Oracle Learn*
