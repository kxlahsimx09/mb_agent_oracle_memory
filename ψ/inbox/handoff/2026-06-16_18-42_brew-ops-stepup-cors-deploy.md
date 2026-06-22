# [for next-ui] step-up + bankbot CORS deployed to staging — re-run the smoke

**From:** brew-ops (`brew-ops-stepup-cors-deploy`) · **Date:** 2026-06-16 18:42 (GMT+7) · **Stack:** `mb-next-staging` / sinuw (`sinuwgsqqyqzlpaavimf`)
**Closes:** next-dev (`next-dev-stepup-cors`) branch `fix/stepup-bankbot-cors` tip `28a2cf7` "fix: restore browser CORS on step-up Edge Functions" — the staging-deploy half.

## TL;DR — GREEN, re-run the WUI-013 browser smoke

The 2 step-up Edge Functions PR #534 missed are now deployed to sinuw with `withCors()`. Browser preflight passes. The WUI-013 step-up money-out modal + super-admin posture escape-hatch should now work from the browser (no more CORS kill).

## Deployed (targeted, from `fix/stepup-bankbot-cors`@`28a2cf7` — NOT deploy-all)

| EF | URL | Live status |
|---|---|---|
| `auth-step-up-verify`  | `https://sinuwgsqqyqzlpaavimf.supabase.co/functions/v1/auth-step-up-verify`  | ACTIVE v19, updated 11:39Z |
| `auth-step-up-posture` | `https://sinuwgsqqyqzlpaavimf.supabase.co/functions/v1/auth-step-up-posture` | ACTIVE v18, updated 11:39Z |

Command: `npx supabase functions deploy <ef> --project-ref sinuwgsqqyqzlpaavimf` (exit 0 each; `_shared/cors.ts` bundled in both).

## Curl evidence (the proof)

`OPTIONS` preflight — identical on BOTH EFs:

```
# allowed origin
Origin: https://mb-next-admin-portal.vercel.app
→ HTTP/2 204
  access-control-allow-origin: https://mb-next-admin-portal.vercel.app   # echoed, not *
  access-control-allow-headers: authorization, apikey, content-type, x-client-info
  access-control-allow-methods: GET, POST, PUT, OPTIONS
  access-control-max-age: 86400
  vary: Accept-Encoding, Origin

# disallowed origin (negative)
Origin: https://evil.example.com
→ HTTP/2 204   (NO access-control-allow-origin → browser blocks; allowlist enforced)
```

`PORTAL_ALLOWED_ORIGINS` already set on sinuw (`https://mb-next-admin-portal.vercel.app,http://localhost:3000`).

## `admin-bankbot-log` (WUI-130) — NOT deployed, by design

next-dev's commit `28a2cf7` states it explicitly: *"admin-bankbot-log (WUI-130) is a separate, genuinely-unbuilt backend slice — deferred, not a CORS fix."* No such EF dir exists on the branch (design/spec docs only). Nothing to deploy. If/when bankbot-log lands as a real EF, it'll need its own deploy + the same `withCors()`.

## Repo evidence

`docs/deploy-evidence/staging/2026-06-16_1842_stepup-cors.md` committed on local branch `ops/staging-deploy-stepup-cors-20260616` (NOT pushed — it tracks next-dev's branch; the handoff is the durable record). next-dev's `fix/stepup-bankbot-cors` is NOT merged yet — staging validation precedes the owner merge; `functions deploy` ships local source so no merge was required.

## Note for next session: `ef-deploy-list.sh --assert` shows STALE — that's a branch artifact

Running `--assert sinuwgsqqyqzlpaavimf` from `fix/stepup-bankbot-cors` reports FAIL (source=52/ACTIVE=51, ~51 EFs "STALE"). This is because the branch carries OTHER campaigns' undeployed substrate (a `_shared/rbac.ts` change + a 52nd EF `admin-topups`, both from the topup campaign) — it bumps every EF's `_shared` mtime floor. My 2 step-up EFs are NOT stale (fresh updated_at, ACTIVE). Do not deploy-all from this branch to "fix" the assert — those other EFs are owned by the topup deploy gate.

---

## §7 — PRODUCTION env-mirror (for the OWNER — brew-ops cannot action it)

**Status: NOT actionable from the fleet worktree.** `vercel whoami` → "No existing credentials found" — the worktree has no Vercel auth, and prod deploys are MANUAL + brew-ops-owned. Documenting the exact steps for the owner:

**What's needed:** the production admin-portal Vercel project must carry the 2 sinuw public vars (it reads exactly these — confirmed in `mb-next-admin-portal/.env.example` + source grep):

| Var | Value |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | `https://sinuwgsqqyqzlpaavimf.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | sinuw anon key (`eyJhbGciOiJIUzI1Ni…`) — fetch via `curl -s https://api.supabase.com/v1/projects/sinuwgsqqyqzlpaavimf/api-keys -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \| jq -r '.[]\|select(.name=="anon").api_key'`, OR Supabase dashboard → sinuw → Settings → API → anon/public key |

**Owner steps (in `mb-next-admin-portal`):**
```bash
vercel login                                  # owner credentials
vercel link                                   # link to the prod admin-portal project (no .vercel here)
vercel env add NEXT_PUBLIC_SUPABASE_URL production       # paste the URL above
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production  # paste the anon key
vercel env ls production                                  # confirm both present
vercel deploy --prod                                      # re-deploy so the build picks up the vars
```
Plus, when the **prod** portal domain goes live, prod EFs need the same `PORTAL_ALLOWED_ORIGINS` (add the prod origin) + the step-up CORS EF deploy on the prod Supabase project. **Do NOT deploy to prod without explicit owner go.**

## Next
- next-ui: re-run the WUI-013 step-up browser smoke against staging → expect preflight pass, modal fires.
- owner: action §7 prod env-mirror when ready (steps above).
