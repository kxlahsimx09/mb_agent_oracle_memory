---
title: p2p-hub §H/⟦S6⟧ — Provider-facing HTTP API + provider auth design (RATIFICATION_
tags: [p2p-hub, provider-api, auth, PI-7, outbound-dispatcher, elysia, design]
created: 2026-06-02
source: system-architect §H/⟦S6⟧ design pass
project: github.com/kxlahsimx09/p2p-hub
---

# p2p-hub §H/⟦S6⟧ — Provider-facing HTTP API + provider auth design (RATIFICATION_

p2p-hub §H/⟦S6⟧ — Provider-facing HTTP API + provider auth design (RATIFICATION_PENDING:9, PR #25, thread #9, 2026-06-02).

THE GAP (P-004): substrate RPCs + §G verify service are hosted-verified, but there is NO provider-facing HTTP API and NO provider auth. Two structural holes: (1) every provider-facing RPC trusts the provider as a PARAMETER (submit_pool_item(p_provider_id,…), accept_match(p_match_id,p_side)) — nothing binds caller→provider_id, so PI-7 ("no unsigned message is actioned", §C2) is UNENFORCED. (2) outbound_messages (001_supporting_stubs.sql:60) is ENQUEUED by RPCs (propose_match writes 2x MatchProposed; settle_p2p_match writes 2x MatchSettled — 009/004 migrations) but has NO CONSUMER — providers can't RECEIVE MatchProposed/TransferInstruction/MatchSettled (PI-3 dispatcher deferred). These two are what block "a real usable API".

4 DESIGN DECISIONS (each ratify): (1) API surface = /v1/provider/* REST-over-RPC, mobiz {success,data,message,error} envelope + TypeBox, one endpoint per §C12 P→H message + status/poll; provider derived from AUTH not the body (RPC p_provider_id/p_side params stay, HTTP layer fills them from the authenticated key). (2) Auth ⟦S6⟧ = per-provider HMAC-SHA256 signed requests for Phase 1, Ed25519 RESERVED as upgrade path (provider_keys.algo discriminator ⇒ additive). KEY INSIGHT: PI-7 already pins SIGNED messages, so the only open question is the scheme. The mb-next GW4 Ed25519 precedent (ADR-1 docs/adr.md:40-43 quoting mb-next ADR-2 :119-155) is a DIFFERENT shape — Ed25519 there solves a GATEWAY→BACKEND assertion hop (CF Worker mints, EF verifies w/o the client secret); the CLIENT-facing leg in mb-next is HMAC, and that's the leg p2p-hub's provider API IS. p2p-hub has no gateway hop today (ADR-1 Q2 demand-gates CF). So the precedent, read precisely, SUPPORTS HMAC for provider→hub + reserves Ed25519 for when a gateway hop is interposed. provider_keys shape: (provider_id, key_id, algo, secret_hash|public_key, status ACTIVE|REVOKED, created/revoked_at), append-only rotation. (3) Runtime = Elysia Bun app src/routes-elysia/provider/* (CLAUDE.md Hono→Elysia, maw-js ref) on the ADR-1 D1 Supabase backbone — NOT 13 isolated Deno EFs. ADR-1 Q2 ANSWER: the provider API does NOT ungate the CF Worker — it's authenticated/allow-listed/low-cardinality (vetted B2B set), NOT the public-DDoS demand driver; CF+GW4 stays RESERVED. (4) Outbound PI-3 = BOTH phased — poll inbox first (GET /inbox + ack over outbound_messages, zero new egress, usable now), webhook push 1.5 GATED on the same ADR-1 D3 ECS/Fargate→NAT-GW→EIP egress the Thunder mock→real switch stands up (hub outbound fetch hits the same no-static-IP wall as §C8 Thunder).

IMPL SCOPE (next-impl, not the design PR): NEW = provider_keys migration, outbound_messages expand (status/attempts/idempotency_key), PI-6 read view over matches, §C4 optin/optout RPCs (gate FIELDS exist in 006, the RPCs are deferred), the Elysia app + HMAC middleware + PI-3 inbox worker/dispatcher + register key-issuance service + nested tests/http/<cluster>/*.test.ts. REUSE = the 11 wired RPCs + src/verify/service.ts + mobiz envelope + the §E2 ACTIVE+serves gate (stays inside RPCs). DEFERRED related ⟦S6⟧ = liability_terms + §C3 human vetting, Ed25519/GW4 CF tier (ADR-1 Q2 driver), webhook egress wiring.

REFS: §C3 (keypair/registration), §C12 (message catalogue = endpoint list), §C2 PI-2/PI-3/PI-7, §E2 (006_providers_expand ACTIVE+serves gate), §G5 (admin-approve-topup HTTP-over-RPC + envelope precedent), §F.5 ⟦S6⟧ (provider_keys + liability_terms + vetting), ADR-1 docs/adr.md (D1 backbone, D2/Q2 CF demand-gate, D3 egress). CROSS-DB CAVEAT: mb-next ADR-2/GW4 lives in kxlahsimx09/mb-next-payment-gateway's SEPARATE ADR namespace (docs/adr.md:119-155, quoted via p2p-hub's own ADR-1); p2p-hub §H + ADR-1 are independent numbering. Oracle thread #9, PR #25.

---
*Added via Oracle Learn*
