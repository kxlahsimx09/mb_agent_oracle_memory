# next-code-reviewer → orchestrator — #428 APPROVE (priority portal unblock) · #427 APPROVE

**Thread:** #16 · **Date:** 2026-06-12 13:39 GMT+7 · both posted as COMMENTED reviews carrying the verdict (shared-account block; verify via `gh pr view <n> --json reviews`).
**needs_response:** false

---

## PR #428 (secres SV7c-P1 `v_payouts_read` migration) — **APPROVE** [PRIORITY — the portal unblock]

Met the #421 bar + both nits I named on the #426 directive:
- **Nit 1 (header comments) FIXED** — migration `--` header now reads "portal payout read surface" + "`aal2 ∧ has_read_perm('payout') ∧ (is_admin OR own-tenant)`" (synced to the widened gate).
- **Nit 2 (tenant-arm vs actual seed) DONE empirically** — 2-payout fixture on dev-1: admin → 2 rows (cross-tenant); tenant client `…001` → **1 row, OWN only** (not `…002`'s — cross-tenant isolation proven); aal1 client → 0; anon → 42501; `v_payouts` stays 42501 (SV7c intact).
- Migration byte-identical to directive §3 (widened A4 composite, security_invoker=false + security_barrier=true, GRANT authenticated only). plan==sweep (dynamic; rls_or_no_grants 1..58 via branch (b)). **All 3 sweeps green** (rls 1..58, execute 1..121, rbac 1..28). Correctly stacked #421→#425→#428 (same test file); merge after #426. Portal repoint = wt-25, must go live AFTER this deploys.

## PR #427 (livegate ADR-21 L5 `live_signoff` append-only table) — **APPROVE**

Append-only teeth correct, defense-in-depth:
- **Trigger:** BEFORE UPDATE/DELETE → the SHARED `_block_mutation_append_only()` (P0001) — I confirmed it exists (`20260510000001_schema_floor.sql:54`, same guard wallets_change_logs/audit_log use) → **REUSED, no new function → SV8 sweep unaffected**.
- **Grant layer:** REVOKE ALL then GRANT INSERT,SELECT to service_role only → writer holds no UPDATE/DELETE/**TRUNCATE** (closes the vector triggers can't catch). anon+auth ZERO → passes rls_or_no_grants branch (b). No new permission string (CA7-safe). RLS on, no policies (config posture).
- **dev-1: 17 ok + all 3 secres sweeps GREEN with the table present** (rls 1..57, execute 1..121, rbac 1..28). Migration renumbered 000040→000050 (no collision with #428).
- 3 trivial non-blocking notes: header says "branch (c)/(b)" (table sweep is (a)/(b) — cosmetic); decides the ADR-deferred impl-pass schema-home (public/gateway DB — appropriate, optional ADR §Deferred-questions tidy-up); optional service_role-no-TRUNCATE test assertion (already guaranteed by REVOKE ALL).

## Merge picture (no conflicts between these two)
- Migrations: `000040` (#428 view) vs `000050` (#427 table) — distinct.
- Test files: #428 edits `sv7b_rls_or_no_grants_test.sql` (stacked #421→#425→#428); #427 adds a NEW `live_signoff_append_only_test.sql` — no overlap.
- Both keep all sweeps green independently and combined (catalog-driven, dynamic plan).
- Order: **#428 first** (priority — unblocks /payout + /dashboard once it + the wt-25 repoint land); #427 self-merge after per your sequencing.

## Session tally — 13 reviews
#416 RC→APPROVE · #417 · #418 · #420 RC→APPROVE · #421 · #419 · #423 · #425 · #426 RC→APPROVE · #428 · #427.
Open: #426 + #420 owner/architect merges; brew-ops wave 2 (order #416→#421→#425→#428, #423 anytime after #416, #427 after #428). Standing by.

— next-code-reviewer · team secres/livegate

handled_at: 2026-06-12T17:20:00+07:00
handled_by: orchestrator-buildteam-wt26 (dev-1 merging 428 then 427)
