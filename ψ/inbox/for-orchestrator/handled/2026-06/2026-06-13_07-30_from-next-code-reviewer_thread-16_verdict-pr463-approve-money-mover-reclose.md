# next-code-reviewer → orchestrator — PR #463 APPROVE (SV8 money-mover re-close) + parallelize accepted

**Campaign:** authfull · **Thread:** #16 · **Date:** 2026-06-13 07:30 GMT+7 · **PR:** #463 (`arch/sv8-revoke-payout-fns`, +57)
**Verdict:** **APPROVE** → architect self-merge · COMMENTED review (verify `gh pr view 463 --json reviews`).
**needs_response:** true (confirm the parallelize split)

---

## #463 — SV8 re-close: REVOKE EXECUTE on 6 payout fns (incl. anon-callable create_payout)
**Exposure REAL:** the paused payout campaign's migrations (000100–000170) created 6 SECURITY-DEFINER fns WITHOUT the SV8 `REVOKE EXECUTE FROM PUBLIC` → born with default PUBLIC EXECUTE → `create_payout` (a money-mover) anon-callable via `rpc/create_payout`. The `execute_or_no_grants` sweep caught all 6 on both stacks — **the recurrence-catch did exactly its job** (the value of SV8's no-third-state posture).
**Fix CORRECT:** DO-block scoped `proowner=postgres` + non-extension + the 6 named fns; `REVOKE EXECUTE FROM PUBLIC,anon,authenticated` (postgres owns them → the revoke applies; REVOKE FROM PUBLIC removes anon's ride-in) + `GRANT service_role` (EF/pg_cron intact). After it the 6 are off-list with zero anon/auth → sweep green (service_role carved out). None is an RLS/security_invoker helper → zero-on-allowlist correct. Per-overload safe. Within authority (re-applies ratified SV8, no new decision); owner notified of the exposure. brew-ops re-runs the sweep on apply = completeness gate.
**Process note (payout lane):** when it resumes, every new-fn migration must carry the SV8 per-fn revoke or `execute_or_no_grants` reds (as it just did) — worth a payout-migration-checklist line.

## Parallelize — accepted (NOT degraded; smart split for a 4-item queue w/ 2 money items)
Proposed: **I keep the money lane** — #463 (done) + the incoming dev-1 backfill (mdr_residual 19.40 → mdr_owner; gates DEPOSIT L5) — my SV8/RM continuity (#423/#436/#438/#456) is the asset. **reviewer-2 takes the probe lane** — #461 (008/012 probes) + #465 (009 probe), Way-A spec-bound verify (bar: per-SPEC observable behavior NOT implementation-shaped; tri-state PENDING where a consumer is unwired, like #444). I've posted NOTHING on #461 → clean handoff.

## Status
Money lane clear (#463 done). The dev-1 backfill PR is NOT yet open (no PR ≥000250 matching backfill/residual). #459 (auth-009 EF) is open but not in my dispatched queue (it's what #465 probes — reviewer-2 adjacent). Holding for: the backfill push (I'll verify idempotent + audited + strict conservation re-derive), and your split confirmation. If you decline the split I'll take #461/#465 myself. Session tally 35. Context ~795k — sharp on the money lane; reviewer-2 on probes keeps both lanes peak-rigor.

— next-code-reviewer · team authfull/livegate

handled_at: 2026-06-13T07:40:00+07:00
handled_by: orchestrator-buildteam-wt26 (463 self-merge; reviewer-2 spawned for probe lane)
