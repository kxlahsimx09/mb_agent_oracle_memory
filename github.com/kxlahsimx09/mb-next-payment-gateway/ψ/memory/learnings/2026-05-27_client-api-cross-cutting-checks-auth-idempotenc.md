---
title: Client-API cross-cutting checks (auth / idempotency / rate-limit) live IN the Ed
tags: [system-architect, repo:mb-next-payment-gateway, next, architecture, api-design, load-harness, perf-slo, edge-function, middleware, rate-limit, idempotency, auth, decision, thread-216]
created: 2026-05-27
source: docs/adr.md §ADR-1/2/7/11 (direct reads); poc/integration/src/gateway + supabase/functions/_shared; thread #216 msg 1208/1209
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Client-API cross-cutting checks (auth / idempotency / rate-limit) live IN the Ed

Client-API cross-cutting checks (auth / idempotency / rate-limit) live IN the Edge Function ingress middleware chain — there is NO production gateway tier; a gateway is explicitly REJECTED. And the PoC stubs two of the three, so PoC capacity numbers are optimistic.

Context (thread #216 §C.7 gating question, 2026-05-27): before picking a §C.7 hosted-load topology — (a) EFs-carry-the-checks vs (b) a hosted Bun-gateway-in-front — the user challenged whether the architecture even ratifies WHERE the rate-limit / auth-RBAC-RLS / idempotency checks live in production, and on what substrate ("the Bun PoC gateway doesn't look like the real thing"). Grounded by direct reads of docs/adr.md (vector index degraded) + the PoC code.

PLACEMENT IS PINNED BY THE ADRs (not a gap) — all three concerns are EDGE-FUNCTION INGRESS MIDDLEWARE, Postgres substrate, NO separate gateway:
- §ADR-1 (adr.md:10): "API endpoints are Edge Functions." Business logic in EFs; only atomic wallet mutations in thin PL/pgSQL (§ADR-3).
- §ADR-2 (:20/:28/:38): RLS Layer-1 = data isolation at the DB; RBAC Layer-2 = "enforced at application layer (Edge Function middleware), NOT in RLS" via check_permission(). §ADR-2 G5-D (:55) is decisive: the middleware chain runs INSIDE the EF (`JWT verify → IP allowlist → RBAC → handler`) and a GATEWAY TIER IS EXPLICITLY REJECTED — "Gateway-level rejected — no DB lookup access, breaks DB-fresh principle of §ADR-2 base C4." So "edge-layer" in the ADRs = the Supabase EDGE FUNCTION, NOT a CDN/gateway/reverse-proxy.
- §ADR-7 (:1708 "API Key Authentication via Edge Function Middleware", :1714-1716): client-API auth = API-Key+HMAC validated in "Custom middleware in Edge Functions"; on success the EF uses service_role to act on behalf of the client; "Rate limiting implemented via Postgres counter (no Redis needed)."
- §ADR-11 D5 (:2450): idempotency = "Shared middleware in Edge Function (parallel to §ADR-7 API-Key middleware)," no-opt-out; D2 (:2440-2441) dedup in a Postgres `idempotency_keys` table UNIQUE(client_id,key), Redis ruled out.
- §ADR-11 §Amendment A3 RL1 (:2506): per-client rate-limit "realized at the edge/authentication layer ... the same shared client-API ingress boundary" as the §ADR-7 API-key + §ADR-11 idempotency middleware, "before any payment business logic or atomic RPC runs"; RL3 (:2510) substrate = impl-choice (PG counter / Supabase-native / edge-KV), fail-open; adds no PL/pgSQL surface.

SHARPENING for the client-CREATE hot-path: the deposit/payout create path authenticates by API-Key+HMAC (§ADR-7) and runs via service_role on behalf of the client — so RBAC + RLS (the ADD-4 "auth/RBAC/RLS" concern) are the ADMIN/JWT surface, NOT the machine create path. On the create hot-path, "the checks" = §ADR-7 API-Key+HMAC + §ADR-11 idempotency + §ADR-11-A3 rate-limit. (§ADR-2 G6-D / §ADR-7 / §ADR-2-Amdt S2 all confirm machine flows are API-Key, not human-RBAC.)

THE PoC "Bun gateway" IS A LOCAL-DEV TWIN, NOT A PRODUCTION TIER: `poc/integration/src/gateway/server.ts` (Hono on Bun :3010) runs the same middleware+handler chain locally; it is NOT a proxy in front of the EFs, and the HOSTED runs don't use it at all (`driver.ts` hits the hosted EFs directly when GATEWAY_URL=$SUPABASE_URL/functions/v1). So the production "real thing" is the EF middleware chain; the Bun gateway is just its local equivalent.

→ FAITHFUL §C.7 TOPOLOGY = (a) EFs-carry-the-checks. (b) hosted-Bun-gateway-in-front is UNFAITHFUL BY CONSTRUCTION — it invents the very tier §ADR-2 G5-D rejects. Never measure a "production-faithful" capacity number on (b).

THE REAL GAP IS PoC FIDELITY INSIDE THE EF (not placement): the hosted create EFs (supabase/functions/deposits-create + _shared/) today — auth is STUBBED (`_shared/auth.ts` does a plaintext X-Client-Id lookup, no §ADR-7 HMAC; self-labelled "Real production = §ADR-7 API-Key full RBAC"), JWT gate BYPASSED (`--no-verify-jwt`, anon-key pass-through), rate-limit ABSENT (§ADR-11-A3 not in path). Idempotency IS implemented & faithful (§ADR-11 C5 header-required + C4 409 + idempotency_keys dedup). Consequence: a §C.7 run on the current EFs is missing the HMAC-verify CPU cost + the rate-limit counter write — both add per-request CPU + a small DB write → they LOWER the shared-CPU/burst-credit ceiling, so the current PoC OVER-ESTIMATES production capacity.

RECOMMENDATION (escalated to user via orchestrator): no placement ratification needed (already pinned). Run §C.7 on topology (a). For a RATIFIABLE production-faithful capacity number, first complete the create-EF middleware to production shape — real §ADR-7 API-Key+HMAC verify + §ADR-11-A3 Postgres-counter rate-limit (idempotency already faithful). Two options: (A) fidelity-first = add HMAC+rate-limit then run [recommended for a ratifiable number]; (B) run-now + scope the number as "create handler + idempotency + atomic RPC capacity, EXCLUDES auth-HMAC + rate-limit cost (both O(1)/small, would modestly lower the ceiling)."

Durable rule: when judging whether a perf/capacity harness is "production-faithful," verify the cross-cutting MIDDLEWARE (auth/HMAC, idempotency, rate-limit) is actually in the measured request path — a stubbed-auth / no-rate-limit harness over-states capacity. And don't add an architecture tier (gateway) the ADRs reject just to host the checks; the EF IS the ingress. Companion to [[2026-05-27_shared-burstable-compute-family-insight-a-bigger]] (the §C.7 compute side) and the §D verdict learnings.

---
*Added via Oracle Learn*
