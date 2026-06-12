# next-dev-1 → orchestrator-buildteam (wt-26) · thread 16 · 2026-06-12 11:22 GMT+7

## secres — ALL FIVE deliverables BUILT (3 merged, 2 in review)

| # | Deliverable | State | Evidence (dev-1, pgtap 1.3.3) |
|---|---|---|---|
| T1 | CA3 `user:update` + pure `rbac.ts` extraction | **MERGED #417** → main `92cd077` | rbac.test.ts 11 pass; survived #416 merge |
| T2 | CA7 `rbac_seed_vs_catalogue` gate | **MERGED #417** | plan 1..28, 28 ok/0; teeth (bogus→2 RED) |
| T3 | SV7c owner-context VIEW closure | **MERGED #421** → main `74d26bc` | pre 4 RED → post 1..56, 56 ok/0; svc_role retained |
| SV8 | function PUBLIC EXECUTE closure | **PR #423 OPEN** (review) | pre 107 RED → post 1..121, 121 ok/0; aclexplode: auth{5 helpers}, PUBLIC/anon=0, svc_role=118, pgtap 1079 untouched |
| SV9 | SV6 non-SELECT residue closure | **PR #425 OPEN** (review) | pre 13 RED → post 1..56, 56 ok/0; aclexplode: auth=SELECT only, anon zero, no residue |

### #423 (SV8) — `secres/sv8-function-execute`
DO-block app-owned loop (proowner=postgres, deptype='e'); REVOKE EXECUTE FROM PUBLIC/anon/authenticated + GRANT service_role; re-GRANT 5 A4 RLS-helpers to authenticated; + DEFAULT PRIVILEGES belt. New `sv8_execute_or_no_grants_test.sql`. **Allowlist completeness census-verified** (only the 5 helpers appear in any pg_policies qual; v_deposits security_invoker body is a plain projection). One spec-instructed literal fix: `has_read_perm(p_resource text)` (PG17 identity-args include the param name). Independent — mergeable any time.

### #425 (SV9) — `secres/sv9-nonselect-residue`
REVOKE REFERENCES/TRIGGER/MAINTAIN (anon+auth) + SELECT (anon) on the 12 SV6 tables. Branch-(a) tightening of the table sweep in `sv7b_rls_or_no_grants_test.sql` → each SV6 row asserts the exact contract. Built off post-#421 main → no same-file collision (per the reviewer/your sequencing note). Cumulative sweep file condensed to 242 lines (<250). UNSTABLE = pending Vercel docs deploy only (benign).

## Discipline notes
- All PRs off main, docs-free (landing shape B — no bundled docs commit). Shared campaign/secres worktree kept clean (no supabase/ pollution of #416).
- Every merge verified ONLY via `gh pr view --json reviews` (commit_id == head) before acting; self-merge under owner standing GO 2026-06-10.
- dev-1 carries SV7c+SV8+SV9 applied (verified end-states); brew-ops db-push of the wave records migration history (20260612000010/000020/000030) across stacks. EF redeploy (T1 rbac.ts) rides the wave (behavior-neutral until AUTH-011).

## Remaining
Self-merge #423 + #425 on verified APPROVE (independent, any order). Then secres impl lane is complete. Polling gh.

handled_at: 2026-06-12T13:50:00+07:00
handled_by: orchestrator-buildteam-wt26 (reviewer queued 423+425)
