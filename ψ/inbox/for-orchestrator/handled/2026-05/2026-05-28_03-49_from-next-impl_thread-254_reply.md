---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: CF gateway-in-front PoC DELIVERED end-to-end — PR #274 open; brew-ops handoff for §C.7 Medium ready
needs_response: true
priority: normal
created: 2026-05-28T03:49:00+07:00
handled_at: 2026-05-28T10:53:00+07:00
handled_by_thread: 254
handled_note: >
  CF gateway-in-front PoC delivery (PR #274) relayed to user. State-grounding caught a
  MAJOR architecture pivot (12+h gap, 5 new messages 1213-1217): user directed §ADR-2
  §Amendment 2026-05-28 merging PR #272+#273 (relocate auth/rate-limit out of EF into a
  CF gateway tier); my msg-1212 i/ii/iii escalation became moot. next-impl then delivered
  the PoC end-to-end per msg 1216's user-authorized scope. PR #274 verified via gh:
  OPEN/MERGEABLE/non-draft. Local-verify all-green except an expected substrate-chain gap
  (local 71/106 migrations → create_deposit 500; resolves on brew-ops full chain apply).
  Relayed PR + brew-ops deploy checklist (4 steps) + 3 small follow-ups + 2 user calls
  (merge + dispatch GO) to user via Telegram (chat 2002026175, msg id 38) at
  2026-05-28T10:53+07:00. Trace marker posted to thread #254 (msg 1218). Thread left
  pending; brew-ops dispatch deferred until user merges + signals GO. No reply envelope
  to next-impl (it has delivered + is idle/available for the Medium-run leg later).
---

All 5 parts implemented + local-verified vs `docs/design/client-api-gateway/README.md`. PR #274 https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/274 (branch `next-impl/perf-cf-gateway-poc`, off origin/main, c125344). Thread #254 msg 1217 has the full table.

**Wired (P-001 lane-cross mark on all):** (1) migration adds `client.api_key_secret` + `rate_limit_overrides` + `gateway_config` + `client_invalidate_webhook` trigger; (2) CF Worker `gateway/cf-worker/` does HMAC verify → KV cache (per-request postgresjs) → Hyperdrive miss → rate-limit → mint EdDSA GW4 (jose, alg pinned, rh-bound) → forward + `/internal/invalidate`; (3) EF `_shared/gateway-assertion.ts` per spec §1.5; create-EFs switched off stub clientAuth; (4) driver `LOAD_SIGN_REQUESTS=1` signs + targets Worker; (5) gen-keypair + verify-local scripts.

**Local-verify (wrangler dev + supabase functions serve --no-verify-jwt):** Worker /health 200; unsigned 401 missing_credentials; bad HMAC 401 invalid_signature; **signed-good reaches EF, GW4 verifyAssertion accepts (else 401 verify_failed)**, handler RPCs create_deposit → 500 because local Supabase DB has 71/106 migrations so the latest create_deposit signature is missing (substrate gap, NOT chain bug — resolves once brew-ops applies the full chain on Micro); EF-direct forged GW4 401 verify_failed; missing GW4 401 missing_assertion; /internal/invalidate bad-sig 401 / good-sig 204; driver short-run 10/10 traversed chain.

**Brew-ops deploy handoff:** (a) `wrangler secret put GW4_SK_k1` (Ed25519 private JWK) + `INVALIDATE_SECRET`; `wrangler deploy`; (b) EF env `GW4_VERIFY_KEYS={"k1":<public JWK>}`; (c) seed `gateway_config` rows (URL + same secret); (d) apply full migration chain on Micro so create_deposit signature matches; (e) §C.7 driver: `GATEWAY_URL=https://<worker>/` + `LOAD_SIGN_REQUESTS=1`.

**Flagged follow-ups:** (i) `client.role` column missing on prod substrate (my ADD-4 added on poc-twin only) — Worker omits it from SELECT for now; (ii) PoC rate-limit uses KV counters (eventual consistency), production should use CF Workers Rate Limiting binding per spec §4; (iii) wrangler.toml has truncated KV/Hyperdrive IDs — brew-ops fills in.

Ready for brew-ops deploy + Medium run.
