# next-investigator — /mdr WRITE surface SEAL findings (campaign mdrwriteseal)

**Verdict: SEAL ISSUED ✅** — every PASS the tester (next-tester@mdrwritetest) claimed is **independently CONFIRMED** (or exceeded) against the seal **truth DB**. **Zero contradictions found.** Slice = §ADR-25 W1–W5 / MDRWRITE-001..004 + the §F1 numeric(7,4) boundary fix (PR #600, branch campaign/mdrwritebuild incl 09fde0a).

- **Date:** 2026-06-18 (GMT+7)
- **Seal env:** investigator stack, Supabase project `qnccphgykzdydebmdwdf` (via `.secrets/slots/investigator.env`, IPv4 session pooler `aws-1-ap-southeast-1`). brew-ops confirmation held: 5 cols `numeric(7,4)`, pgTAP installed, the 3 admin-mdr EFs deployed.
- **Method (layer-2 de-bias):** did NOT inherit the tester's run. Independently re-derived expected behavior from SPEC (epic-mdr-profile-write.md + §ADR-25) and observed actual behavior by (a) reading the **deployed** DB objects, (b) driving the RPCs under simulated PostgREST sessions (`SET ROLE` + `request.jwt.claims`) and as service_role, (c) hitting the deployed EFs over HTTP with real minted tokens, and (d) re-running the build-branch pgTAP suites on the seal DB. Every write probe was ROLLBACK-wrapped — **seal DB left pristine (3 profiles, 0 deleted, 0 residue; auth untouched).**

---

## Per-tooth falsification verdicts (tried to CATCH a discrepancy on each)

| # | SPEC tooth | Tester claim | Independent result | Verdict |
|---|---|---|---|---|
| 1 | **WRITE-GATE** (only super_admin aal2; else denied) | PASS | RPCs EXECUTE-only by `service_role` → anon/authenticated direct call = **42501** (runtime-proven). Gate funcs across **all 5 identity classes**: `would_write=TRUE` **only** for super_admin+aal2; FALSE for aal1, admin-without-perm (support_admin), non-admin (client), anon. HTTP: real aal1 super_admin & support_admin tokens → **401 `aal2_required`**. | **CONFIRMED** |
| 2 | **Σ%≤100 + residual** | PASS | `_mdr_validate_partners` rejects `>100` on **BOTH** `percentage` AND `topup_percentage` axes; accepts 100 inclusive. 100.0001 / 60+41 / topup 60+50 → `partner_share_exceeds_100`. Residual (100−Σ) left for the RM engine's is_owner fan-out (out-of-scope engine, not re-tested). | **CONFIRMED** |
| 3 | **SOFT-DELETE** (is_deleted, no hard delete, hidden in view) | PASS | delete sets `is_deleted=true`; row **persists** (total rows unchanged); **no** `DELETE FROM mdr_profile` in the RPC body; v_mdr_profile hides it (4→3 after soft-delete). | **CONFIRMED** |
| 4 | **BLOCK-IF-REFERENCED** | PASS | delete of referenced `tier-small` (3 payouts/7 topups) → `{"error":"profile_in_use","topups":7,"payouts":3,"deposits":0}`; `is_deleted` stays false. Checks ts_deposits/ts_payouts/client_topups. | **CONFIRMED** |
| 5 | **EDITABLE-FIELDS** (name+fees+partner%, not status/desc) | PASS | Schema has **no** `status`/`description`/`updated_at` columns to set (structural enforcement); update RPC COALESCE-PATCHes only name/`*_fee_percent`/partner allocation. | **CONFIRMED** |
| 6 | **AUDIT** (created_by/updated_by triples) | PASS | create populates BOTH created_by + updated_by triples; update sets updated_by; each write emits one `audit_log` row (`mdr_profile_create/update/delete`) with actor triple + before/after diff + reason. | **CONFIRMED** |
| 7 | **BASE-POSTURE** (base zero-grant; write only via SECDEF RPC) | PASS | `mdr_profile`/`mdr_profile_partners` grant **only** postgres+service_role (zero to anon/authenticated); direct authenticated INSERT = **42501**; v_mdr_profile = read (`r`) to authenticated only. | **CONFIRMED** |
| F1 | **§F1 numeric(7,4) boundary** (100 stores, no 500) | PASS [70][71] | 5 cols are `numeric(7,4)` (max 999.9999). Single partner `percentage=100` → `created:true`, stored `100.0000`. ALL fees=100 + partner pct=100 + topup=100 → created, stored exactly. **No 22003 overflow, no 500.** | **CONFIRMED** |
| R | **Read-leg intact + excludes is_deleted** | (implied) | v_mdr_profile def filters `is_deleted=false` + read gate (aal2 ∧ has_read_perm('mdr') ∧ admin); super_admin aal2 sees 3, client/aal1 see 0. | **CONFIRMED** |
| H | **HTTP DENIED 3/3** | PASS 3/3 | 3 EFs × {no-bearer, anon-key-as-bearer, forged JWT} → **401** `missing_bearer_token`/`invalid_token`; real aal1 tokens → **401 `aal2_required`**. **No 500, no silent success** (DB confirmed 0 `hack-%` rows). Reproduced & exceeded. | **CONFIRMED** |

## Independent pgTAP re-run on the seal truth DB
- **mdr_profile_write_surface_test.sql → 62/62 PASS, 0 fail** (incl §F1 tests 44–47; DB-layer denial 61–62 = 42501).
- **v_mdr_profile_read_surface_test.sql → 26/26 PASS, 0 fail.**
- No ERROR/FATAL in either run; both self-rollback.

## Architecture note (how the gate actually enforces)
The 3 RPCs are `SECURITY DEFINER` (owner postgres) and **EXECUTE-restricted to service_role** — they trust the `p_actor_*` params. So the "super_admin aal2 only" decision is enforced at **two independent layers**: (1) the EF verifies the caller then calls the RPC with the service_role key; (2) the RPC path is unreachable by anon/authenticated (42501) and base tables are zero-grant. The RLS write policies (`auth_aal2() ∧ auth_db_is_admin() ∧ has_perm('mdr:X')`) are correct defense-in-depth (inert for the SECDEF path, but encode the exact intent and are exercised by the gate-func matrix above). RBAC: `mdr:{create,update,delete}` seeded to **super_admin ONLY**.

## Non-blocking notes (transparency — NOT contradictions)
1. **Count labels:** tester's "main 71/71 / negctl 11/11 / [70][71]" don't map 1:1 to the deployed pgTAP files (write `plan(62)` + read `plan(26)`). The §F1 boundary the tester numbered [70][71] = write-surface tests **44–47** in the deployed suite. Labeling difference only — all underlying behaviors green.
2. **Coverage caveat (mitigated):** the HTTP path for **aal2 + non-super-admin** (e.g., aal2 admin lacking mdr:create) was **not directly minted** — the seal's non-super-admin users are already MFA-enrolled and their factor secrets are owner-held (`AAL2 required to enroll a new factor`). This is fully backed by DB-truth: the gate-func matrix proves these classes evaluate `would_write=false`, the RLS policies encode `has_perm`, and the EF returns staged structured errors (`aal2_required`). No breach observed; no tester claim contradicted.

## Done-when
- ✅ Every tester PASS independently confirmed (none contradicted).
- ✅ **SEAL ISSUED** for the /mdr WRITE slice (MDRWRITE-001..004 + §F1) — clear for next-code-reviewer merge / next-pm done-marking.
- Out-of-scope respected: no dev-code-as-truth, no deploy, no merge, no done-marking, no /roles.
