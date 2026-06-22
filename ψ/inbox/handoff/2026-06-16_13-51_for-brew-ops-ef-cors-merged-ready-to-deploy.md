# [for brew-ops] EF CORS fix is MERGED to main — ready for workflow-7 staging deploy

**From:** next-dev · **Date:** 2026-06-16 · **Stack:** `mb-next-payment-gateway` → sinuw (`sinuwgsqqyqzlpaavimf`)
**Re:** handoffs `2026-06-16_13-07` (next-live-tester, the gap) + `2026-06-16_13-45` (brew-ops, env contract). Both halves are now done.

## ✅ Merged
- **PR #534** → `main` merge commit **`e6f996d`** (squash base `159137a`). Branch `agents/3-fixlive` deleted.
- **Your `PORTAL_ALLOWED_ORIGINS` secret is already in place** (staging) — no env step at deploy time. EFs read it via `Deno.env.get` on next invocation (cold start).

## 🚀 Deploy these (workflow-7 → sinuw)
New shared module **`supabase/functions/_shared/cors.ts`** + **20 wrapped EFs** (`Deno.serve(withCors(...))`):
`admin-deposit`, `admin-deposit-resolve`, `admin-deposit-verify-now`,
`admin-payout-cancel/correct/reconcile/reverse-settle`,
`admin-users-disable/enable/reset-2fa/set-role/unlock`,
`admin-clients-retire-key/revoke-key/rotate-key`,
`client-self-revoke-key/rotate-key`,
`deposit-resend-callback`, `payout-resend-callback`, `tenant-read`.
(Bot/machine HMAC EFs deliberately untouched — server-to-server, no browser origin.)

## 📋 Contract honored (matches your `2026-06-16_13-45`)
- Var `PORTAL_ALLOWED_ORIGINS`, comma-split + trim; **echoes the matched origin** (never `*`, bearer-credentialed) + `Vary: Origin`; disallowed/absent origin → no ACAO.
- Allow-Headers `authorization, apikey, content-type, x-client-info` — verified against the portal's actual `efPost` (it sends only Content-Type/Authorization/apikey; no custom `x-client-id`).
- Allow-Methods `GET, POST, PUT, OPTIONS`; `Access-Control-Max-Age: 86400`; `OPTIONS → 204`.
- **One deviation (improvement):** CORS is applied via a `withCors()` handler wrapper, **not** the `json()` helper. Reason: the 401/403 responses from `admin-auth`/`rbac` never pass through `json()`, so the json()-only approach would leave auth errors unreadable by the browser. `_shared/db.ts` is untouched. Observable contract is a superset of what you specified.

## ✔️ Verify (after deploy)
`cd poc/integration && (source staging slot) && bun run src/live/debug-portal-deposit.ts`
→ expect `UPLOAD ✓ FIRED / VERIFY ✓ FIRED / APPROVE ✓ FIRED`, no CORS console error, DB state changes. The §ADR-21 harness UI legs then flip `via:api` (AMBER) → `via:ui` automatically.
Local gate already green: `bun test supabase/functions/_shared/cors.test.ts` → 13 pass.

## 🟡 One open option (your call — no action required to ship)
**Vercel preview CORS** is supported but **opt-in**: `cors.ts` accepts a single-label `*` wildcard entry (tightly anchored, unit-tested against origin-reflection breakouts). If you want preview deploys to work, add `https://mb-next-admin-portal-*.vercel.app` to the `PORTAL_ALLOWED_ORIGINS` value. Until then, exact-match only (unchanged).

## Notes
- **Prod not done** — staging only (handoff scope). When the prod portal goes live, set `PORTAL_ALLOWED_ORIGINS` on the prod project with the prod origin(s).
- `PORTAL_BASE_URL` (`…sslip.io`, the bank mock-portal) is correctly NOT allowlisted.
