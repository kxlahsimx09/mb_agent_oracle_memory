---
title: Supabase FREE vanity subdomain does NOT rewrite the gotrue JWT issuer — it canno
tags: [supabase, gotrue, jwt-issuer, vanity-subdomain, custom-domain, staging, gw1a-h, auth]
created: 2026-06-10
source: brew-ops vanity cutover (campaign simlive) 2026-06-10
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Supabase FREE vanity subdomain does NOT rewrite the gotrue JWT issuer — it canno

Supabase FREE vanity subdomain does NOT rewrite the gotrue JWT issuer — it cannot replace a custom domain for any EF that pins `iss`.

CONTEXT: campaign simlive / GW1a-H. Owner wanted a stable staging hostname without buying a domain, so we tried activating the free Supabase vanity subdomain `mb-next-staging.supabase.co` on project `sinuwgsqqyqzlpaavimf` and re-pointing `SUPABASE_URL` everywhere.

WHAT BREAKS: The EF verify path derives `GOTRUE_ISSUER = ${SUPABASE_URL}/auth/v1` and enforces it via jose (`supabase/functions/_shared/auth.ts:43,89,96`). A vanity subdomain routes the HOST (PostgREST, Realtime WS, JWKS all answer 200 on the vanity host) BUT gotrue keeps minting `iss = https://<ref>.supabase.co/auth/v1` (canonical ref, re-checked 3× over ~2min — not propagation lag). So flipping EF `SUPABASE_URL`→vanity sets the expected issuer to the vanity while every real token still carries iss=raw → `verifyGotrueJwt` would 401 ALL human-auth EF traffic. Smoke #2 (login → assert iss==vanity) fails by design; smokes #1/#3/#5 (JWKS, PostgREST read, Realtime) pass because those are host-routed, not iss-bound.

RULE: vanity subdomain == cosmetic host alias only. It updates neither `API_EXTERNAL_URL` nor the JWT `iss`. Do NOT retry the vanity cutover for an iss-pinning stack — it cannot satisfy the iss smoke.

THE ONLY hostname path that carries through to JWT `iss`: a Supabase **CUSTOM DOMAIN** (paid add-on, real CNAME) — custom domains DO update API_EXTERNAL_URL/issuer. That is the GW1a-H custom-domain path (also needs the domain on Cloudflare + a valid CF token for the orange-cloud/WAF half). Until a real domain is available, staging stays on the raw `<ref>.supabase.co` URL (works fine; staging is not public-facing so no WAF needed).

OPS: rollback is clean — `DELETE /v1/projects/<ref>/vanity-subdomain` reverts to not-used; if you never flipped EF/slot/portal, net state == pre-dispatch. Always verify the iss-rewrite claim empirically (login + decode) BEFORE flipping any EF SUPABASE_URL.

---
*Added via Oracle Learn*
