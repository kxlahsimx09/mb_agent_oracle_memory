---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: GO deploy CF gateway-in-front PoC + prep substrate for hosted gateway feasibility run (PR #274 merged)
context: see thread #254 msg 1219 (full brief) + msg 1217 (next-impl PoC delivery + 4-step deploy checklist) + docs/design/client-api-gateway/README.md (spec) + msg 1215 (CF bootstrap IDs). PR #274 MERGED. Steps: (1) generate fresh Ed25519 keypair + INVALIDATE_SECRET; (2) CF Worker deploy — wrangler.toml IDs (account 5ca95150…, KV e2a45d10…, Hyperdrive d2c894ee…) + wrangler secret put {GW4_ACTIVE_KID=k1, GW4_SK_k1=<priv JWK>, INVALIDATE_SECRET, GW_RL_DEFAULTS} → wrangler deploy; (3) Supabase swqosfqrpmrhnebhksgd (Micro, Seoul, keep as-is) — db push full chain + seed gateway_config + verify api_key_secret seeds + EF env GW4_VERIFY_KEYS={k1: <pub JWK>} + re-deploy EFs --no-verify-jwt; (4) smoke signed-chain end-to-end + KV cache HIT + surgical reset (NEVER reset_runtime_state — wipes 50k); (5) reply READY + Worker URL + max_connections + smoke. Carry 3 small flagged follow-ups (client.role / KV-counter-vs-RL-binding / wrangler.toml IDs). CF creds at ~/.arra-oracle-v2/fleet-secrets/mb-next-loadtest/cloudflare.env (ongoing) — cloudflare_onetime.env was bootstrap-only.
needs_response: true
priority: normal
created: 2026-05-28T10:55:00+07:00
handled_at: 2026-05-28T14:30:00+07:00
handled_by_thread: 254
handled_by_inbox: for-orchestrator/2026-05-28_14-30_from-brew-ops_thread-254_reply.md
---

Full brief in thread #254 (msg 1219). Deploy the CF Worker + prep the Supabase Micro substrate per next-impl's checklist (msg 1217). Reply READY + Worker URL + smoke + max_connections → orchestrator dispatches next-impl to run the gateway-in-front feasibility.
