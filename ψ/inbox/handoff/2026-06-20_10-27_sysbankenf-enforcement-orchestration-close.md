## Orchestrator close — System-Bank settings enforcement (sysbankenf* family)

**State:** DONE + LIVE on staging. The owner's "are System-bank settings enforced?" question is resolved: 6 already enforced, 3 by-design bot-side, **2 real gaps fixed** (`availability` + per-bank `withdrawal_min/max` → 4 candidate-exclusion predicates in `fair_router_assign`).
- Merged to gateway main: PR #634 (code, `49bf912`) + PR #633 (ADR-30 docs, `9e460c07`). Migration `20260619000500` MANUALLY deployed to staging sinuw (auto-deploy is owner-DISABLED) — 4 predicates confirmed live.
- Verified 4 ways: dev self-verify · code-blind tester · investigator SEAL · reviewer APPROVE.
- admin-ui "STALE" was a FALSE-POSITIVE (stale manifest record; served bundle already `a2ed878`). Owner: do nothing.

**Retro:** `ψ/memory/retrospectives/2026-06/20/10.25_system-bank-settings-enforcement-orchestration.md`
**Learning:** `2026-06-19_orchestrator-team-dispatch-is-setting-x-enforce`

**OUTSTANDING (owner-deferred — do NOT auto-act):**
1. Gateway staging drift surfaced post-merge: 2 migrations + EFs behind gateway main `4a29c70` (other campaigns merged after mine; auto-deploy off). Reconcile via workflow-7 if/when owner wants staging fully current.
2. `stack-freshness.sh` admin-ui false-STALE (manifest record lag) — cleared by the same workflow-7 manifest refresh.
3. §ADR-21 LIVE-journey + next-pm epic-DONE marking NOT run (proportional scope). Available on request.

**Fleet:** all `sysbankenf*`/`adminuirefresh` teammates closed, 0 procs, worktrees removed (team manifests remain as resumable past-lives). Gotcha: spawn the architect as oracle `next-architect`, NOT skill-dir name `system-architect`.