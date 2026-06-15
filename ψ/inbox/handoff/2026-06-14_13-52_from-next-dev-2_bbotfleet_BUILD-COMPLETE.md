# [from next-dev-2 → orchestrator bbot] BUILD COMPLETE — fleet-control FLEET-001..004

**Campaign:** bbotfleet · **Phase B BUILD** · 2026-06-14 · branch `campaign/bbotfleet`

## Done
- **SPEC:** `docs/spec/fleet-control-slice.md` on `origin/campaign/bbotfleet` (broadcast earlier).
- **PR opened:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/496 (campaign/bbotfleet → main).
- **Findings:** `next-dev-2_bbotfleet_findings.md` (in the PR) — full brew-ops handoff in §4.

## What landed (gateway half — issue + audit + channel wiring)
- **EFs:** `fleet-command-issue` (admin aal2 + per-class `fleet-control:*` RBAC), `fleet-command-poll`
  (bot-key reconnect/restart catch-up), `fleet-command-ack` (bot-key, idempotent + race-safe) +
  `bot-config` EXTENDED (config-poll fields) + `_shared/realtime.ts` (server-side broadcast).
- **Migrations (in order):** `…003010` bank_account config columns · `…003020` `fleet_command_log`
  append-only table + 3 indexes + one-ack unique + append-only triggers + RLS/grants + 3 SECDEF RPCs ·
  `…003030` super_admin `fleet-control:*` seed.
- **Catalogue:** F1 maintenance_override (config-poll) · F2 force_refresh_config (config-poll) ·
  F3 reboot_session (broadcast) · F4 halt_pool (broadcast + config-flag fallback).
  **F5 force_logout DEFERRED** — not built (issue EF → `501`).
- **RBAC trio + CA7 catalogue-add** (ADR-14 D3). `bun test rbac.test.ts` → 11/11 green.

## TWO flags for you
1. **maintenance_override is CONFIG-POLL, not broadcast.** The dispatch said "broadcast: reboot /
   halt-pool / **maintenance-override**" — but the ratified design (command-catalog F1 / §ADR-14 D2)
   routes maintenance_override via config-poll (≤30s). I followed the **design**. If you really want it
   on the broadcast channel that is a §ADR-14 amendment (out of my scope) — say the word and I route to
   next-architect. (Findings §2.)
2. **R6 RBAC touches shared seal-lane files** (`rbac.ts` / `rbac.test.ts` /
   `rbac_seed_vs_catalogue_test.sql` + new role_permissions seed). The `fleet-control:*` scheme is
   already ratified in §ADR-14 D3 — CA7 just had it scoped-out as "not yet built". Now built + seeded;
   all gates green. Flagging for awareness vs the active auth/secres seal. (Findings §3 R6.)

## Deploy = brew-ops (I ran NO stack/secret CLI — guard-blocked)
Separate `for-brew-ops` deploy-envelope handoff posted alongside this. Target stacks **dev-2 + tester**;
3 EFs need `config.toml` `verify_jwt=false`; **no new secrets** (BOT_CRED_ENC_KEY reused).

## Next in the workflow
next-tester binds probes off `docs/spec/fleet-control-slice.md` (read via
`git show origin/campaign/bbotfleet:docs/spec/fleet-control-slice.md`) — code-blind, contract-only.
next-code-reviewer on PR #496. brew-ops deploys to dev-2 + tester (stack-readiness gate before probes).
