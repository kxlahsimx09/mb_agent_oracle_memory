**from brew-ops → orchestrator bbot · campaign bbotfleet · STACK-READINESS (fleet-control on TESTER/yupsev)**

## VERDICT: 🟢 GREEN for the fleet COMMAND path · 🟡 ONE flagged HOLD (bot-config)

Stood next-dev-2's fleet-control build (PR #496, `campaign/bbotfleet`, FLEET-001..004) up on TESTER = `yupsevcrubgprsbujbpu` (yupsev). Full report committed to the branch: `brew-ops_bbotfleet_findings.md` (commit `8fd98b9`).

### DONE + VERIFIED
- **config.toml** (DO#1): added `verify_jwt=false` for fleet-command-issue/poll/ack → commit `824abe1`, pushed to `campaign/bbotfleet` (in PR #496). Confirmed effective: all 3 EFs report `verify_jwt=false`.
- **Migrations** (DO#2): applied `20260614003010/003020/003030` in strict order via psql session-pooler + recorded in the ledger. Verified: `fleet_command_log` exists (RLS-on/0-policy/no anon-grant), 3 RPCs SECDEF proacl={postgres,service_role}, 4 fleet-control perms seeded, bank_account += config_revision/maintenance_override_until/halt_pool_until.
- **Fleet EFs** (DO#2): fleet-command-issue/poll/ack deployed → ACTIVE, v1, verify_jwt=false, all respond **401** (own auth gate live; control 404 proves not-missing). `--assert`: these 3 are neither MISSING nor STALE.
- **Secrets** (DO#3): NONE new. `BOT_CRED_ENC_KEY` (botKeyAuth) + SUPABASE_URL + SERVICE_ROLE_KEY all present on yupsev.
- **Realtime wired**: `/realtime/v1/api/broadcast` replicated with the EF's exact contract (topic `bot:<id>`, event `fleet_command`) → **HTTP 202**.
- **EF→DB smoke** (read-only, zero-footprint): `fleet_command_log` PostgREST → 200 `[]`; RPC `fleet_unacked_commands` PostgREST → 200 `[]`.

### 🟡 ONE HOLD — bot-config redeploy needs YOUR call
`campaign/bbotfleet` is **behind main**: PR #495 (bbot bot lanes) is ALREADY MERGED to main + deployed on yupsev. bbotfleet lacks all of it. The known #495⟷#496 **bot-config** conflict is real and on the SAME lines: #495 adds `dual_control`; bbotfleet adds the 3 fleet columns. Deploying bbotfleet's bot-config to the SHARED yupsev would **regress `dual_control`** (BBOT-003/011). I held it. Impact: NONE on the fleet COMMAND path (all GREEN); the only gap is the bot-facing config-poll READ projection, whose consumer is the cross-repo bankbot-v2 executor (handoff §6 = out of scope).
- **(a) RECOMMENDED:** have next-dev-2 merge main→bbotfleet (resolve bot-config to all 5 fields; also makes deploy-all/--assert cleanly green), then I redeploy the merged bot-config + full sweep. CODE op = next-dev-2.
- **(b)** If no bbot fleet-tester needs dual_control on yupsev now, authorize the regression and I deploy bbotfleet's bot-config as-is.

### FYI (not introduced/fixed by me)
- `--assert yupsev` is RED only for understood reasons: 7 orphan EFs (= #495 family, proof of behind-main) + 33 stale (= new `_shared/realtime.ts` bumps every EF's git mtime; they don't import it). Clean-green needs the (a) merge first. Did NOT deploy-all (would regress bot-balance/-config/-queue-mark from behind-main).
- yupsev ledger MISSING `20260613000030_authro_business_secret_revoke` (pre-existing; authro/secres lane). Not applied (out of scope). Flag for a future clean `db push` (needs `migration repair`); route to authro owner if it's a live exposure on the tester stack.

### Fleet-tester creds — ready to hand
Name the fleet-tester team and I'll `maw team send`: yupsev URL+service-role, a super_admin aal2 gotrue session (fleet-command-issue gate; can mint on request), and a bot key (BOT_CRED_ENC_KEY-bound) for poll/ack. Not minted yet (no team named).

OUT OF SCOPE (untouched): EF/migration code, mark-done (next-pm), behavior probes (fleet-tester), the bot-config merge, the authro migration.