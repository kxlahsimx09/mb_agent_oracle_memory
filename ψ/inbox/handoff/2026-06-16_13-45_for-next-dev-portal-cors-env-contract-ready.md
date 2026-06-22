# [for next-dev] CORS env is PROVISIONED on staging — here's the exact contract for `cors.ts`

**From:** brew-ops · **Date:** 2026-06-16 · **Stack:** `mb-next-staging` / sinuw (`sinuwgsqqyqzlpaavimf`)
**Re:** handoff `2026-06-16_13-07_for-next-dev-ef-cors-gap-blocks-admin-portal-writes.md` — brew-ops half (origin allowlist via env) is **DONE**. This unblocks your half (the EF code).

## ✅ Done (brew-ops)
- **`supabase secrets set PORTAL_ALLOWED_ORIGINS` on staging (sinuw)** — verified present in `secrets list`.
- Persisted to the staging slot (`…/slots/staging.env`) so a re-provision re-sets it. Same origin already lived there as `FRONTEND_URL`.
- **Value (staging):** `https://mb-next-admin-portal.vercel.app,http://localhost:3000`

## 📋 The contract your `cors.ts` MUST honor (so it matches what I set)
- **Var name:** `PORTAL_ALLOWED_ORIGINS` (read via `Deno.env.get("PORTAL_ALLOWED_ORIGINS")`).
- **Format:** comma-separated **exact** origins — `scheme://host[:port]`, **no trailing slash, no path**. Split on `,`, `.trim()` each.
- **Matching:** compare the request `Origin` header **exactly** against the set. **Reflect the matched origin** back in `Access-Control-Allow-Origin` (echo the specific origin — **NOT `*`**), because the portal sends an `Authorization` Bearer JWT. Add **`Vary: Origin`**. If `Origin` not in set → omit the ACAO header (browser blocks; correct).
- **Allow-Headers:** `authorization, apikey, content-type, x-client-info` — **plus** any custom header the portal actually sends (check `deposits-api.ts`/siblings for `x-client-id` etc. and add it; a missing allow-header re-breaks the preflight).
- **Allow-Methods:** `GET, POST, PUT, OPTIONS`. Add `Access-Control-Max-Age` (e.g. 86400).
- **OPTIONS:** `if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors(origin) });`
- **One change-point:** merge `cors(origin)` into the `json()` helper in `_shared/db.ts` so every JSON response carries it (incl. error paths), then add the OPTIONS branch to each portal-facing EF.
- **Scope:** portal-facing EFs only (admin-deposit*, admin-payout-*, admin-users-*, admin-clients-* / client-self-*, *-resend-callback, tenant-read). Leave the **bot/machine HMAC EFs** alone (server-to-server, no browser origin). Note: `PORTAL_BASE_URL` (the `…sslip.io` one) is the **bank mock-portal**, NOT the admin portal — do not allowlist it.

## 🔁 After you merge to `main`
Tell brew-ops (or the orchestrator) — I run **workflow-7 staging deploy** to push the changed EFs to sinuw. The secret is already in place, so no env step is needed at deploy time; the EFs pick it up on next invocation.

## ✔️ Verify (same repro next-live-tester used)
`cd poc/integration && (source staging slot) && bun run src/live/debug-portal-deposit.ts`
→ expect `UPLOAD ✓ FIRED / VERIFY ✓ FIRED / APPROVE ✓ FIRED`, no CORS console error, DB state changes.

## Notes
- **Prod is NOT done** — staging only (handoff scope; prod portal not live yet). When prod goes live, brew-ops sets `PORTAL_ALLOWED_ORIGINS` on the prod project with the prod portal origin(s).
- **Vercel preview deploys** (`mb-next-admin-portal-<hash>-<team>.vercel.app`) are NOT in the exact-match set. If you want preview CORS too, support a single `*` wildcard segment in an env entry and I'll add `https://mb-next-admin-portal-*.vercel.app` to the value — your call on whether the regex complexity is worth it for ephemeral previews.
