---
title: CF gateway-in-front PoC delivered end-to-end (thread #254 msg 1216→1217, PR #274
tags: [implementation-architect, repo:mb-next-payment-gateway, next, poc, thread-254, cf-gateway, gw4-eddsa-jose, rh-binding, hmac-verify, kv-cache, hyperdrive, internal-invalidate, cf-workers-io-isolation, supabase-migration-chain-gap, no-verify-jwt, p-001-lane-cross, next-dev, gateway-impl, handoff]
created: 2026-05-28
source: PR #274 on github.com/kxlahsimx09/mb-next-payment-gateway; local-verify on local Supabase :54322; thread #254 msg 1216→1217
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# CF gateway-in-front PoC delivered end-to-end (thread #254 msg 1216→1217, PR #274

CF gateway-in-front PoC delivered end-to-end (thread #254 msg 1216→1217, PR #274, 2026-05-28) — impl+local-verify only.

User-authorized lane-cross into next-dev + gateway-impl (P-001 mark on every file) per the spec at docs/design/client-api-gateway/README.md (§ADR-2 §Amendment 2026-05-28, EdDSA/jose JWT with rh-bound claim, KV layout, /internal/invalidate, schema). 5 parts shipped: migration (client.api_key_secret + rate_limit_overrides + gateway_config + client_invalidate_webhook trigger via pg_net), CF Worker (gateway/cf-worker/: Hono + jose + postgresjs; HMAC verify → KV cache → Hyperdrive miss → rate-limit → mint EdDSA GW4 → forward; plus /internal/invalidate), EF _shared/gateway-assertion.ts (verifyAssertion per spec §1.5), driver LOAD_SIGN_REQUESTS=1 signing, gen-keypair + verify-local scripts.

Durable cross-cutting learnings (worth future-recall):

1. **CF Workers I/O isolation kills cached postgresjs.** postgresjs caches connections at module scope by default; CF Workers throws "Cannot perform I/O on behalf of a different request" the second request reuses it. Fix: create `postgres(...)` INSIDE the request handler, call `c.executionCtx.waitUntil(sql.end({timeout:5}))` to clean up. Spec said little; this is a real workarea pattern.

2. **Local Supabase DB chain is partial.** `supabase start` populates the local postgres DB but only 71/106 migrations are present in this worktree's local state. So an end-to-end verify hitting create_deposit on the local DB 500s with "Could not find function create_deposit(p_amount, p_callback_url, ...)" — the latest RPC signature isn't there. NOT a chain/auth bug; brew-ops db push on Micro resolves. For local-verify of the gateway+EF chain auth-side, this is fine (auth verifies before RPC); for full lifecycle, apply the full chain to a dedicated DB (which is hard because pg_cron jobs are wired to a single cron.database_name — same issue all dedicated-DB harnesses face; either skip pg_cron migrations or stub cron.schedule).

3. **`supabase functions serve` enforces platform JWT by default.** Must add `--no-verify-jwt` for the Worker→EF flow to work locally (the Worker isn't passing a platform Bearer; it passes only X-Gateway-Assertion). Same as the hosted production design (brew-ops drops --no-verify-jwt for prod EFs; until the platform-JWT/GW4 dual-trust story is settled, --no-verify-jwt is the cleanest local mirror).

4. **client.role column gap on production substrate.** Prior ADD-4 (#271) added `role` to poc/integration's twin substrate only; supabase/migrations/ doesn't have it. Spec §2.1 lists `role` on ClientCache as "unused by gateway hot-path; carried for completeness" — the Worker SELECTs without role and defaults at the cache layer ('client_api'). If next-dev later adds the migration, the Worker can include it. Worth-noting for any future code that does `SELECT * FROM client` expecting role.

5. **Brew-ops deploy half (the hosted leg) is genuinely 4 steps**: (a) wrangler secrets (GW4_SK_k1 + INVALIDATE_SECRET) + deploy; (b) EF env GW4_VERIFY_KEYS public-JWK map; (c) PG seed of gateway_config (URL + INVALIDATE_SECRET shared with Worker); (d) full migration chain push on Micro so create_deposit signature matches the EF call. The §C.7 driver then sets GATEWAY_URL=https://<worker>/ + LOAD_SIGN_REQUESTS=1.

6. **Local-verify shape that actually exercised the chain**: wrangler dev --local (with .dev.vars for GW4_SK_k1 + INVALIDATE_SECRET) + supabase functions serve --env-file (with GW4_VERIFY_KEYS) + node verify-local.mjs sending signed/unsigned/bad-sig + a short bun-driver run. Hyperdrive's localConnectionString points at 127.0.0.1:54322/postgres (the local Supabase DB).

Lane note (P-001): every file carries a comment marking next-impl as author under the user lane-cross + earmark for next-dev/gateway-impl promotion review.

---
*Added via Oracle Learn*
