---
title: Coverage gap (🟡 escalated): Auto-detect blacklist regression tripwire (Phase 1 
tags: [tester, repo:mobiz-payment-gateway, current, coverage-gap, blacklist, compliance, w1-seventeenth-baseline]
created: 2026-05-05
source: controllers/BotConfigController.go:827 + services/blacklistAutoDetect.go:115-287@7c8033b
project: github.com/kokarat/mobiz-payment-gateway
---

# Coverage gap (🟡 escalated): Auto-detect blacklist regression tripwire (Phase 1 

Coverage gap (🟡 escalated): Auto-detect blacklist regression tripwire (Phase 1 passive collection — PR #401 `7c8033b`, 2026-05-05).

What's missing: the entire `services.AutoBlacklistTitled` + `services.IsBlacklisted` surface plus the `blacklists` collection has zero integration coverage. `AutoBlacklistTitled` fires from `BotConfigController.SaveBankTransactions:827` in a goroutine after every `/api/v1/bot/save-bank-transactions` call, scans the last hour of `bank_statements` (both directions, 200-row cap), regex-matches counter-party names against the Thai-honorific title set (พระ monk, สามเณร samanera, เด็กชาย/หญิง minor, military/police/navy ranks ร.ต./ส.ต./ด.ต./พ.ต./น.อ., etc.), and upserts `(bank_code, account_number)` into the `blacklists` collection. `IsBlacklisted` exists at `services/blacklistAutoDetect.go:287` but is NOT yet called from any controller — Phase 1 = passive collection only per the commit body.

Why this matters: Phase 2 will wire `IsBlacklisted` into `PayoutRequestController.CreatePayoutRequest` and `DepositRequestController` for live rejection. At that transition, a regex misclassification becomes a direct customer-impact path — false negative blocks fail to fire on real titled recipients (compliance risk), false positives block legitimate payouts. The escalation 🟢→🟡 is justified by zero regression coverage at the gate-wiring transition + cleanup helper at `helpers/setup-infra.sh::setup_test_data` does NOT touch `blacklists` (state-pollution vector for any future test that triggers the goroutine with Thai-honorific names).

Test architecture: 6 phases — (1) Thai-honorific incoming → assert blacklists row within 2s with category populated + blocks=["deposit","payout"] + detected_in=["in"]; (2) Thai-honorific outgoing → second row + detected_in=["out"]; (3) re-scrape same statement → hit_count increments + last_seen updates + no duplicate (idempotent upsert via `$setOnInsert` + `$addToSet`); (4) admin sets `status="inactive"` → re-scrape → assert status stays inactive; (5) English/ASCII name → assert NO row created (`mightHaveTitle()` byte-sniff fast-rejects); (6) Phase-2-deferred — `IsBlacklisted` returns the row when (bank_code, account_number, direction) match AND row's `blocks` array contains the direction.

Impact if unfilled: Phase 2 ships and an unwitnessed regex regression silently rejects legitimate payouts OR fails to block titled recipients (compliance audit gap). Discovery only via customer complaint or post-incident audit.

Carry-forward: when Phase 2 lands (any commit that wires `IsBlacklisted` into a request handler — `grep` for callers), revisit this gap → may need promotion to 🔴 if the gate is hot-path with no fallback.

---
*Added via Oracle Learn*
