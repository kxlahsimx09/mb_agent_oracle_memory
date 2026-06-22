# brew-ops-vercel-deploy — BLOCKED on Vercel auth token (everything else staged & ready)

**Operator:** brew-ops (slug `brew-ops-vercel-deploy`), 2026-06-17 ~11:55 GMT+7.
**Mission:** deploy merged `main@HEAD` of `mb-next-admin-portal` to Vercel staging (`mb-next-admin-portal.vercel.app`, pointing at sinuw `sinuwgsqqyqzlpaavimf`).
**Outcome:** **BLOCKED — need a `VERCEL_TOKEN`.** No non-interactive path exists on this machine. The deploy artifact is fully staged; one command finishes it.

## What I confirmed about the topology
- `main@HEAD` = `2dd460f` (WUI-008 merge #41) — has WUI-006/008/009/013/015/130 + /users + payout actions.
- **TWO Vercel projects exist.** The GitHub-integrated `vercel` app auto-deploys to project **`mb-next-admin-portal-docs`** (`mb-next-admin-portal-docs.vercel.app`, a Nextra PRD site), and **every one of its builds FAILS** — `git_url`/statuses on `main` show the latest production deploy `dpl_A2xh4tGyWwj8A...` (+ several Jun-16 ones) all `state=failure`. Cause = **GOTCHA 1 git-author SEAT-BLOCK**: HEAD commit author `117012903+kxlahsimx09@users.noreply.github.com` is not a member of the Hobby team `midas-go's projects`, so the team refuses to build any git-based deploy. This is the "commit-author-email mismatch" the orchestrator flagged. It is NOT retryable via API without a token (can't add team member / re-author).
- The **canonical `mb-next-admin-portal.vercel.app` is a SEPARATE project** (`prj_ZIwsqrarjYCYgIgxMUgNAocANSCH`, team `team_NcQL9QEsv53GkO7pBqyiyMFC`). Currently 200 but STALE (production deploy `220gui6ly`, Jun 10, pre-#9). The GitHub integration does NOT push to this project — it's deployed by the **git-less `vercel deploy` CLI playbook**.

## Canonical deploy method (from the Oracle learning doc, thread #13, 2026-06-11)
`ψ/memory/learnings/2026-06-11_next-ui-deploying-mb-next-admin-portal-to-a-publ.md`:
- Deploy a **git-less rsync copy** (no `.git` ⇒ dodges the seat-block) with `.vercel/project.json` kept, then `vercel deploy`.
- GOTCHA 2: `docs-site/` must stay in `.vercelignore` + tsconfig exclude (both present today — verified OK).
- GOTCHA 3: project `ssoProtection` may 401 `.vercel.app` URLs → PATCH `/v9/projects/{id}` `ssoProtection=null` (reversible) if the owner needs a plain URL. (Also needs the token.)
- Auth token "lives in `~/Library/Application Support/com.vercel.cli/auth.json`" — i.e. **the human's `vercel login` cache**, NOT present on this Linux agent box.

## Paths I exhausted (all dead)
1. **Deploy hook** — `git grep` across portal + gateway repos, all fleet-secret dirs, central memory: zero `integrations/deploy` / `VERCEL_DEPLOY_HOOK`. None exists.
2. **GitHub integration** — wired but deploys to `-docs` and fails on the seat-block; not fixable without a token.
3. **GitHub Actions** — only workflow is `ui-gate.yml` (lint/tsc gate, no deploy). `gh secret list` repo + org = **0 secrets**. No `VERCEL_TOKEN`/`ORG_ID`/`PROJECT_ID`.
4. **Token stores** — no `VERCEL_TOKEN` value in any `~/.arra-oracle-v2/fleet-secrets/**`, no `~/.netrc`, no env var, none in `mb_agent_oracle_memory`. `.vercel-projects/` holds only `.gitkeep`+README (no link file for the portal). No `auth.json` anywhere on disk (`~/.local/share/com.vercel.cli/` has only telemetry/config). `vercel whoami`/`projects ls` hang on the interactive device-login (can't complete).
5. **Reconstruct Jun-10** — the playbook above IS the method; it needs the token the human's machine had.

I confirmed the token is the SOLE gate: `vercel deploy --prod --yes --token=<probe>` from the staged dir rejected only the token format — it did NOT fall back to interactive login, did not complain about the link or env. So a valid token → immediate deploy.

## STAGED & READY — single-command unblock
Artifact at `/tmp/portal-deploy-staged` (git-less copy of `main@2dd460f`, `.vercel/project.json` = `prj_ZIwsqrarjYCYgIgxMUgNAocANSCH` / `team_NcQL9QEsv53GkO7pBqyiyMFC`, `.env.local` with both `NEXT_PUBLIC_SUPABASE_URL=https://sinuwgsqqyqzlpaavimf.supabase.co` + sinuw anon key, docs-site excluded). The owner only needs to provide a Vercel token, then:

```
cd /tmp/portal-deploy-staged
vercel deploy --prod --yes --token=$VERCEL_TOKEN \
  --build-env NEXT_PUBLIC_SUPABASE_URL=https://sinuwgsqqyqzlpaavimf.supabase.co \
  --build-env NEXT_PUBLIC_SUPABASE_ANON_KEY=<sinuw anon key>
# then alias to mb-next-admin-portal.vercel.app, and if 401: PATCH /v9/projects/prj_ZIwsqrarjYCYgIgxMUgNAocANSCH ssoProtection=null
```

**MINIMAL UNBLOCK FOR OWNER:** export a `VERCEL_TOKEN` for team `midas-go's projects` into the agent shell (or a fleet-secret slot), OR run `vercel login` once on this box so `~/.local/share/com.vercel.cli/auth.json` is cached. Either one and I deploy + verify immediately.
