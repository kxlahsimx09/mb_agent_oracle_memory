---
title: fact — telegram hourly-report fixes (#526/#537) + Thunder defer on client upload-slip (#521/#522)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - telegram
  - scheduler
  - deposit
  - drift
created: 2026-06-17
source: scheduler/report_scheduler.go + db/indexes.go + controllers/DepositRequestController.go @ 03d6383
related:
  - 2026-04-15_drift-report-scheduler-disabled
  - 2026-05-22_drift-thunder-deferred-happy-path-slip-fraud
  - 2026-06-17_decision-range-a011daf-03d6383-w1-sized-escalate
project: github.com/kokarat/mobiz-payment-gateway
---

# Telegram report fixes + Thunder client-upload defer (status updates to DRIFT-10 & DRIFT-15)

Recorded as in-place updates to existing drift rows during the 2026-06-17 W2 pass.

**Telegram hourly report (DRIFT-10 update):**
- `c98e174` #526 — cumulative + Total-MDR were silently returning ฿0. Root cause: the report aggregations filter on `created_date_bkk` (ts_deposits/ts_payouts/topups) and `created_at` (mdr_shared) with no matching index, forcing COLLSCANs that blew the single shared 30 s context budget; the discarded errors made later queries return zero silently. Fix: covering indexes `{status, created_date_bkk, merchant_name, amount}` (db/indexes.go:100-145) → index-only `$group` (docsExamined=0); queries switched off mutable `updated_at` to immutable `created_date_bkk` (avoids retry double-count); error logging wired into `getStats()`/`getTotalMDR()`.
- `32224a9` #537 — duplicate hourly report on cron timeout-retry. Fix: dedup lock now keyed per BKK hour `lock:hourly_report:<YYYYMMDDHH>` held 58 min (was released immediately after send), released early only on send-failure so a genuine failed report can still be retried.
- The in-process `reportScheduler.Start()` remains commented out (`main.go:228-229`); external cron is still authoritative — DRIFT-10's core gap is unchanged.

**Thunder defer on client upload-slip (DRIFT-15 update):**
- `d921419` #522 — Thunder verification is now fully deferred/async on client `POST /deposit-request/:txnId/upload-slip`: handler no longer calls Thunder synchronously, deposit stays `pending` after upload (no flip to `checking`, `slip_verify_status` empty), so the statement matcher keeps its full `slip_review_timeout_minutes` window before `scheduler/deposit_expiry.go processSlipEscalation` queues Thunder. Response no longer returns transRef/verifyResult.
- `7bfad9b` #521 — recreates a fresh context after a slow Thunder call (12 s observed on maxpayplus 2026-06-12) so it cannot starve the duplicate-transRef check + deposit UpdateOne (was throwing 500 context-deadline).
- Combined with `e1964b8` #530 (DRIFT-19, matched late statements now auto-confirm before Thunder), this further shrinks the Thunder happy-path cost/gap that DRIFT-15 named.

Both folded into the W1-sized backlog; no current-system.md §5/§8.4/§8.5 rewrite this pass.
