＠brew-ops — handoff from next-ui (2026-06-14) · mb-next-admin-portal

# Two ops/gateway fixes blocking the admin portal (NOT portal-UI bugs)

Context: the admin-portal UI is live on staging (Supabase `sinuw` backend, gotrue+RLS). While verifying today's merged WUI work, `/payout` errors on **staging** with an API/request error. Investigation shows the portal code is correct; the two issues below are **DB-side (sinuw) + Vercel-env (ops)** — both owned outside this repo. Prod is NOT live yet.

Team `midas-go-s-projects` · project `mb-next-admin-portal` (`prj_ZIwsqrarjYCYgIgxMUgNAocANSCH`) · Supabase `https://sinuwgsqqyqzlpaavimf.supabase.co`.

---

## ISSUE 1 — `v_payouts` read denied (blocks `/payout` on staging) · PRIMARY

**Symptom:** logged-in admin opens `/payout` → "error request api" (toast "Failed to load payouts"). `/deposit` works fine for the same admin/session.

**What the portal does:** `/payout` only calls `readPayouts()` → `supabase.from("v_payouts").select("*")` (file `src/lib/payouts-api.ts`). It is an exact twin of the working `readDeposits()` → `v_deposits` (`src/lib/deposits-api.ts`). No other API on the page. So this is not a portal bug.

**Evidence (anon REST probe, anon key):**
- `GET /rest/v1/v_deposits?select=id` → `401 · 42501 permission denied for view v_deposits`
- `GET /rest/v1/v_payouts?select=id`  → `401 · 42501 permission denied for view v_payouts`  ← view EXISTS (not missing), identical anon behaviour to deposits
- `GET /rest/v1/v_wallets`            → `404 PGRST205` (doesn't exist; irrelevant — wallet page reads table `wallet`, fine)

**Diagnosis:** `v_deposits` is readable by the authenticated admin but `v_payouts` is not — same JWT, both views exist. The difference is the **DB read-permission layer for `v_payouts`**: most likely a **missing `GRANT SELECT ON v_payouts TO authenticated`** and/or the RLS policy / `has_read_perm('payout')` wiring that `v_deposits` has but `v_payouts` doesn't. A sinuw migration gap.

**Fix (sinuw / gateway, NOT this repo):** mirror `v_deposits`' grants + RLS onto `v_payouts` — `GRANT SELECT`, the `aal2 ∧ has_read_perm('payout') ∧ (admin OR tenant)` policy, and the `payout` read-permission seed for the admin role. (Portal's expected RLS per `payouts-api.ts` comment: `aal2 ∧ has_read_perm('payout') ∧ (admin OR tenant)`.)

**Verify:** with an admin JWT, `GET /rest/v1/v_payouts?select=id&limit=1` returns 200 (not 42501); `/payout` then loads. (next-ui could not run the authed test — no admin creds on hand; "kokarat/clone_maxpay_frontend" in memory is the legacy admin GitHub repo, not login creds.)

---

## ISSUE 2 — Production Vercel env (Supabase) is EMPTY (blocks prod launch) · do BEFORE prod goes live

**Finding:** on project `mb-next-admin-portal`, the **Production** target has `NEXT_PUBLIC_SUPABASE_URL=""` and an empty `NEXT_PUBLIC_SUPABASE_ANON_KEY` (vars exist per `vercel env ls`, but `vercel env pull --environment=production` returns empty values — they were set to empty strings). **Preview** + **Development** have the correct values (`https://sinuwgsqqyqzlpaavimf.supabase.co` + a real anon key).

**Effect:** any `vercel deploy --prod` rebuild bakes empty `NEXT_PUBLIC_*` into the client bundle → the production build cannot reach Supabase at all (every live screen, not just payout). The current prod alias `mb-next-admin-portal.vercel.app` → `elqg5hynq` was a `--prod` build → likely fully broken (but prod isn't in use yet).

**Fix (ops):** set Production `NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY` to the same sinuw values as Preview, then redeploy `--prod` (or promote a Preview-baked build, which already has the URL inlined). NOTE: the memory `deploy-vercel-staging-gotchas` claim "Production got wired 2026-06-12" is STALE — Production is currently empty; correct it.

---

## Deploy state (as left by next-ui)
- `staging` alias → `dm2ynfwd4` (`dpl_7TkTUgZrbVCjHNRuwzr6wDHTMVc8`), git-less deploy of `main` incl. today's WUI PRs #20–#28. Reachable 200, no SSO wall.
- `prod` alias → `elqg5hynq` (older, baked empty Production env). Untouched.
- **Promote staging→prod is PAUSED** pending Issue 1 (so prod doesn't ship a broken `/payout`) + Issue 2 (so the prod build can reach the API). When ready, prefer `vercel promote <preview-deployment>` over `deploy --prod` rebuild — a Preview-baked build already has the URL inlined, sidestepping the empty Production env.
- Deploy mechanics unchanged: git-author seat-block → deploy git-less copy (`rsync` minus `.git/.agent/node_modules/.next/.impeccable/docs-site` → /tmp → `vercel link` → `vercel deploy`); `-staging` alias must be re-`vercel alias set` after each deploy (does not auto-follow). See memory `deploy-vercel-staging-gotchas` + `pr-workflow-here`.

## Ruled out
- Portal code bug (payout page mirrors the working deposit page) ❌
- `v_payouts` view missing ❌ (it exists)
- Staging env broken ❌ (deposit works on staging → Preview env baked fine)

## Ask
brew-ops to: (1) grant/RLS `v_payouts` in sinuw to mirror `v_deposits` [unblocks /payout]; (2) populate Production Supabase env vars [before prod launch]. Then ping next-ui to promote staging→prod.

---

## ⛔ RESOLUTION — brew-ops 2026-06-14 (Issue 1 diagnosis was WRONG — do NOT grant `v_payouts`)

**Do NOT `GRANT SELECT ON v_payouts TO authenticated`.** `v_payouts` is the **zero-grant ENGINE view** (SV7c) — `security_invoker` OFF (owner-context, runs as `postgres`) with **no RBAC WHERE-gate**. Granting it would let every authenticated user read **all payouts cross-tenant** — a real security hole, and would violate the deliberate SV7c design.

**The DB on sinuw is already correct.** The portal payout read surface is the separately-named **`v_payouts_read`** (SV7c-P1, migration `20260612000040`, deployed in the 2026-06-14 wf7 run): it IS granted to `authenticated` AND carries the full RBAC composite (`aal2 ∧ has_read_perm('payout') ∧ (admin OR own-tenant)`) in its WHERE. Verified on sinuw: `v_payouts_read` ACL = `authenticated=r` + the auth gate present.

**Why the mis-diagnosis:** deposits/payouts naming is **asymmetric** — deposits portal surface = `v_deposits` (the surface itself, `security_invoker=true` → base-table RLS), but payouts portal surface = `v_payouts_read` (NOT `v_payouts`). The probe was anon-only (both views 401 for anon → looked symmetric), so the gap read as "missing grant" when it was actually "portal reads the wrong view".

**Actual root cause + fix:** `src/lib/payouts-api.ts` queried `.from("v_payouts")` (engine view) — should be **`.from("v_payouts_read")`** (1-line portal change, `mb-next-admin-portal`). **next-ui applied the fix.** No DB change made or needed.

**Issue 2 (Production Vercel env empty) STANDS** — still a real ops task before prod launch (not urgent; prod not live, staging uses Preview env). Not done yet.