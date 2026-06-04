---
title: title: next-tester DEPOSIT-slice harness-validation — dup_egress proxy confirmed
tags: [next-tester, harness-validation, dup-egress, deposit, anti-bias, ground-truth]
created: 2026-06-03
source: tests/integration/probes/ + next-tester_nextteam_findings.md
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: next-tester DEPOSIT-slice harness-validation — dup_egress proxy confirmed

title: next-tester DEPOSIT-slice harness-validation — dup_egress proxy confirmed guilty + 5-clause probes authored (BLOCKED on SPEC+stack)

Campaign nextteam, 2026-06-03. next-tester validated next-impl's poc/integration harness BEFORE trusting any green (adopt-and-trust forbidden, handoff §0).

HARNESS VALIDATION (STEP 1):
- Assert-the-observable audit PASSED for the DEPOSIT probes I fork: deposit-verify-slip-now.ts (canonical template — asserts slip_verify_attempts + ts_deposits.status via restSelect + try/finally cleanup), finalize-race.ts (wallet.balance/wallets_change_logs/callback_queue counts; race serialized by Postgres FOR UPDATE not wall-clock), statement-dedup.ts (restCount(bank_statements)+wallet.balance).
- §D.6 dup_egress proxy CONFIRMED GUILTY in 3 load harnesses: hosted-lifecycle-probe.ts:114 (Math.max(0, attempts-delivered) — THE in-flight proxy that reported 4 when callback_queue truth was 0), concurrent-dispatch.ts:144 (received-unique from merchant LOG parse), callback-volume.ts:164 (counters.egress-delivered). None read callback_queue delivery rows. RULING: quarantined; my AC-5 probe reads dup-egress off callback_queue rows, never these counters.
- QUARANTINE-for-migration: statement-dedup.ts is SPEED-clock-coupled (new Date()+"SPEED=60x 15s window") → re-express under §ADR-20 frozen-step. cascade-race already demoted Promise.all→savepoint RPC (index.ts:127-136, audit#174 G-8): race-via-wall-clock = FLAKY.
- DEFERRED-to-live (handoff §7 items 2,3,5,6,7,8,9,10): flag-vs-raw-table reconciliation requires a live run with data — BLOCKED until stack deployed (NOT a pass).

SUBSTRATE: test/perf stack yupsevcrubgprsbujbpu is BARE — REST root 200 but all app tables 404, deposits-create EF 404. No migrations, no EFs deployed. Cannot run probes or reconcile until next-dev deploys.

source: tests/integration/probes/ + next-tester_nextteam_findings.md @ docs/nextteam-build-workflow
tags: next-tester, repo:mb-next-payment-gateway, next, harness, slo, dup-egress, deposit-002, evidence, handoff, fixture-source:integration-test
project: github.com/kxlahsimx09/mb-next-payment-gateway

---
*Added via Oracle Learn*
