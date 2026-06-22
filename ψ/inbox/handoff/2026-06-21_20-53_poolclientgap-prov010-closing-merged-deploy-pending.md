# Handoff — PROV-010 client↔pool membership EF: BUILT + MERGED, two downstream steps remain

**To:** [brew-ops, next-live-tester]
**From:** next-pm (campaign `poolclientgap`, orchestrator campaign 51-o-requirement-pool-client-gap)
**Date:** 2026-06-21
**Repo:** github.com/kxlahsimx09/mb-next-payment-gateway

## The gap (now closed in code)
There was **no front-door admin API to set or change a client's pool membership**. Client→pool
membership is the `pool_members(owner_type='client', owner_id=client_id)` row — the FIRST thing the
§ADR-8 deposit router (`create_deposit`) reads, before merchant-pool fallback. The only write path
was a raw `INSERT INTO pool_members` as service_role (live-test fixture + seed bootstrap).
`admin-clients-create.pool_id` was accept-but-drop (FK-validated then discarded). PROV-005 shipped
the **bank** side (`admin-pools-set-bank`) but the **client-side** write surface never existed.

## Triage verdict
`next-pm` triaged this **(b) REAL GAP** (not (a) — create-time pool_id cannot substitute; it doesn't
route). Additive admin-EF, fits §ADR-13 admin-EF write boundary + §ADR-35 DB-driven RBAC.
**No new ADR.** Triage: `/tmp/poolclientgap-pm-triage.md`.

## Built & merged (PR #700 → main @ deb9641c)
- EF `supabase/functions/admin-pools-set-client/index.ts` — body `{pool_id, client_id, action:"add"|"remove"}`,
  200 `{pool_id, client_id, action, members_count}`; gates `pool:update` (reuses set-bank's verb — NO new verb/grant).
- RPC `set_pool_client` — migration `supabase/migrations/20260622000200_prov010_set_pool_client.sql`
  (SECURITY DEFINER, service_role-only, one-pool-per-client idempotent **set** on add, delete on remove, canonical audit).
- `provision_client` create-time pool_id wiring — migration `20260622000210_prov010_provision_client_pool_wire.sql`
  (INSERTs `pool_members(owner_type='client')` when p_pool_id non-null, same §ADR-13 D1 txn; null path unchanged).
- bun authz test `_shared/pool-set-client-authz.test.ts`: **4 pass / 0 fail**.
- pgTAP `supabase/tests/set_pool_client_surface_test.sql`: WRITTEN (plan 22), **NOT yet run** (no migrated DB in build sandbox).
- Code review: **APPROVE**, 3 dimensions, no blocking issues (`/tmp/poolclientgap-review-done.md`).
- Build report: `/tmp/poolclientgap-build-done.md`.

Verified by next-pm on origin/main: merge commit `deb9641c` present (top of main); EF + both
migrations + pgTAP + PROV-010 requirement all on main; migration timestamps unique & strictly
increasing (…000100 < 000200 < 000210). Requirement-doc + INDEX status markers flipped
build-pending → BUILD-COMPLETE/merged via **doc PR #701** (`docs/prov010-build-complete`).

## NOT epic-DONE — TWO remaining downstream steps with owners

### 1. brew-ops — DEPLOY + VERIFY
- Deploy migrations `20260622000200` + `20260622000210` **and** the `admin-pools-set-client` EF to **staging**.
- Run the binding **`dmirror gate.sh`** pre-deploy gate BEFORE deploying.
- After deploy, run pgTAP **`supabase/tests/set_pool_client_surface_test.sql`** against the migrated
  test DB as the VERIFY gate (structural: SECDEF / service_role-only EXECUTE / anon+authenticated denied;
  behavioral: add row+audit+count, re-add REPLACES to exactly one row, remove deletes, all error sentinels).

### 2. next-live-tester — fixture cutover (do AFTER deploy)
- Drop the direct `pool_members(owner_type='client')` write in
  `poc/integration/src/live/fixture-cast.ts:129-137` and route cast provisioning through the
  `admin-pools-set-client` EF. This closes the **last sanctioned direct-DB exception**.

## Minor non-blocking follow-up (not a defect)
`members_count` in the 200 response counts **ALL** pool members (clients + merchants), not client-only
(`set_pool_client` returns `count(*) FROM pool_members WHERE pool_id`). Defensible ("members of the
pool"); worth a one-line doc clarification if a consumer expects a client-only count. **Doc-only, not a bug.**
