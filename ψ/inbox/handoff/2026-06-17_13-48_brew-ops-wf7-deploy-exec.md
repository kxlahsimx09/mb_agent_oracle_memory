# brew-ops-wf7-deploy-exec — admin-ui DEPLOYED to staging (portal-on-staging gap CLOSED)

**Status: DONE.** workflow-7 admin-ui substrate deploy executed; PR open for owner review (never merged).

## Result
- **Live URL:** https://mb-next-admin-portal.vercel.app (alias)
- **New deployment id:** `dpl_GYvwADZWkQw9t7T4DBUyj2Tg2c2r` (url `mb-next-admin-portal-78rhutov8`), `READY`, `target=production`
- **Replaces stale:** `dpl_7psQpP7fZ6fbw9ZTSoS3mey5zbVZ` (was the 2-day-old alias target)
- **admin-portal deployed SHA:** `2dd460f3cf8c8dde98f6e2ca2918b883efb98db6` (`main`, #37/#38/#39/#40/#41) — advanced from `509324b`

## Method (gotchas honored)
- **GOTCHA 1 (seat-block):** git-less deploy from `/tmp/portal-deploy-staged` (re-verified: no `.git`, src byte-identical to `2dd460f` for all #37–#41 files). Linked `prj_ZIwsqrarjYCYgIgxMUgNAocANSCH` / `team_NcQL9QEsv53GkO7pBqyiyMFC`.
- **GOTCHA 2:** `docs-site/` excluded via `.vercelignore`.
- **GOTCHA 3:** alias root + `/users` returned 200 (no 401) → ssoProtection PATCH not needed.
- Token validated `vercel whoami` → `midasgoteam-ops`; token + anon never echoed.

## Verify (new code is LIVE, not stale)
- Alias **root + `/users` → HTTP 200**; new id `dpl_GYvw…` ≠ stale `dpl_7psQ…`.
- **Bundle proof:** live `/_next/static/chunks/*.js` contain `v_users` (#39 /users-from-v_users) AND `admin-clients-create` (#41) → shipped JS is the new code.
- **Browser-side EF call resolves:** `OPTIONS` preflight from `Origin: https://mb-next-admin-portal.vercel.app` to `…/functions/v1/admin-clients-create` + `admin-users-set-role` → `204` + echoed `Access-Control-Allow-Origin` + `Allow-Methods: GET, POST, PUT, OPTIONS`. Origin on EF CORS allowlist (from the 2026-06-16 EF-CORS run) ⇒ client-side EF writes reachable.

## Manifest / evidence (committed, NOT merged)
- Repo: `mb-next-payment-gateway`, branch `chore/wf7-adminui-deploy-2dd460f`, **PR #551**.
- `STAGING-DEPLOY-MANIFEST.md`: admin-ui row → `deployed` (`2dd460f`); run header + idempotency updated. migrations/EF/cf-worker carry 2026-06-16 verified state (this was an admin-ui-scoped run).
- `docs/deploy-evidence/staging/2026-06-17_1345.md`: append-only per-run evidence.
- Secret-shape scan over the diff = clean; no slot/secret committed.

## Open items for owner
- **PR #551 awaiting review/merge** (per CLAUDE.md, never self-merge).
- cf-worker remains standing drift (no `wrangler.staging.toml` / CF token) — unchanged, not in this run's scope.
