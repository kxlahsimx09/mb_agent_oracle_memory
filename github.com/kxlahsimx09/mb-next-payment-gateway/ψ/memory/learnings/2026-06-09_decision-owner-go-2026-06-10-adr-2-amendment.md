---
title: DECISION (owner GO 2026-06-10) — §ADR-2 §Amendment GW1a-H RATIFIED: human-traffi
tags: [decision, adr, cloudflare, supabase, custom-domain, gw1a-h, realtime, simlive, ratified]
created: 2026-06-09
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DECISION (owner GO 2026-06-10) — §ADR-2 §Amendment GW1a-H RATIFIED: human-traffi

DECISION (owner GO 2026-06-10) — §ADR-2 §Amendment GW1a-H RATIFIED: human-traffic CF proxy via Supabase custom domain. Cloudflare fronts ALL Supabase human-traffic surfaces (PostgREST + gotrue + Realtime WS + Edge Functions) via a Supabase custom domain (e.g. api-staging.midasgo.co) CNAMEd to the project + CF orange-cloud — NOT via the GW4 Worker (machine-actor only) and NO new Worker code. CF orange-cloud proxies the Realtime WebSocket transparently (WAF on the WS handshake the GW4 Worker could not give). Env-swappable: a single SUPABASE_URL change (raw sinuwgsqqyqzlpaavimf.supabase.co → custom domain), zero client code change, anon key + JWKS unchanged. REQUIRED gotcha: activation flips the gotrue JWT `iss` claim, so the EF `SUPABASE_URL` env must be updated to the custom domain (and verifyGotrueJwt must not pin the old issuer). WAF posture = OWASP Low (PostgREST filter-param false-positives at Med/High) + fail-open rate-limits for SIM-LIVE. Does NOT change §ADR-7 (machine-actor GW4 model unchanged). Same identity-agnostic principle as §ADR-2 EA1–EA4. Architect ruling: /tmp/simlive/architect-cf-proxy-ruling.md §6. The formal ADR note + the brew-ops activation are the follow-through. Context: campaign simlive (wiring admin-portal → staging for the §ADR-21 SIM-LIVE deposit+auth golden journey).

---
*Added via Oracle Learn*
