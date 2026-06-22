## /mdr WRITE leg — COMPLETE + LIVE; /roles WRITE deferred. Orchestrator campaign `o-ui`, 2026-06-18.

Follow-on to the read-surface family (`mdr-roles-live-done` handoff). After /mdr + /roles shipped read-only + LIVE, owner asked for the WRITE leg. Outcome:

**/mdr = fully editable LIVE** (super_admin create/edit/soft-delete on `mb-next-admin-portal.vercel.app/mdr`, reads+writes staging sinuw).
- Spec §ADR-25 (composes §ADR-18 + §ADR-13). Forks ratified: wf1 project-what-exists · wf2 full-CRUD + soft-delete (is_deleted + §ADR-13-F2 audit triples) · wf3 Σ%≤100 + residual-to-is_owner (§ADR-18 b2 ==fee SUPERSEDED) · **wf4 = KEEP /roles READ-ONLY (AUTH-003 RBAC freeze HELD)**.
- Build PR #600: 3 SECDEF RPCs (admin_create/update/delete_mdr_profile, EXECUTE→service_role) behind admin EFs (admin-mdr-{create,update,delete}) + RBAC seed mdr:{create,update,delete}→super_admin + RLS write policies + Σ%≤100 + audit.
- **§F1 bug caught by the independent tester** (not dev's own tests): a boundary value of 100 overflowed `numeric(6,4)` (max 99.9999) → uncaught 500. Fixed by widening the 5 fee/% cols to `numeric(7,4)` (commit 09fde0a). VERIFY 71/71 → SEAL (0 contradictions) → reviewer APPROVE+merge.
- Ship: brew-ops staging (sinuw, migrations + full 61-EF sweep) → next-ui wire #65 (Add/Edit/Delete + Σ%-inline-block + soft-delete + block-if-referenced, super_admin-gated) → portal redeploy → LIVE (verified super_admin uses controls, cs denied). pm marked MDRWRITE-001..004 + WUI-231/232 DONE (#606/#66).

**Deferred (NOT built, freeze held):** /roles write (ROLEWRITE-001..005, WUI-233/234) — revisit only on explicit owner GO to lift the AUTH-003 Phase-1 RBAC freeze + the stricter-guardrail set (wf5/wf6).

**Known /mdr-write limitations (substrate-grounded, honest):** partner picker labels by wallet owner-id (no partner names on any read surface); EDIT can't pre-fill existing partner allocations (`mdr_profile_partners` zero-grant) → "replace entire allocation" tick. Both = further-increment if the owner wants a partner read path.

**Also shipped:** /roles matrix horizontal-overflow fix (PR #59, sticky column). Login cast for staging: `~/sa-login.sh` (U_SA super_admin). Retro: `ψ/memory/retrospectives/2026-06/18/18.50_mdr-roles-live.md` (read leg).
