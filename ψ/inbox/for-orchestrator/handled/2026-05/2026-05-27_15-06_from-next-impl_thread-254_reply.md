---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: (A) HALT-AND-CONFIRM — work lands in next-dev's lanes (functions+migrations) + is security-auth; ready plan + ownership call needed
needs_response: true
priority: high
created: 2026-05-27T15:06:00+07:00
handled_at: 2026-05-27T22:08:00+07:00
handled_by_thread: 254
handled_note: >
  HARD ESCALATION. next-impl HALT-AND-CONFIRM (priority high, BLOCKED): option (A)/EF-ingress
  work lands in next-dev's reserved lanes (supabase/functions + migrations) + is security-auth
  code; next-dev not spawned. Memory check (FTS5, vector degraded): no prior decision-authority
  pattern for lane-crossing / spawn-next-dev → LOW confidence → escalated to user, NOT
  auto-authorized. Relayed the 3 ownership options (i/ii/iii) + next-impl's recommendation (i)
  + substrate gap (client.api_key_secret absent, no rate-limit table) + brew-ops seed dependency
  to user via Telegram (chat 2002026175, msg id 37) at 2026-05-27T22:08+07:00. Escalation marker
  posted to thread #254 (msg 1212). Thread left pending; next-impl stays blocked until user picks
  i/ii/iii. No reply envelope to next-impl yet (response = user's governance decision).
---

Agree with (A) + the §ADR-2 G5-D EF-ingress placement (no disagreement on the *what*). But I grounded it against the substrate and must flag a boundary before authoring (thread #254 msg 1211 has the full plan):

**Almost all of it lands in next-dev's RESERVED lanes** (my SKILL hard-rule = I don't author these) **and it's security-sensitive auth code** (my SKILL: auth/credential → halt + ping human; next-dev not spawned):
- `supabase/functions/_shared/auth.ts` + deposits-create + payouts-create — real API-Key+HMAC (functions lane).
- `supabase/migrations/` — substrate MISSING: (1) `client.api_key_secret` doesn't exist (only `api_key`) → no secret to HMAC against; (2) NO rate-limit table/RPC in migrations (my ADD-3 is only in the Bun twin). New migration + seed needed (migrations lane).
- `poc/integration/src/load/driver.ts` HMAC signing — the only clearly-MINE piece.

I will NOT silently cross into functions/migrations. Pick ownership:
- (i) explicitly authorize next-impl to author functions+migrations for THIS scope (one-time, documented; flag for next-dev review later) — I start immediately;
- (ii) spawn next-dev for the EF+migration parts, I own driver-signing + local-verify + spec-tests;
- (iii) I do driver-signing only + hand a patch-spec to the EF owner.

Recommendation: (i) is the pragmatic unblock (next-dev absent, user ratified A, impl+local-verify only) — but it's a production-auth-ownership governance call, so I'm surfacing it.

**Brew-ops dependency (regardless of path):** §C.7 Micro substrate needs this migration applied (`api_key_secret` + rate-limit) + per-client secret seeded BEFORE the Medium run, and the driver handed the secret — else signed requests can't be verified. Awaiting your (i)/(ii)/(iii) call.
