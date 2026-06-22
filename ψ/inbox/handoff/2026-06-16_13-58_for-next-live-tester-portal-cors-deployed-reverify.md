# [for next-live-tester] EF CORS gap is FIXED + DEPLOYED to staging — please re-run the repro

**From:** brew-ops · **Date:** 2026-06-16 · **Stack:** `mb-next-staging` / sinuw (`sinuwgsqqyqzlpaavimf`)
**Closes:** your handoff `2026-06-16_13-07_for-next-dev-ef-cors-gap-blocks-admin-portal-writes.md`.

## Done (both halves)
- **brew-ops (env):** `PORTAL_ALLOWED_ORIGINS` set on sinuw = `https://mb-next-admin-portal.vercel.app,http://localhost:3000` (verified in `secrets list`; persisted to staging slot).
- **next-dev (code):** PR #534 merged — `_shared/cors.ts` `withCors()` on the **20 portal-facing EFs**.
- **brew-ops (deploy):** workflow-7 deploy-all sweep → sinuw (51 EFs ACTIVE). Manifest/evidence PR **#536** (await owner merge — deploy already live, PR is the record).

## Already verified live (so you should see green)
`OPTIONS` preflight to `…/functions/v1/admin-deposit`:
- `Origin: https://mb-next-admin-portal.vercel.app` → `204` + `Access-Control-Allow-Origin` echoes the origin (not `*`), `Vary: Origin`, allow-headers `authorization, apikey, content-type, x-client-info`.
- `Origin: https://evil.example.com` → `204`, **no** ACAO (correctly blocked).

## Your move
Re-run the repro: `cd poc/integration && (source staging slot) && bun run src/live/debug-portal-deposit.ts`
→ expect `UPLOAD ✓ FIRED / VERIFY ✓ FIRED / APPROVE ✓ FIRED`, no CORS console error, DB state changes. The §ADR-21 harness UI legs should flip `via:api` (AMBER) → `via:ui` automatically — **no harness change needed**.

## Heads-up
- If any portal EF still preflights-fail, check whether the portal sends a custom header not in the allow-list (`authorization, apikey, content-type, x-client-info`) — e.g. `x-client-id`. If so, ping next-dev to add it to `cors.ts ALLOW_HEADERS` (no env/redeploy-of-secret needed; just an EF code change + redeploy).
- **prod** is NOT done (staging only). brew-ops sets the same secret + deploys when the prod portal goes live.
