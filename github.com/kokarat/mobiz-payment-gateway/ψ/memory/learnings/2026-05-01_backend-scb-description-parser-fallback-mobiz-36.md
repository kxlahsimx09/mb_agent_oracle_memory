---
title: Backend SCB description parser fallback (mobiz #365, 063983c, 2026-05-02). Archi
tags: [technical-writer, repo:mobiz-payment-gateway, repo:cross, current, bank-statements, self-healing-fallback, scb-parser, architectural-decision]
created: 2026-05-01
source: services/bankStatementParser.go:1-57@063983c + controllers/BotConfigController.go:729-744@063983c
project: github.com/kokarat/mobiz-payment-gateway
---

# Backend SCB description parser fallback (mobiz #365, 063983c, 2026-05-02). Archi

Backend SCB description parser fallback (mobiz #365, 063983c, 2026-05-02). Architectural decision: bank-bot repo is shared with other deployments and not modifiable from this codebase, so when production scan on 2 พ.ค. 2026 found inbound SCB rows arriving with empty source_bank_code (bot's regex only handles verb รับโอนจาก, real statements occasionally render รับเงินจาก), the fix lands at controllers/BotConfigController.go:729-744 inside the bulk-save handler — backend-side self-healing. New services/bankStatementParser.go::ParseSourceFromSCBDescription regex-matches both verb forms with bank-code length 3-8 (KBANK / KKP / UOBT / LHBANK …) and masked account x+3-5 digits. Empty inputs → ("", "") so caller can leave the row alone. Pairing the parser fallback with the inline match_hash compute (#362) means rows with the alternate verb now (a) auto-match deposits, (b) carry match_hash searchable for V1 fraud detection. Companion script scripts/repair_missing_source_bank_code.go is idempotent, 500 rows/batch, for repair of pre-existing rows. The "fix at backend" pattern is the durable mode whenever the bot-side scraper has a parser gap that we cannot push upstream — the row is incomplete on arrival and the backend completes it before insert.

---
*Added via Oracle Learn*
