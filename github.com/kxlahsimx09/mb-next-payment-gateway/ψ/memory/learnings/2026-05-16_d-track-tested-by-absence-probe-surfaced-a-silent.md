---
title: D-track tested-by-absence probe surfaced a silent substrate defect: function-ove
tags: [poc-implement, d-track, tested-by-absence, substrate-defect, function-overload, sweep-stale-claims, mark_failed, exception-when-others-masking]
created: 2026-05-16
source: next-impl thread #118 — D-track D2/D6/D7
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# D-track tested-by-absence probe surfaced a silent substrate defect: function-ove

D-track tested-by-absence probe surfaced a silent substrate defect: function-overload ambiguity disabled sweep_stale_claims.

**Context.** Authoring the D2 (explicit bot restart) D-track invariant probe for the integration PoC (`poc/integration/src/probes/bot-restart-claim.ts`). D2 forces `sweep_stale_claims` (§ADR-4a D6) to FIRE on a bot-restart-orphaned withdrawal claim.

**Defect found.** Migration `20260513000005_adr9_wc_payload_rpcs` added a 3-arg `mark_failed(uuid, text, text DEFAULT 'system_error')` overload **without dropping** the existing 2-arg `mark_failed(uuid, text)`. PostgreSQL then carried both. `sweep_stale_claims`'s internal `PERFORM mark_failed(v_row.id, 'sweep: ...')` (2 positional args) matched **both** candidates → SQLSTATE `42725` "function is not unique". The sweep body wraps each row in `BEGIN ... EXCEPTION WHEN OTHERS THEN CONTINUE`, so the ambiguity error was **swallowed silently** — every bot-restart-orphaned withdrawal claim leaked forever in `status='claimed'`. The §ADR-4a D6 invariant did not hold in production.

**Why the smoke missed it.** The integration smoke's fixture exercises only `mark_success` / `mark_rejected` / `mark_waiting_to_review` — never `mark_failed`, never `sweep_stale_claims`. The dead code path stayed invisible until the D2 tested-by-absence probe was the first thing to drive it.

**Fix.** Migration `20260516000001_resolve_mark_failed_overload_ambiguity` drops the redundant 2-arg overload; the 3-arg form is a strict superset (default `p_failure_code='system_error'`), so all callers resolve unambiguously with no behaviour change.

**Durable rules.**
1. A `CREATE OR REPLACE FUNCTION` that changes **arity** does NOT replace — it ADDS an overload. Any migration adding params to an existing RPC must `DROP` the old signature in the same migration, or it silently creates a call-ambiguity landmine for every existing positional caller.
2. `EXCEPTION WHEN OTHERS THEN CONTINUE` in sweep/cron loops masks structural errors (ambiguity, missing column) as if they were per-row data faults. Such handlers should at minimum log, or narrow the caught condition — otherwise a sweep can be 100% dead and still "succeed".
3. tested-by-absence works: a load-bearing invariant probe that no happy-path test covers will catch exactly this class of silently-dead substrate code.

---
*Added via Oracle Learn*
