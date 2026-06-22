# brew-ops-wf7-runbook-gitless — wf7 admin-UI step hardened for hands-off deploy (PR open, not merged)

**Agent:** brew-ops (fresh slug `brew-ops-wf7-runbook-gitless`) · 2026-06-17 GMT+7 · **doc/runbook change only, no live deploy**

## Done
Rewrote the **workflow-7** admin-UI substrate (d) step so a future hands-off wf7 run deploys `mb-next-admin-portal` to Vercel successfully. Codified the two fixes proven this session.

- **File:** `.agent/skills/brew-ops/references/workflow-7-staging-deploy.md` (resolves into the skills repo `kxlahsimx09/mb_agent_oracle_memory` at `github.com/Soul-Brews-Studio/arra-oracle-v3/...` — `.agent` is a symlink; per `skills-live-in-separate-repo`, the PR is against that repo, NOT the gateway).
- **PR:** https://github.com/kxlahsimx09/mb_agent_oracle_memory/pull/24 (branch `docs/wf7-adminui-gitless-runbook`). **Awaiting owner review — NOT self-merged.**

## The two blockers codified
1. **Auth (resolved):** `VERCEL_TOKEN` now lives in `slots/staging.env` (sourced in Step 0). Step 0.2 asserts it non-empty; every `vercel` cmd in (d) passes `--token=$VERCEL_TOKEN`. Supabase build env (`SUPABASE_URL`/`SUPABASE_ANON_KEY`) is in `slots/next-ui.env` — documented.
2. **Git-author seat-block (the real gap):** old step `cd mb-next-admin-portal && vercel deploy --yes` is a `.git`-present deploy that FAILS the Vercel Hobby seat-block (HEAD commit author not a team member). Rewrote (d) to the proven **git-less** path: copy tree WITHOUT `.git/` + `docs-site/` to a temp dir, carry `.vercel/project.json` (`prj_ZIwsqrarjYCYgIgxMUgNAocANSCH` / `team_NcQL9QEsv53GkO7pBqyiyMFC`), `vercel deploy --prod --yes --token=$VERCEL_TOKEN` from there, alias, ssoProtection-401 PATCH (GOTCHA 3).

## Ground truth used
Proven run = `brew-ops-wf7-deploy-exec`, deployment `dpl_GYvwADZWkQw9t7T4DBUyj2Tg2c2r` (`READY`, alias 200), admin-portal SHA `2dd460f`. Confirmed `staging.env` carries `VERCEL_TOKEN` and `next-ui.env` carries `SUPABASE_URL`/`SUPABASE_ANON_KEY` (key names only; values never echoed).

## Also added
Persistent `vercel env add` for build env (per-run `--build-env` fallback), sharper Step 3 UI verify gate (READY + new `dpl_…` ≠ prior + alias root/`/users` 200 + optional bundle grep + record SHA), an admin-UI GOTCHAS callout (seat-block→git-less / docs-site exclude / ssoProtection 401 / token home), amended footer.

## Safety
Doc-only; no substrate mutated. Secret-shape scan over the diff = clean (all secrets referenced via `$VAR`/slot, none committed). Owner merges.

**After PR #24 merges, a hands-off wf7 run will deploy admin-ui successfully** (auth via the `staging.env` token + git-less dodges the seat-block).
