---
title: title: d5/DEPOSIT-005 probes — post-BK2 feedStatement needs paired-key auth (min
tags: [next-tester, deposit-005, bbot, paired-key-auth, adr-20-clock, evidence]
created: 2026-06-18
source: tests/integration/probes/d5/_flow5.ts @ 7a82cce4 ; PR #587
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: d5/DEPOSIT-005 probes — post-BK2 feedStatement needs paired-key auth (min

title: d5/DEPOSIT-005 probes — post-BK2 feedStatement needs paired-key auth (mint per dest + sign tMs from app_now, NOT Date.now)

tags: [next-tester, repo:mb-next-payment-gateway, next, probe, slo, deposit-005, bbot, evidence, handoff, fixture-source:integration-test, deposit-005]
project: github.com/kxlahsimx09/mb-next-payment-gateway
source: tests/integration/probes/d5/_flow5.ts @ 7a82cce4 ; evidence/integration-deposit-5-1781752029627-7a82cce4.json ; PR #587

PROBLEM (post-BK2 cutover #398): the d5 / DEPOSIT-005 suite (`bun tests/integration/run-deposit-5.ts`) ran vacuous on a cut-over stack because `feedStatement` (probes/_flow.ts) defaults to the RETIRED `x-bot-secret` header → `bot-statements` EF → `401 bot_key_missing` → statements never land → cascade never runs.

FIX (wiring only, no gateway change): `feedStatement` already has a paired-key `auth` seam; `probes/bbot/_botauth.ts` already mints+signs (mirror of poc/integration/src/live/bot-driver.ts). Added `mintDestCred(ctx, dest, reason)` to d5/_flow5.ts (revoke-then-mint via BBOT.rpc.mint, enc key = tester-slot BOT_CRED_ENC_KEY) and threaded `auth:{cred}` through `feedAndCascade` into every d5 probe (ac1/ac2/ac2b/ac3/ac4/ac5/ac6/ac7).

TWO NON-OBVIOUS PINS:
1. `dest.systemBankId` IS the `bank_account.id` — makeQrDeposit resolves it from `bank_account` by the create response's `payment_account_number`, and it is the SAME id the fed statement's `system_bank_id` carries → mint `p_bank_account_id = dest.systemBankId` makes key↔account always agree (no BK3 `bot_account_mismatch`). No separate lookup needed.
2. Sign the BK7 timestamp `tMs` from the stack's `app_now()` at FEED TIME, NOT wall-clock `Date.now()`. The d5 probes drive the §ADR-20 virtual clock (`clock_set` to T0+minutes; ac2/ac3/ac7 jump minutes/days ahead), so the verifier's ±300_000 ms replay window is measured against `app_now()`; `Date.now()` reads minutes off the frozen clock and 401s `bot_timestamp_expired`. (`auth.tMs` stays overridable for a WC3 window probe.) The live bot-driver uses Date.now() only because the live journey does NOT freeze the clock.

ENV PREREQ: tester slot must carry `BOT_CRED_ENC_KEY` (>=16 chars, == the stack's deployed EF secret) — a brew-ops provisioning item, not test code. mintDestCred fails LOUD if absent (never a silent vacuous green).

RESULT: 17/17 GREEN on tester yupsevcrubgprsbujbpu (post-BK2, PR #586 migration 20260618000200 applied), 3 consecutive runs (V4 non-flaky), ac_clauses=8 expected=8 deferred=[] dep5_unbound=false. Bun-confirms PR #586 (incl d005-ac2 same-bank→FIFO + d005-ac2b diff-bank→park). Landed test-only as PR #587 (based on #586 branch).

FOLLOW-UP (same gap, not yet fixed): deposit-002-ac3/ac4/ac5 call feedStatement with NO auth → same x-bot-secret default → will 401 post-BK2. Needs the same wiring (lift mintDestCred to _flow.ts or a shared helper + revalidate the deposit-002 runner) as a separate test-only PR.

---
*Added via Oracle Learn*
