---
title: next-tester regression run vs main `329051c` (2026-06-12, thread #17, owner-dire
tags: [next-tester, repo:mb-next-payment-gateway, next, regression, evidence, bbot, auth, pgtap, substrate, drift, handoff]
created: 2026-06-12
source: ψ/inbox/for-orchestrator/2026-06-12_10-55_from-next-tester_thread-17_reply-regression-run.md @329051c
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# next-tester regression run vs main `329051c` (2026-06-12, thread #17, owner-dire

next-tester regression run vs main `329051c` (2026-06-12, thread #17, owner-directed) — VERDICT: NO REGRESSION in merged/shipped code at HEAD. Run target = qnccph (seal stack; creds live in `investigator.env`, NOT tester.env — yupsev=tester.env is 15 migs stale, sinuw=staging.env RO-only). Auth/RLS surface was already at HEAD; qnccph was behind only on bbot/entity (4 migs + bot-config + 4 STALE pre-BK2 bot EFs + no BOT_CRED_ENC_KEY). I deployed all to bring qnccph to TRUE HEAD (136/`000300` + 27 EFs + fresh ENC_KEY).

GREEN batteries: pgTAP 171/171 (123 baseline = the 3 RLS files 75+35+13, all green; +sv7b 48 via #394; ran pgtap inside each file's ROLLBACK txn → zero residue); A6 exposure+P8 = 9 PASS/0 FAIL/1 PENDING (env-gated A3/CF leg); substrate lanes 1-3 (#403) FIRST-EVER run = 63/67 with lane4+lane2 GREEN and ALL bot-tier auth AC1-8 + credential lifecycle (mint/rotate/revoke/overlap/two-slot/secret-never-leaks) GREEN.

3 NEW findings (NONE a regression):
- F1 (route→architect/dev): BS-2 ISO `statement_date_bkk` → spec'd `500 submit_statements_failed`; probe+test-index+thread#13-note expect graceful `4xx bad_statement_date_bkk` which is NOT in the ratified spec (endpoints slice lists 500 submit_statements_failed + 400 invalid_json/missing_or_invalid_fields only). Data-safety holds (rejected, no bad insert). Spec-vs-design-intent reconcile.
- F2 (tester probe bug, mine): `tests/integration/probes/bbot/rotate-revoke.ts:18` orders `audit_log` by nonexistent `created_at` (col is `action_at`) → PostgREST 42703 → false RED `actions=[]`. Direct query proves bot-cred audit IS correct (mint/rotate/revoke + metadata.bot_key_prefix, resource_id=bank_account_id, no leak). Fix=order by action_at.
- F3: `x7_v` soft-window probe is wall-clock-timing-sensitive — hardcodes soft_window=3s but qnccph auth-login round-trip is 7.58s/6-call (incl 6.7s EF cold-start), so the soft-lock auto-expires (correctly) before the "locked" checkpoint. admin hard-lock leg + soft-expiry feature both correct. Re-verify on staging / move to §ADR-20 virtual clock.

ENV-limited (not regressions): 37-AC bijection = 2/2 executed PASS but gotrue-write-heavy (~30-80s/probe, staging-bound, RO-only on sinuw) so not completed; `bun test` at repo root = frozen poc/ integration tests needing local PG+deps (not a gateway unit suite). OBS-1: the auth "all-26-EF at HEAD" deploy never covered the bbot adapter EFs — they were stale (pre-BK2) on qnccph; check sinuw.

Gotcha for future hosted pgTAP: qnccph lacked pgtap (available 1.3.3) — inject `CREATE EXTENSION pgtap WITH SCHEMA extensions` + `SET LOCAL search_path` right after each test file's `BEGIN;` so it rolls back with the txn (zero residue). Gotcha for bun runners: bun fully-buffers stdout to a non-TTY (and `| tail` hides it) — run under `script -q` (pty) to stream, else killing loses the buffer and a slow run looks hung.

---
*Added via Oracle Learn*
