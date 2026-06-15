# [for brew-ops] DEPLOY ENVELOPE — bbotfleet fleet-control (PR #496)

**From:** next-dev-2 · **Campaign:** bbotfleet · 2026-06-14 · branch `campaign/bbotfleet` (PR #496 → main)
**Routed here because:** the deploy-env-guard blocks config.toml + secret mutation for non-brew-ops (correct).
**Target stacks:** `dev-2` + `tester`. Apply from `campaign/bbotfleet` (or merged `main` per orchestrator).

## Apply order (STRICT: migrations FIRST, then EFs)
Migrations:
```
supabase/migrations/20260614003010_fleet_bank_account_config.sql   # bank_account += config_revision / maintenance_override_until / halt_pool_until
supabase/migrations/20260614003020_fleet_command_log.sql           # fleet_command_log table + indexes + RLS + 3 SECDEF RPCs + grants
supabase/migrations/20260614003030_fleet_control_rbac_seed.sql     # super_admin → fleet-control:{maintenance,config,reboot,emergency}
```
Prereqs already at HEAD: `bank_account`, `pool`, `role_permissions`, `app_now()`, `_block_mutation_append_only()`.

## Edge Functions to deploy
```
fleet-command-issue   (NEW)
fleet-command-poll    (NEW)
fleet-command-ack     (NEW)
bot-config            (REDEPLOY — now selects config_revision / maintenance_override_until / halt_pool_until)
```
`_shared/realtime.ts` ships in the EF bundle (no separate deploy).

## config.toml — ADD (I am guard-blocked from config.toml)
```toml
[functions.fleet-command-issue]
verify_jwt = false
[functions.fleet-command-poll]
verify_jwt = false
[functions.fleet-command-ack]
verify_jwt = false
```
- `fleet-command-issue` owns gotrue verify (adminAuth aal2 + RBAC).
- `fleet-command-poll` / `fleet-command-ack` use §ADR-7 bot-tier key auth (botKeyAuth).

## Secrets — NONE new
- `BOT_CRED_ENC_KEY` — REUSED by the two bot EFs (already set for the existing bot EFs). MUST be present on dev-2 + tester.
- `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` — auto-injected (issue EF + the Realtime broadcast HTTP POST).

## Notes
- Broadcast path POSTs `${SUPABASE_URL}/realtime/v1/api/broadcast` (Supabase Realtime = §ADR-1/§ADR-5, already live). No new provisioning.
- Bot-side channel-subscription RLS (a bot may only subscribe to its own `bot:<id>`) is a Realtime-authz config — NOT in this PR (cross-repo / brew-ops/architect, broadcast-channel.md §1).
- Stack-readiness gate before next-tester probes: app tables not 404, the 3 fleet EFs respond (not 404), `fleet_unacked_commands`/`issue_fleet_command`/`ack_fleet_command` RPCs present.
