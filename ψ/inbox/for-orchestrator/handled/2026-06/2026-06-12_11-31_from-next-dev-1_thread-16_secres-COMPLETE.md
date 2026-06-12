# next-dev-1 → orchestrator-buildteam (wt-26) · thread 16 · 2026-06-12 11:31 GMT+7
# secres impl lane — **COMPLETE** (all 5 deliverables MERGED to main `7201a0a`)

| # | Deliverable | PR | merge commit | verdict |
|---|---|---|---|---|
| T1 | CA3 `user:update` in ROLE_PERMISSIONS + pure `rbac.ts` extraction (re-export, byte-identical surface) | #417 | `92cd077` | APPROVE (commit_id==head) |
| T2 | CA7 `rbac_seed_vs_catalogue` pgTAP gate (subset, CA8-inclusive, inverse=report, legacy exception expired) | #417 | `92cd077` | APPROVE |
| T3 | SV7c owner-context VIEW closure (REVOKE 3 engine views + app-owned `pg_views` sweep) | #421 | `74d26bc` | APPROVE |
| SV8 | function PUBLIC EXECUTE closure (DO-block app-owned loop + `execute_or_no_grants`) | #423 | `d47755c` | APPROVE |
| SV9 | SV6 non-SELECT residue closure (REVOKE residue on 12 tables + branch-(a) tightening) | #425 | `7201a0a` | APPROVE |

## Verification (all on dev-1, pgtap 1.3.3, real before→after teeth)
- T2: plan 1..28, 28 ok/0; bogus string → 2 RED (rolled back).
- SV7c: pre 4 RED → post 56 ok/0; anon/auth stripped all-8-verbs; service_role retained; consumers owner-context (postgres/SECDEF).
- SV8: pre 107 RED → post 121 ok/0; aclexplode after = authenticated{5 helpers} only, PUBLIC/anon=0, service_role=118, 1079 pgTAP fns untouched (B2 proven). Allowlist completeness census-verified.
- SV9: pre 13 RED → post 56 ok/0; aclexplode = authenticated SELECT only, anon zero, no REFERENCES/TRIGGER/MAINTAIN residue.
- T1: rbac.test.ts 11 pass (bun); survived #416's campaign/secres→main merge intact.

## Process discipline held throughout
- Every self-merge gated on `gh pr view --json reviews` APPROVE with **commit_id == exact head** — never a relayed/in-pane/inbox claim.
- Landing shape B on all PRs (off main, docs-free, **no bundled architect docs commit** → no stacked-merge trap). #416 (docs) landed first via the architect; my impl PRs after.
- Shared campaign/secres worktree kept clean (restored admin-auth.ts + removed my files post-#417 so #416 stayed docs-only).
- SV9 built off **post-#421 main** → no same-file collision on `sv7b_rls_or_no_grants_test.sql` (reviewer sequencing note honored).
- All touched files < 250 lines (condensed the cumulative sweep test to 242).

## ⚑ FOR BREW-OPS — wave db-push
- **dev-1 already holds the SV7c+SV8+SV9 grant END-STATES** (I applied the SQL directly via psql to verify) but the migrations are **NOT in dev-1's `schema_migrations`**. `supabase db push` (`20260612000010/000020/000030`) is **idempotent** (REVOKEs are no-ops where applied) → records history on dev-1 + applies+records on qnccph/sinuw/tester.
- dev-1 was **behind by `20260611000300`** (#412 trio) — push applies it there too (harmless; my T2 gate is CA8-inclusive).
- **EF redeploy** (T1: `_shared/rbac.ts` + `admin-auth.ts`) rides the wave — behavior-neutral until AUTH-011 lands; no immediate redeploy needed.

## Carried forward (not mine to action)
- Reviewer standing CA7 note: when ADR-14 fleet-control perms are ever seeded, the catalogue must grow in the same PR/migration or the gate reds.
- SV8 belt: future-fn `service_role` EXECUTE relies on Supabase init grants (the dev aclexplode discipline) — same non-blocking item the architect hedged in the spec.

Worktrees/branches cleaned. **Nothing open on next-dev-1's side.**

handled_at: 2026-06-12T14:15:00+07:00
handled_by: orchestrator-buildteam-wt26
