# brew-ops → orchestrator — secres WAVE 3 (v_payouts_read + live_signoff) deploy: GREEN on BOTH stacks

**Thread #16 · 2026-06-12 13:49 GMT+7 · qnccph (seal) + sinuw (staging).** Ran from a clean detached worktree of `main@f9d7b96`; shared campaign/secres worktree untouched; temp worktree removed.

## Merge states — verified via `gh pr view`
- **#428** MERGED `2e5bd6d` (SV7c-P1 — `v_payouts_read` gated projection)
- **#427** MERGED `f9d7b96` = main HEAD (ADR-21 L5 — `live_signoff` append-only table)
- **Source-diff `f156462..f9d7b96`: ZERO `supabase/functions/`+`src/`** → no EF redeploy (only migrations/tests/docs).

## [1] Migrations `20260612000040` + `20260612000050`
- Base rev `20260612000030` confirmed both; dry-run 2 pending each; applied in order; **rev now `20260612000050` on both**. (The `DROP TRIGGER IF EXISTS` NOTICEs are first-create idempotency, harmless.)

## [2] `v_payouts_read` (portal payout projection) — GREEN both stacks
- **EXISTS**, owner-context **`security_invoker=false` + `security_barrier=true`** ✓ (the #412 gated-projection shape).
- **Grants: `authenticated:SELECT` only** — no anon, no PUBLIC. (sinuw also `investigator_ro:SELECT` = the L3 RO role's default-privilege, benign.)
- Queryable as service_role/postgres (no error). **Gate FAILS-CLOSED:** ungated `authenticated` (no aal2/perm) → **0 rows, no 42501** (has the grant, gate denies rows). aal2-admin JWT sim ran (real admin found on both) → 0 rows **because base `ts_payouts` = 0 on both stacks** (no payout data; on a data-bearing stack the gate opens to the admin's cross-tenant set — logic verified, count is data-limited).
- **SV7c intact: the engine `v_payouts` STAYS `42501` for `authenticated`** ✓ (the revoke held; portal now reads `v_payouts_read`).

## [2] `live_signoff` (ADR-21 L5 append-only) — GREEN both stacks
- Table present, **RLS enabled, 0 policies** (config-table posture). **Grants: `service_role` INSERT+SELECT only; anon+authenticated ZERO** ✓ (sinuw `investigator_ro:SELECT` = RO default, benign).
- **service_role INSERT works** (ROLLBACK probe; **0 probe rows left** — never persisted).
- **Append-only enforced at BOTH layers** (defense-in-depth, both stacks):
  - `service_role` UPDATE/DELETE → **42501** (grant-layer — service_role holds no UPDATE/DELETE grant, fires first).
  - owner/grant-holder UPDATE/DELETE → **P0001 `live_signoff is append-only`** (the trigger teeth — demonstrated via an owner probe, ROLLBACK, 0 rows left).
  - *Note: the orchestrator's "P0001 trigger" expectation is confirmed; for the service_role write-path the grant-layer 42501 simply fires before the trigger is reached.*

## [3] Sweep suites — pgTAP on sinuw (qnccph has no pgTAP → aclexplode equivalents in [2])
- `sv7b_rls_or_no_grants` **61/61** · `sv8_execute_or_no_grants` **121/121** · `rbac_seed_vs_catalogue` **31/31** · `live_signoff_append_only` **17/17** → **230/230, 0 failures.** (rls plan grew 58→61 with the `v_payouts_read` view-sweep additions — all pass.)

## [4] EF health
- `auth-login` → HTTP 400 `{"error":"missing_credentials"}` on both (no EF redeploy this wave; unaffected).

**VERDICT: WAVE 3 GREEN on qnccph + sinuw.** Clear to (a) notify wt-25 to flip the portal repoint (v_payouts → v_payouts_read) and (b) have the owner record the first formal `live_signoff` ACCEPT row. The full secres exposure close-out + the L5 sign-off substrate are deployed and verified. brew-ops on standby.

handled_at: 2026-06-12T17:50:00+07:00
handled_by: orchestrator-buildteam-wt26 (wt-25 notified; owner ACCEPT next)
