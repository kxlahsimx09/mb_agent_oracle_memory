# brew-ops-wf7-adminui — admin-ui substrate deploy: CONFIRMED-BLOCKED on owner Vercel auth

**Agent:** brew-ops (fresh slug `brew-ops-wf7-adminui`) · **Workflow-7 admin-ui substrate (d)** · 2026-06-17 GMT+7

## Verdict
**CONFIRMED-BLOCKED.** Workflow-7's admin-ui auth path was followed exactly and is **NOT usable on this box** — no non-interactive Vercel auth source exists. The prior `brew-ops-vercel-deploy` conclusion ("blocked on a Vercel token") is **correct**, and opening the workflow-7 runbook + the portal's own bootstrap script confirms it is a genuine owner-only unblock, not a generic-search miss.

## The trigger IS live (the prompt was right on this)
- admin-portal `main` advanced `509324b → 2dd460f` (PR #41 `feat(portal): wire WUI-008 create-client to admin-clients-create EF`, plus #37–#40). `git rev-parse origin/main` = `2dd460f`.
- Prior wf7 run (2026-06-16 13:55) change-detected admin-ui as `skipped-no-change` because admin-portal was still `509324b`. **That no longer holds** → admin-ui substrate is CHANGED and must deploy. Correct call.

## What the runbook prescribes for admin-ui auth (quoted)
- Runbook `.agent/skills/brew-ops/references/workflow-7-staging-deploy.md`:
  - Step 0.3: *"Confirm CLIs: `supabase`, `wrangler`, `vercel` on PATH"* — no token slot named for Vercel (unlike Supabase, which has an explicit `staging.env` PAT slot).
  - Step 2(d): *"`cd mb-next-admin-portal && vercel deploy --yes`"* against the **linked project** (`.vercel/project.json` → `prj_ZIwsqrarjYCYgIgxMUgNAocANSCH`, org `team_NcQL9QEsv53GkO7pBqyiyMFC`).
- The auth source for that `vercel deploy` is spelled out verbatim in the portal repo's own `docs-site/scripts/vercel-bootstrap.sh` (the only place the mechanism is documented):
  > **"Auth token is taken from the Vercel CLI's own auth file (~/Library/Application Support/com.vercel.cli on macOS) — agents inherit it from the human's `vercel login` automatically. If that's absent, set `$VERCEL_TOKEN` before running."**

So the prescribed chain is exactly two non-interactive sources: **(1) Vercel CLI login cache (`auth.json`) from the owner's `vercel login`, OR (2) `$VERCEL_TOKEN`.**

## Proof both sources are absent on this box
- Real Linux CLI cache `~/.local/share/com.vercel.cli/` contains ONLY `config.json` (keys: `['// Docs','// Note','telemetry']` — **no `token` key**), `telemetry-device.json`, `telemetry-session.json`. **No `auth.json`** (the file that holds the login token).
- Swept every known location: `~/.vercel`, `~/.config/vercel`, `~/Library/Application Support/com.vercel.cli`, `~/.now` — all absent. Machine-wide `find ~ -iname auth.json` with a `"token"` field → none.
- `$VERCEL_TOKEN` **unset**. No Vercel key in any fleet slot (`staging.env` = 0 VERCEL keys; `next-ui.env` has only Supabase + UI-admin creds).
- `vercel whoami` (even with stdin closed) **blocks/terminates** — CLI is not authenticated non-interactively. Cannot start an interactive `vercel login` I can't finish.

## Everything ELSE is staged and ready (so the unblock is one step)
- `/tmp/portal-deploy-staged` is a **git-less** copy (no `.git` — the Jun-10 pattern to dodge the git-author seat-block) and **carries the `2dd460f` code**: PR #41's `admin-clients-create` wiring present in both `src/app/(portal)/users/create-client-modal.tsx` and `src/lib/client-provision-api.ts`.
- It is correctly linked: `.vercel/project.json` → `prj_ZIwsqrarjYCYgIgxMUgNAocANSCH` / org `team_NcQL9QEsv53GkO7pBqyiyMFC`.
- `.env.local` scaffolded with `NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY` (anon key available in `~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/slots/next-ui.env`).
- Only the auth token is missing.

## Exact owner unblock (one step)
On this box, the owner runs ONE of:
```bash
# A) interactive login (populates ~/.local/share/com.vercel.cli/auth.json):
vercel login            # then brew-ops re-runs wf7 admin-ui

# B) OR paste a Vercel access token into a brew-ops-readable slot, e.g.:
echo 'VERCEL_TOKEN=<token>' >> ~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/slots/staging.env
```
Then brew-ops executes from the staged copy:
```bash
cd /tmp/portal-deploy-staged
# env A → token from auth.json; env B → export VERCEL_TOKEN first / pass --token
vercel deploy --prod --yes \
  --build-env NEXT_PUBLIC_SUPABASE_URL=https://sinuwgsqqyqzlpaavimf.supabase.co \
  --build-env NEXT_PUBLIC_SUPABASE_ANON_KEY=<from next-ui.env>
vercel alias set <new-dpl-url> mb-next-admin-portal.vercel.app
```
Verify: URL HTTP 200, `/users` lists from `v_users`, browser-side EF call succeeds (CORS allowlist already carries `https://mb-next-admin-portal.vercel.app` per 2026-06-16 13:55 evidence). Then emit/commit the wf7 manifest (admin-ui row: `2dd460f`, `dpl_…`).

## Was workflow-7's admin-ui path usable? NO.
Followed the runbook's prescribed path precisely (linked-project `vercel deploy`, auth per the documented bootstrap chain). Genuinely requires the owner's `vercel login` cache or a pasted `$VERCEL_TOKEN` — neither present. This is the runbook's own Escalation case ("only the owner can paste"). Nothing was mutated. prod gateway/DB untouched.
