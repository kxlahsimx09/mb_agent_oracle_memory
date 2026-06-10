---
to: brew-ops (CF custom-domain activation — owner-delegated 2026-06-10)
from: orchestrator-build (campaign simlive)
priority: P2
topic: Activate Supabase custom domain + CF orange-cloud for human-traffic WAF (GW1a-H) — HARDENING, not a SIM-LIVE blocker
project: github.com/kxlahsimx09/mb-next-payment-gateway
tags: [brew-ops, cloudflare, supabase, custom-domain, gw1a-h, simlive, staging, hardening]
---

# brew-ops task — activate CF-proxy-in-front-of-Supabase (GW1a-H)

**Owner GO 2026-06-10** ("CF proxy หน้า Supabase จริง") + GW1a-H amendment ratified. Full design: `/tmp/simlive/architect-cf-proxy-ruling.md`. This is an **env-swappable hardening layer — does NOT block the SIM-LIVE functional test** (Lane B runs on the raw `SUPABASE_URL` until you activate this).

## Mechanism (no Worker code)
Supabase **custom domain** (e.g. `api-staging.midasgo.co`) CNAMEd → `sinuwgsqqyqzlpaavimf.supabase.co`, **CF orange-cloud (Proxied)**. CF then fronts ALL services (PostgREST + gotrue + Realtime WS + EFs) with WAF/DDoS. CF proxies the Realtime WebSocket transparently.

## Activation checklist (from ruling §201)
1. **Supabase**: add custom domain `api-staging.midasgo.co` (dashboard, or Management API `PATCH /v1/projects/sinuwgsqqyqzlpaavimf/custom-hostname`; `SUPABASE_ACCESS_TOKEN` in slots/staging.env). Supabase shows the CNAME to add.
2. **CF DNS** (zone `midasgo.co` or agreed): `CNAME api-staging → sinuwgsqqyqzlpaavimf.supabase.co`, **orange-cloud**. SSL mode = **Full** (temporary).
3. Wait ~1–5 min for Supabase DNS-validation + TLS cert provisioning.
4. On Supabase "active", switch CF SSL → **Full (strict)**.
5. ⚠️ **JWT `iss` gotcha (REQUIRED):** activating the custom domain changes the gotrue JWT `iss` from `…sinuwgsqqyqzlpaavimf.supabase.co/auth/v1` → `…api-staging.midasgo.co/auth/v1`. Update **EF env `SUPABASE_URL`** in Supabase project secrets → `https://api-staging.midasgo.co` and redeploy (or cold-start). Verify `_shared/auth.ts verifyGotrueJwt` does NOT pin the old issuer literally. Anon key + JWKS signing keys are project-bound → unchanged.
6. **Portal env**: update `NEXT_PUBLIC_SUPABASE_URL` → `https://api-staging.midasgo.co` in the Vercel staging env (Lane B PR #7 preview). Coordinate with next-ui — single env-swap, zero code change.
7. **Smoke**: login → read v_deposits → Realtime subscribe → EF write, all via the custom domain.
8. **WAF rules** (ruling §5): CF OWASP **Low** (PostgREST filter params false-positive at Med/High; whitelist `/rest/v1/*`), Bot Fight Mode, **fail-open** rate-limits (Log+Challenge, NOT Block, for SIM-LIVE) on `/auth/v1/token*` (10/min), `/rest/v1/*` (300/min), `/functions/v1/*` (60/min), `/realtime/v1/*` (20 conn/min). Promote to Block after the golden journey confirms clean. DO NOT cache `/auth|/rest|/realtime|/functions` or modify Authorization/apikey/CORS/Upgrade headers.

## Access note
Steps 1–2 + 8 need owner-controlled Supabase dashboard + CF zone access. If brew-ops holds the CF API token + the Supabase PAT (SUPABASE_ACCESS_TOKEN), it can do steps 1, 5 (Management API) + CF DNS/WAF via CF API. Else escalate the dashboard steps to the owner.

§ADR-7 (machine-actor GW4 Worker) is UNCHANGED — the GW4 Worker stays on its own hostname, NOT behind this custom domain.
