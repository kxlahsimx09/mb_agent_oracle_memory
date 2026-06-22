# [for next-dev / brew-ops] EF CORS gap — the admin portal CANNOT perform any write action from the browser

**From:** next-live-tester · **Date:** 2026-06-16 · **Stack:** `mb-next-staging` / sinuw (`sinuwgsqqyqzlpaavimf`)
**Severity:** HIGH — this is a real product defect (not test-only): the deployed admin portal is effectively **read-only from the browser**. It ALSO blocks the §ADR-21 owner directive ("human admin actions must walk the real UI path").

## Finding (one line)
**Every Edge Function (`/functions/v1/*`) returns NO CORS headers and does not handle the OPTIONS preflight**, so the deployed admin portal (`mb-next-admin-portal.vercel.app`), which calls the EFs via a **direct cross-origin browser `fetch`**, gets every write blocked by CORS.

## Evidence (a 1-minute standalone repro nailed it)
Tool: `poc/integration/src/live/debug-portal-deposit.ts` (provisions U-SA + a pending deposit, logs into the portal via the real form, clicks upload/verify/approve with network+console capture). Output:
```
PAGE-CONSOLE-ERR: Access to fetch at 'https://sinuw…supabase.co/functions/v1/admin-deposit'
   from origin 'https://mb-next-admin-portal.vercel.app' has been blocked [by CORS policy]
PAGE-REQ-FAILED:  POST https://sinuw…/functions/v1/admin-deposit  net::ERR_FAILED
UPLOAD  → slip_uploaded_at: null → null   ✗ NOT FIRED (CORS)
VERIFY  → button absent (no slip ⇒ verify-now hidden — a downstream symptom)
APPROVE → status: pending → pending        ✗ NOT FIRED (CORS); confirm modal stays open
```
The clicks FIRE correctly (modals open, the EF POST is attempted) — the browser kills it at the network layer.

## Root cause (verified in source)
- `grep -rl 'Access-Control-Allow-Origin' supabase/functions/` → **0 files**. No `_shared/cors.ts`; `admin-deposit/index.ts` has no OPTIONS branch.
- The portal calls EFs directly from the browser: `mb-next-admin-portal/src/lib/deposits-api.ts` →
  `efPost()` = `fetch(\`${NEXT_PUBLIC_SUPABASE_URL}/functions/v1/${path}\`, {method:'POST', …})` (e.g. `efPost("admin-deposit", …)`).
- Why login + reads still work: gotrue (`/auth/v1/*`) and PostgREST (`/rest/v1/*`) are **Supabase-managed** and send CORS; only the **custom Edge Functions** don't.

## Impact (all CORS-blocked from the portal browser)
admin-deposit (upload-slip/approve/force-approve/resolve), admin-deposit-verify-now, admin-payout-cancel/correct/reconcile/reverse-settle, admin-users-* / admin-users-set-role, admin-clients-* / client-self-*, deposit-resend-callback, payout-resend-callback, tenant-read — i.e. **every admin write a human operator would do**.

## Fix (next-dev — EF; brew-ops — origin allowlist)
1. Add **`supabase/functions/_shared/cors.ts`**: build CORS headers from an allowlist —
   `Access-Control-Allow-Origin: <portal origin if in allowlist>`, `Access-Control-Allow-Headers: authorization, apikey, content-type, x-client-info`, `Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS`, `Access-Control-Max-Age`.
2. In each portal-facing EF: `if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(origin) });` and **merge `cors(origin)` into every response** (incl. the `json()` helper in `_shared/db.ts` so it's one change-point).
3. **Origin allowlist (brew-ops, config/env):** `https://mb-next-admin-portal.vercel.app` + any preview/prod portal domains + `http://localhost:3000` for dev. Prefer an env (`PORTAL_ALLOWED_ORIGINS`) over hard-coding.
4. Keep the bot/machine HMAC EFs as-is unless the portal calls them (they're server-to-server, no browser origin).

## Verify
Re-run the repro: `cd poc/integration && (source the staging slot) && bun run src/live/debug-portal-deposit.ts`
→ expect `UPLOAD ✓ FIRED`, `VERIFY ✓ FIRED`, `APPROVE ✓ FIRED` (DB state changes; no CORS error). Then the §ADR-21 harness's UI-driven admin actions flip from `via:api` (AMBER fallback) to `via:ui` automatically — no harness change needed; the clicks already work.

## Notes
- Harness side is correct + safe: the live-test drives the real UI and falls back to the direct EF call when the UI action doesn't move the DB (records `via:"api"`, flags the leg AMBER "UI not proven"). Money path never breaks.
- `debug-portal-deposit.ts` is a reusable portal-UI diagnostic — keep it.
