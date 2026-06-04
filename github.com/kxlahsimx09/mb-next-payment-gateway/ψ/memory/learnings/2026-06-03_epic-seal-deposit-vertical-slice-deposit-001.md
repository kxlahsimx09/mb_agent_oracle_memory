---
title: #epic-seal — DEPOSIT vertical slice (DEPOSIT-001 + DEPOSIT-002) SEALED 2026-06-0
tags: [epic-seal, deposit, nextteam, verification, independent-regression, money-invariants]
created: 2026-06-03
source: next-investigator (campaign nextteam)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #epic-seal — DEPOSIT vertical slice (DEPOSIT-001 + DEPOSIT-002) SEALED 2026-06-0

#epic-seal — DEPOSIT vertical slice (DEPOSIT-001 + DEPOSIT-002) SEALED 2026-06-03 by next-investigator.

VERDICT: ✅ SEALED. Independently verified on an ISOLATED seal stack `qnccphgykzdydebmdwdf` (mb-next-investigator, Singapore) — separate from the tester stack `yupsevcrubgprsbujbpu`. The investigator did NOT trust the tester's green; re-derived every clause from raw ground-truth tables.

SCOPE: 30-clause complete-AC enumeration = 25 probed (5 happy AC + 20 GAP) + 5 non-probed guardrails (D1-07/D2-06/D2-07/D2-08/D2-10 — legitimately out-of-slice negative/race suite, existing poc/integration coverage: idempotency/finalize-race/finalize-rollback/expire-race; NOT hidden gaps).

INDEPENDENT REGRESSION (reset_for_test → §ADR-20 frozen virtual clock): SLICE 12/12 + GAP 38/38 = 50/50 assertions, 25/25 probed clauses PASS. Matches tester's green, independently re-derived on a separate stack.

LOAD-BEARING CLAIMS confirmed off raw tables (not harness booleans):
- NT-9 full-key collision → NO double-credit: same_dest=true, deposit_credit_row_count=1 (never 2), client_balance_delta=245.5 (not 491), one deposit paid + one pending. Pre-#314 double-credit defect genuinely fixed.
- NT-12 cascade/finalize honor app_now(): all match clauses finalize under frozen clock (no wall-clock-expiry artifact).
- §ADR-9 preconfigured callback: D1-04 raw callback_url→400 CALLBACK_URL_NOT_ALLOWED + zero side-effects; D1-05 invalid-key→400 / missing-config→409; AC-5 delivered-only-on-2xx (delivered last_code=204; non-2xx→not delivered, delivered_at null).
- d2-12 retro slip-fraud: both flagged slip_invalid w/ cross-referenced failure_message, both stay paid, client_delta_across_sweep=0 (NO reversal). Bound to ratified §ADR-4b PIN (key=system_bank_account_id+amount+BKK-day; migration 20260513000013).

MONEY INVARIANTS (all hold): conservation (gross=net+Σshares+residual, raw wcl_sum=250 exact), exactly-one-callback (delivered_rows=1, dedup_key deposit:<id>:deposit.paid), balance≥frozen / money-in-once (AC-4 1 stmt→1 credit, collisions→≤1 credit), money in/out once.

V1 BIJECTION: each probe quotes its AC clause verbatim + asserts pos+neg off ground-truth PostgREST reads; harness gatewayAssertion fails CLOSED (no false pass); tally machinery honest (throw→FAIL, OUT_OF_SLICE empty, GAP_UNBOUND=false). No pass-for-wrong-reason found.

ENABLEMENT (not a defect): AC-5 positive needs a reachable always-2xx callback seam (httpbin.org was globally 503 during the run; re-pointed to google/generate_204 to green it). Recommend CALLBACK_STUB_OK_URL/_FAIL_URL or mock-merchant MERCHANT_BEHAVIOR for CI determinism. The delivered-only-on-2xx invariant itself is fully verified.

Findings: next-investigator_nextteam_findings.md.

---
*Added via Oracle Learn*
