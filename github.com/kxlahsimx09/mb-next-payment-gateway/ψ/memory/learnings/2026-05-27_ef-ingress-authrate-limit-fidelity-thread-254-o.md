---
title: EF-ingress auth/rate-limit fidelity (thread #254 option A) — crosses into next-d
tags: [implementation-architect, repo:mb-next-payment-gateway, next, poc, thread-254, ef-ingress, auth, hmac, api-key, rate-limit, lane-boundary, next-dev, supabase-functions, supabase-migrations, security-halt, c7-medium, handoff]
created: 2026-05-27
source: thread #254 msg 1210/1211; supabase/functions/_shared/auth.ts + deposits-create/index.ts + migrations 20260510000001/8 @ origin/main 2026-05-27
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# EF-ingress auth/rate-limit fidelity (thread #254 option A) — crosses into next-d

EF-ingress auth/rate-limit fidelity (thread #254 option A) — crosses into next-dev's lanes + substrate gaps (2026-05-27, FLAGGED, awaiting ownership decision).

User ratified option (A) from msg 1203: port §ADR-7 API-Key+HMAC auth + §ADR-11-A3 PG-counter rate-limit into the CREATE EDGE FUNCTIONS (supabase/functions/deposits-create, payouts-create, _shared/auth.ts), NOT the Bun gateway twin — because §ADR-2 G5-D pins the checks to EF ingress middleware (gateway tier rejected). Chain target: clientAuthHmac → withIdempotency → rateLimit → handler → RPC. Idempotency already faithful (withIdempotency in _shared/idempotency.ts) — keep.

next-impl HALTED-AND-FLAGGED rather than authoring, because the work lands almost entirely in lanes the SKILL.md reserves for next-dev (which is NOT spawned) AND it's security-sensitive auth/credential code (SKILL halt rule):
- supabase/functions/_shared/auth.ts currently STUB: clientAuth reads x-client-id and looks up client.api_key (no HMAC, no secret). botAuth=x-bot-secret, serviceRoleAuth=Bearer service_role.
- SUBSTRATE GAPS (migration lane): (1) client table has api_key UNIQUE but NO api_key_secret column → HMAC has no per-client secret to verify against → needs a migration ALTER + seed; (2) NO rate-limit counter table/RPC exists in supabase/migrations at all — the ADD-3 rate_limit_rpcs.sql (rate_limit_counters + rate_limit_hit) lives ONLY in poc/integration/src (the Bun twin) → §ADR-11-A3 needs a new migration porting it. merchant_config.secret is the §ADR-9 CALLBACK HMAC secret, NOT a client→server request secret.
- Only clearly-next-impl piece: driver.ts HMAC request signing (poc/integration, my lane), coupled to the EF HMAC contract (x-signature: t=<ms>,v1=HMAC-SHA256(secret, "${t}.${rawBody}")).

Ownership options presented: (i) explicitly authorize next-impl to author functions+migrations for this scope (one-time documented crossing, flag for next-dev review later, P-001 not throwaway); (ii) spawn next-dev to own EF+migration, next-impl owns driver-signing + local-verify + spec-tests; (iii) next-impl does driver-signing only + hand a patch-spec. Recommended (i) as pragmatic unblock (next-dev absent, impl+local-verify only).

BREW-OPS DEPENDENCY (any path): §C.7 Micro substrate must have the new migration applied (api_key_secret + rate-limit table/RPC) + per-client api_key_secret seeded BEFORE the Medium run, and the driver handed the secret — else signed requests fail verification.

Scope is IMPLEMENT + local-verify only (no hosted run); §C.7 Medium is the next leg. The 5 prior ADDs (#268-271) built the SAME checks in the Bun twin (poc/integration) — this (A) work is the EF-path equivalent that the Medium runner (which hits raw EFs) actually exercises.

---
*Added via Oracle Learn*
