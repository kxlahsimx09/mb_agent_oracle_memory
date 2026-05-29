---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: GO build CF gateway-in-front PoC end-to-end (user-authorized cross to next-dev/gateway-impl lanes for THIS PoC; impl+local-verify only)
context: see thread #254 msg 1216 (full brief). msg-1210/1212 superseded by §ADR-2 §Amendment 2026-05-28 (PR #272). Authoritative spec = docs/client-api-gateway/README.md (PR #273, commit 587cd86) — pinned: EdDSA/jose JWT, rh-bound claim, keyring, KV layout/TTL, /internal/invalidate, schema. CF bootstrap done (msg 1215): account 5ca95150…, KV CLIENT_CACHE=e2a45d10…, Hyperdrive=d2c894ee… (loadtest Supabase origin). CF creds at ~/.arra-oracle-v2/fleet-secrets/mb-next-loadtest/cloudflare.env + cloudflare_onetime.env. Build 5 parts: (1) migrations (api_key_secret+rate_limit_overrides cols, /internal/invalidate trigger, seed); (2) CF Worker (Hono, KV+RL+Hyperdrive, HMAC verify, mint EdDSA GW4 w/ rh); (3) EF _shared/gateway-assertion.ts verify + drop client-cred stubs; (4) driver HMAC signing pointed at CF Worker; (5) local-verify (wrangler dev + supabase functions serve). Substrate-feasibility goal (not ratifiable). User authorized lane-cross for THIS PoC; promotion=next-dev later (P-001 mark). Scope=IMPLEMENT+LOCAL-VERIFY ONLY (no hosted deploy — brew-ops's next leg). Self-sequence PRs.
needs_response: true
priority: normal
created: 2026-05-28T10:20:00+07:00
---

Full brief in thread #254 (msg 1216). Build the 5 parts per the authoritative spec (`docs/design/client-api-gateway/README.md`) + CF bootstrap IDs (msg 1215). User-authorized cross into next-dev/gateway-impl lanes for THIS PoC; impl+local-verify only (no hosted deploy). Reply with PR(s) + per-component wiring + local-verify result + readiness for brew-ops deploy leg (Worker secrets + Supabase GW4_VERIFY_KEYS env).
