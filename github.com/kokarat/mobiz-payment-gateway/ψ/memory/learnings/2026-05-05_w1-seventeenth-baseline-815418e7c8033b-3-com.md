---
title: W1 seventeenth baseline (`815418e..7c8033b`, 3 commits) — NEUTRAL across 48 test
tags: [tester, repo:mobiz-payment-gateway, current, w1-seventeenth-baseline, validate, no-op-pass]
created: 2026-05-05
source: docs/test-index.md@7c8033b + git log 815418e..7c8033b -- controllers/ services/ models/ routes/ scheduler/ helpers/ db/ main.go
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 seventeenth baseline (`815418e..7c8033b`, 3 commits) — NEUTRAL across 48 test

W1 seventeenth baseline (`815418e..7c8033b`, 3 commits) — NEUTRAL across 48 tests; 0 status flips. Fresh PR cycle (prior PR #397 merged 2026-05-05 at `142dfcc`).

Range commits:
- `cd48052` PR #404 — Payout cancel reason validation (5–500 chars). Co-modified `test-payout-admin-cancel.sh:515` to pad Phase 4 not-found probe with valid notes; all four `/cancel` call sites in that test (lines 311 / 399 / 469 / 515) already pass the new gate. Test stays VALID.
- `3727378` PR #403 — `WithdrawalQueueController.GetBanks` aggregation `$match` scoped to `status: {$in: [pending, processing]}` + 30s Redis cache wrap. Same endpoint as PR #391 finding from prior pass — zero tests call `/api/v1/withdrawal-queue/banks`.
- `7c8033b` PR #401 — Auto-detect blacklist Phase 1 (passive collection, both directions). New `services/blacklistAutoDetect.go` (+316), `models/blacklist.go` (+45), `scripts/seed_titled_blacklist.go` (+392), wired into `BotConfigController.SaveBankTransactions:827` as goroutine. `IsBlacklisted` lookup helper exists but is NOT called from any controller (Phase 1 = passive collection per commit body). Hot-path latency unchanged (0ms blocking). Zero tests use Thai-honorific recipient names; goroutine fires with no observable effect under English/ASCII test data.

New coverage gaps appended (3): 🟡 blacklist auto-detect regression tripwire (escalated 🟢→🟡 because Phase 2 gate-wiring transition has zero regression coverage and a regex misclassification is a customer-impact path); 🟢 `PayoutController.CancelPayout` reason validation (rejection paths uncovered — happy path exercised, but empty/short/501-char/non-JSON-body paths are not asserted); 🟢 `/withdrawal-queue/banks` excludes inactive-status rows (adjacent to existing PR #391 NilObjectID-orphan gap on same endpoint — fold into shared regression-tripwire when test architecture is approved).

Memory-discipline notes: prior pass (W1 sixteenth baseline, trace `711291cb-f9e3-4cfc-8fea-8492b29d6ae9`) was a sixth-pass amend extending PR #397 — that PR is now merged so this seventeenth pass switches back to the new-PR path (Step 7.B). Tester-validate cadence preserved; vault frontmatter health check passed pre-commit (`✅ no double-wrap + ✅ every indexed doc has a title:`).

Carry-forward: 11 pending Oracle threads outstanding (none mine to close); 2 ON_HOLD tests (`test-payout-confirm-completed.sh`, `test-payout-auto-reconcile.sh`) still pending Oracle thread #2 MarkFailed-callback redesign; 1 STALE (`test-settlement-cancel.sh` — recommended retarget to `/reject` still awaiting owner sign-off).

---
*Added via Oracle Learn*
