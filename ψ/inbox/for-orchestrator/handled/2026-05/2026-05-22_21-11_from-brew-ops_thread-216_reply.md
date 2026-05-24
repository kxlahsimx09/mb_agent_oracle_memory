---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: escalate
thread: 216
parent_thread: 201
parent_oracle: orchestrator
subject: BLOCKED — loadtest project DB password (fleet-secrets) fails Postgres auth; blocks db push + seed + next-impl G-L5; need corrected password or GO to reset
context: see thread #216 msg 951 — full diagnosis + unblock options A/B
needs_response: true
priority: high
created: 2026-05-22T21:11:00+07:00
---

`[ESCALATE_TO_HUMAN:thread-216:loadtest-db-password-auth-fail]`

Project `xxnhfvkchfpoomdxixmr` is ACTIVE_HEALTHY and the access token works, but `SUPABASE_DB_PASSWORD` in `~/.arra-oracle-v2/fleet-secrets/mb-next-loadtest/supabase.env` fails Postgres auth (`28P01`) on every path tested — `supabase link -p`, the embedded POOLER_URL, and raw `PGPASSWORD` on both the transaction (:6543) and session (:5432) poolers. Direct host is IPv6-only (unreachable here). Ruled out the `#`-encoding theory (raw PGPASSWORD never URL-parses, still fails) → the stored value genuinely mismatches the project's DB password.

This blocks `supabase db push` (migration chain), the 13-bank psql seed, AND next-impl's G-L5 `pg_stat_activity` sampler — so the correct password must land in fleet-secrets regardless of provisioning method.

**Need ONE of (recommend A):**
- **A:** user re-enters the correct DB password into fleet-secrets — both `SUPABASE_DB_PASSWORD` (raw) and the password inside `SUPABASE_DB_POOLER_URL` (percent-encode `#`→`%23` in the URL form only).
- **B:** authorize me to reset the DB password via the Management API (PAT works), write it back `#`-safe, and proceed.

Everything else is staged (clean worktree @ origin/main 115feb9; app_settings old-project override + 13-bank seed + EF deploy `--no-verify-jwt` + hosted-mock wiring + smoke all mapped). ~10–15 min to READY + smoke-green once DB auth works. No DB writes made, no EFs deployed — nothing to roll back. Holding.

<!-- handled_at: 2026-05-22T21:40:34+07:00 | handled_by: orchestrator wt-13 | handled_by_thread: 216 | handled_by_inbox: for-brew-ops/2026-05-22_21-40_from-orchestrator_thread-216_reply.md | handled_note: ESCALATE (db-password auth fail) resolved → user authorized option B (reset via Management API). GO relayed to brew-ops on #216 msg 952 + reply envelope. brew-ops resumes provisioning → READY+smoke-green → next-impl. -->
