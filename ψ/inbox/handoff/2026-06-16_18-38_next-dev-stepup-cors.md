# [for brew-ops] step-up + bankbot CORS ready to deploy

> From **next-dev-stepup-cors** · 2026-06-16 · repo `kxlahsimx09/mb-next-payment-gateway`

## TL;DR
- **Step-up CORS: FIXED, PR up, ready to deploy.** Two EFs wrapped with `withCors`.
- **admin-bankbot-log (WUI-130): DEFERRED — genuinely unbuilt** (not a CORS gap). Re-classify WUI-130 DONE → backend-blocked.

## Branch / PR
- Branch: **`fix/stepup-bankbot-cors`** (off latest `origin/main`; did NOT touch `ops/staging-deploy-2026-06-16-portal-cors`).
- PR: **#540** → `main`. **DO NOT MERGE** (owner-gated).

## EF dirs changed (deploy these 2 on staging sinuw `sinuwgsqqyqzlpaavimf`)
- `supabase/functions/auth-step-up-verify/` — added `withCors` (was missing). Unblocks WUI-013 step-up money-out browser flow.
- `supabase/functions/auth-step-up-posture/` — added `withCors` (was missing). Unblocks WUI-013 super-admin posture escape-hatch.

Both mirror `admin-deposit/index.ts` exactly: `Deno.serve(handler)` → `Deno.serve(withCors(handler))` + the `_shared/cors.ts` import. **No business logic changed.** 92 / 44 lines (≤250). Pattern matches the 23 EFs already using `withCors`.

After deploy: re-run the WUI-013 live smoke (next-ui's recipe in `mb-next-admin-portal/docs/handoff-next-ui.md` §Live-test recipe).

## Bankbot verdict: DEFERRED (genuinely unbuilt)
Investigation (all confirm unbuilt, NOT deployed-but-untracked):
- EF source `supabase/functions/admin-bankbot-log/` — absent.
- Deployed staging fn list via Management API (51 fns) — `admin-bankbot-log` **NOT present**.
- Live DB PostgREST probe (service role): `bankbot_activity_log`, `v_bankbot_activity_stream`, `v_bankbot_fleet_now` all **404 (do not exist)**.
- Permission seed `bot-activity-log:view` — absent from migrations.
- Migration `20260615000010_bankbot_activity_log.sql` — absent (that number was used by `bb2_storage_buckets.sql`, which explicitly states it does NOT create the table/role/views — reserved for "next-dev's BUILD migration").

The whole BOTLOG slice **G1–G6** (`docs/spec/bankbot-activity-log-slice.md`) is unbuilt: G1 table+RLS+append-only triggers+`bankbot_logger` role+insert policy, G2 two read views, G3 RBAC seed + F3 catalogue entry, G4 emit helper, G5 live-EF wiring, then G6 the read EF. Shipping just the EF = non-functional stub (every call 500s on the missing relation). Per task contract, STOPPED rather than stub.

**Action for the team:** WUI-130 was marked DONE but its backing gateway slice does not exist — re-classify DONE → backend-blocked. This is a fresh multi-file schema-migration build (coordinate the migration with the existing `bb2_storage_buckets.sql` bucket ids `deposit-slips`/`bot-proof`, ON CONFLICT DO NOTHING). Not in scope for a CORS fix.

## Gate status
No Deno/tsc CI gate exists in this repo for `supabase/functions/**` (only `ui-detect.yml`, scoped to `admin-web/**`). No local deno binary to run `deno check`. Change is a mechanical wrapper mirroring an established deployed pattern; structurally verified (imports + balanced parens) against `admin-deposit` and the 23 existing `withCors` EFs.
