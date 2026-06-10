---
to: orchestrator-build (next session) + brew-ops + owner
from: orchestrator-build 2026-06-10
priority: P3
topic: DECISION — staging runs on the RAW Supabase URL; custom-domain swap is pending a real domain from owner (vanity is a dead end)
project: github.com/kxlahsimx09/mb-next-payment-gateway
tags: [staging, supabase, custom-domain, vanity, gw1a-h, raw-url, decision, pending-domain]
---

# DECISION (owner, 2026-06-10): staging stays on the raw Supabase URL

Staging is **not public-facing**, so no Cloudflare/WAF is needed there. Project `sinuwgsqqyqzlpaavimf` (mb-next-staging) runs on `https://sinuwgsqqyqzlpaavimf.supabase.co`. EF / `slots/staging.env` / portal Vercel `NEXT_PUBLIC_SUPABASE_URL` all on the raw URL — verified intact (nothing was flipped). **No action needed until a real domain arrives.**

## Why not a vanity subdomain (closed — do NOT retry)
Tried the free Supabase vanity subdomain `mb-next-staging.supabase.co`; **BLOCKED + rolled back clean.** A vanity subdomain routes the host (PostgREST/Realtime/JWKS all 200) but does NOT rewrite the gotrue JWT `iss` (stays `<ref>.supabase.co`, re-checked 3× over ~2min). The EF pins `GOTRUE_ISSUER = ${SUPABASE_URL}/auth/v1` (`supabase/functions/_shared/auth.ts:43,89`), so flipping `SUPABASE_URL`→vanity would 401 all human auth. Full detail: Oracle learning `2026-06-10_supabase-free-vanity-subdomain-does-not-rewrite-th`.

## When owner supplies a real domain → custom-domain swap (turnkey checklist)
The ONLY hostname path that carries through to JWT `iss` is a Supabase **custom domain** (paid CNAME) — it updates `API_EXTERNAL_URL`/issuer. This IS the GW1a-H custom-domain path (also gets the CF WAF half for free). Preconditions to gather BEFORE dispatching:
1. **A real registered domain on Cloudflare** (any domain; ADR says "midasgo.co or agreed"). Owner adds the zone to CF + switches NS at the registrar. `midasgo.co` today is NOT on CF (NS = dyna-ns.net).
2. **A VALID Cloudflare API token**, scope: Zone·DNS·Edit + Zone·Ruleset/WAF·Edit on that zone. The two tokens on disk are INVALID/expired (`mb-next-loadtest/cloudflare.env` API_TOKEN → "Invalid API Token"; `slots/tester.env` CF_API_TOKEN → no valid response). Store the fresh one as `CF_API_TOKEN` + `CF_ACCOUNT_ID` + `CF_ZONE_ID` in `slots/staging.env`.
3. **Enable the Supabase "Custom Domain" add-on** on `sinuwgsqqyqzlpaavimf` (paid; the Management API custom-hostname endpoint returns "Please enable the Custom Domain add-on for the project first" until this is on).

Already-confirmed-ready: the Supabase PAT in `slots/staging.env` (`SUPABASE_ACCESS_TOKEN`) works + has access to the staging project; ANON/SERVICE_ROLE/PROJECT_REF all present.

Then run the GW1a-H activation runbook (handoff `2026-06-09_06-28_simlive-brewops-cf-custom-domain-activation` / architect-cf-proxy-ruling §201 + the merged §ADR-2 GW1a-H amendment, PR #367): add Supabase custom hostname → CF CNAME orange-cloud (SSL Full→Full-strict) → **update EF `SUPABASE_URL` BEFORE/at activation** (iss alignment) → portal env swap → 5 smokes (JWKS / login-iss==domain / v_deposits RLS / EF write / Realtime). **Verify the iss-rewrite empirically (login + decode) before flipping any EF `SUPABASE_URL`** — same guard that caught the vanity dead end.

## Session tail status (for continuity)
- GW1a-H §ADR-2 amendment: **PR #367 OPEN**, awaiting owner merge.
- next-live-tester 6th-role registration: committed `2ff5259` (memory repo), maw wake resolves.
- Staging: raw URL, intact. GW1a-H WAF deferred (above).
