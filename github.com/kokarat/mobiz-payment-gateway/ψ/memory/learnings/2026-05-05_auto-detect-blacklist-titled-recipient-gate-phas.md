---
title: Auto-detect blacklist (titled-recipient gate, Phase-1 passive). New `services/bl
tags: [technical-writer, repo:mobiz-payment-gateway, current, blacklist, auto-detect, deposit, payout, fraud-prevention, phase-1-passive, thai-honorific]
created: 2026-05-05
source: services/blacklistAutoDetect.go:1-317@7c8033b, models/blacklist.go:1-45@7c8033b, controllers/BotConfigController.go:818-826@7c8033b
project: github.com/kokarat/mobiz-payment-gateway
---

# Auto-detect blacklist (titled-recipient gate, Phase-1 passive). New `services/bl

Auto-detect blacklist (titled-recipient gate, Phase-1 passive). New `services/blacklistAutoDetect.go` + `models/blacklist.go` (commit `7c8033b` PR #401, 2026-05-05) populate a new `blacklists` collection with counter-party accounts whose recipient names match Thai-honorific patterns (พระ/สามเณร/เด็กชาย/เด็กหญิง/ทหาร/ตำรวจ/นาวี). `AutoBlacklistTitled(accountNumber)` runs in a goroutine fired from `BotConfigController.SaveBankStatements` (line 818-826) AFTER the bulk insert returns — 0 ms hot-path latency, ~10–50 ms goroutine cost. Both directions scanned: `direction=out` rows pull recipient from `ts_payouts.dest_bank_*`; `direction=in` rows pull sender from `ts_deposits.custom_bank_*`. Same row upserts on either side; `detected_in []string` ($addToSet) is the audit trail of every direction the account has been seen on; `blocks []string` (default `["deposit","payout"]`, $setOnInsert) is what the runtime gate would consult. `IsBlacklisted(ctx, bankCode, accountNumber, direction)` is defined but **not called from any controller at HEAD** — Phase 1 is passive collection until the list accumulates from production traffic. Wire-instructions in commit body: re-add the call right after `ValidateAmount` in `PayoutRequestController.CreatePayout` and the equivalent in `DepositRequestController` to enable the gate. `$setOnInsert` protects manual `status: "inactive"` decisions from auto-revert. Eight categories + `other`. Schema in `models/blacklist.go`. Sister script `scripts/seed_titled_blacklist.go` is initial seeder + idempotent weekly cron (sweeps ts_payouts ~83K + ts_deposits, mergeDirectionRows coalesces hits into one row per account with full directions array).

---
*Added via Oracle Learn*
