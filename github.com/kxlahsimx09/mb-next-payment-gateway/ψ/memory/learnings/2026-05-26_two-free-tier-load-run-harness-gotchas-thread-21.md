---
title: Two free-tier load-run harness gotchas (thread #216 §D run) — both confound a lo
tags: [implementation-architect, repo:mb-next-payment-gateway, next, poc, load-harness, spec-test, gotcha, callback, deposit, thread-216]
created: 2026-05-26
source: poc/integration/evidence/freetier-216/ (lifecycle-first-attempt-capexhausted.jsonl + lifecycle-rerun-after-count-reset.jsonl); thread #216 §D run 2026-05-26
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Two free-tier load-run harness gotchas (thread #216 §D run) — both confound a lo

Two free-tier load-run harness gotchas (thread #216 §D run) — both confound a logic-SLO/G-L7 measurement if not anticipated.

**1. `hosted-lifecycle-probe.ts` `dup_egress` is a CONFOUNDED proxy — assert dup-egress from `callback_queue` ground truth, not the probe number.** The probe computes `dup_egress = egress_attempts - delivered` over callbacks it finds in status='pending'. But the real eager dispatcher (DB-webhook path) fires between deposit→paid and the probe's query, delivering most callbacks first; the probe then races its manual `record_attempt`/`mark_delivered` on the few still-pending → `mark_delivered` returns non-"delivered" (already terminal) → the proxy inflates. In the §D run the probe reported `dup_egress=4` while the TRUTH was 0. Verify the real invariant directly: `callback_queue` rows-per-deposit (want exactly 1 → no dup-enqueue), status distribution (want all delivered), and "deposits with >1 delivered row" (want 0). All three held (1 row/deposit ×40, 40/40 delivered, 0 dup-delivered). Also true in brew-ops' smoke (msg 1077 "DB-webhook eager path fired before manual dispatch"). Companion: [[feedback_adr_amendment_supersession]].

**2. The 13-bank load-test fleet has a 999/bank daily cap (`bank_account.maximum_number_of_deposits`) = 12,987 deposits/day hard ceiling.** A sustained create-load run exhausts it fast (~7.2 min @ 30 dep/s); past that `create_deposit` raises `no_bank_available: no active deposit bank with capacity` and every subsequent create (driver AND the lifecycle probe's direct RPC) fails — looks like a signature/logic bug but is pure cap exhaustion. Fix for a re-measurement: surgical `UPDATE bank_account SET daily_deposit_count=0 WHERE pool_id=...` (preserves `bank_statements`). **NEVER `reset_runtime_state()` to clear it — that does `DELETE FROM bank_statements` and wipes the 50k G-L7 working set** (brew-ops msg 1077). For a longer/larger sustained run, seed more banks or raise the cap. Note: a "spread=0, all banks at 999" SLO-15 reading is the cap, not necessarily LRU fairness — re-read spread after a reset + uncapped concurrent burst for a clean fairness demonstration.

Both surfaced on the free/micro §D run ([[2026-05-26_d-free-tier-feasibility-run-outcome-thread-216]]). Companion: [[feedback_create_or_replace_function_overload]], [[feedback_gl6_load_harness_runs_on_src_not_migrations]].

---
*Added via Oracle Learn*
