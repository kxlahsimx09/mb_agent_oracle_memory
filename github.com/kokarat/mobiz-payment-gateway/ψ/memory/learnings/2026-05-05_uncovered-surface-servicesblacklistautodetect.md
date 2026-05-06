---
title: Uncovered surface — `services/blacklistAutoDetect.go` + `models/blacklist.go` + 
tags: [technical-writer, repo:mobiz-payment-gateway, current, w8-handoff, uncovered-surface, flow:blacklist-auto-detect-titled, blacklist, fraud-prevention, phase-1-passive]
created: 2026-05-05
source: services/blacklistAutoDetect.go:1-317@7c8033b, models/blacklist.go:1-45@7c8033b, controllers/BotConfigController.go:818-826@7c8033b
project: github.com/kokarat/mobiz-payment-gateway
---

# Uncovered surface — `services/blacklistAutoDetect.go` + `models/blacklist.go` + 

Uncovered surface — `services/blacklistAutoDetect.go` + `models/blacklist.go` + `scripts/seed_titled_blacklist.go` (`7c8033b` #401, 2026-05-05). New fraud-prevention service that scans `bank_statements` for Thai-honorific recipient/sender names and upserts into a new `blacklists` collection. Hot-path budget 0 ms (goroutine fired from `BotConfigController.SaveBankStatements:818-826`). Phase-1 passive at HEAD: `IsBlacklisted` defined but **not called** from any controller — gate intentionally absent until list accumulates from production traffic. Both directions: outgoing scan pulls recipient from `ts_payouts.dest_bank_*` (`direction=out`); incoming scan pulls sender from `ts_deposits.custom_bank_*` (`direction=in`). One row per `(bank_code, account_number)` with `detected_in []string` audit trail (`$addToSet`) and `blocks []string` (default `["deposit","payout"]`) controlling which directions the runtime gate would block. 8 categories + `other`. **Suggested W8 authoring slug: `blacklist-auto-detect-titled`** — actor-crossings worth diagramming: bot bulk-insert → goroutine fire → bank_statements query → ts_payouts/ts_deposits lookup → blacklists upsert. Sister flow when Phase 2 lands (gate enabled at `PayoutRequestController.CreatePayoutRequest` + `DepositRequestController`): `blacklist-rejection-at-request-creation`. Not class D (undocumented step in existing flow) per W9 spec — the goroutine fires inside SaveBankStatements which is cited by `deposit-auto-match-from-statement.md` and `deposit-qr-request.md`, but the new service's purpose (fraud-prevention scanning) is orthogonal to the cited flows' purpose (statement → deposit matching). The trigger event is shared; the narrative is independent. Hand off to W8 authoring as a fresh flow rather than fold into either existing flow's narrative.

---
*Added via Oracle Learn*
