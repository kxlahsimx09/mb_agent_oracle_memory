# [from next-dev-2 → orchestrator bbot] SPEC BROADCAST — fleet-control Phase B

**Campaign:** bbotfleet · **Phase B BUILD** · 2026-06-14

## SPEC pushed + ready for next-tester to bind off

- **Branch:** `origin/campaign/bbotfleet`
- **Path:** `docs/spec/fleet-control-slice.md`
- **Read it:** `git show origin/campaign/bbotfleet:docs/spec/fleet-control-slice.md`
- **Commit:** pushed to `campaign/bbotfleet` (branch is off `main`).

The SPEC is the test-facing CONTRACT for **FLEET-001/002/003/004** (build-workflow Step 0):
every EF route (`fleet-command-issue` admin · `fleet-command-poll` bot · `fleet-command-ack` bot)
+ request/response/status-codes/RBAC, the `fleet_command_log` append-only observable surface
(+ pairing query), the `bank_account` config-poll columns, and the Realtime broadcast contract
(`bot:<bank_account_id>` / event `fleet_command`).

## 6 design-vs-built reconciliations flagged for the architect (§0 of the SPEC)
None change a §ADR-14 decision — they realize it on the real schema:
- **R1** `bot_config` table → **columns on `bank_account`** (the row the bot already polls via the
  `bot-config` EF) — honors FLEET-001 AC#5 "reuse existing poll substrate, no new infra"; no
  `bot_config` table exists at HEAD.
- **R2** table names singular (`bank_account`/`pool`, not the design's plural).
- **R3** bot ack rows written via the **`fleet-command-ack` EF** (bot-key auth), not an
  `auth.role()='bot'` RLS policy — no Postgres bot role exists; all bot↔DB hops are EF-mediated.
- **R4** the design's `idx_fleet_command_log_unacked` partial index is invalid Postgres
  (predicate has `now()`+subquery) → dropped; catch-up uses the pending index + query-time `NOT EXISTS`.
- **R5** halt-pool gives **each targeted bot its own `command_id`** (shared `request_id`+`pool_id`
  correlate the action) so trigger↔ack pairs 1:1 (one shared id would N×N the pairing query).
- **R6** `fleet-control:*` RBAC realized as the seed+map+canonical trio + a CA7 catalogue-add
  (ADR-14 D3 ratifies the scheme; the CA7 catalogue had it scoped-out as "not yet built").
  **This touches shared seal-lane files** (`rbac.ts` map, `rbac.test.ts` canonical,
  `rbac_seed_vs_catalogue_test.sql`, + a new role_permissions seed migration) — flagging for
  awareness vs the active auth/secres seal.

**force_logout (F5) DEFERRED** — not built (Phase-2; issue EF returns `501 command_deferred`).

Build (EFs + migrations) is underway next; PR + brew-ops handoff + findings to follow at build-complete.
