# [for brew-ops] DEPLOY ENVELOPE — bbotbot bot lanes (PR #495)

**From:** next-dev-1 · **Campaign:** bbotbot · 2026-06-14 · branch `campaign/bbotbot` (PR #495 → main)
**Routed here because:** the deploy-env-guard blocks config.toml + secret mutation for non-brew-ops (correct).
**Target stacks:** `dev-1` + `tester`. Apply from `campaign/bbotbot` (or merged `main` per orchestrator).

## Apply order (STRICT: migrations FIRST, then EFs)
The updated `bot-config` EF selects `dual_control` (added by migration 040) — deploying the EF before the
migration would 500.

### 1) Migrations — `supabase db push` (in numeric order)
```
20260614000010_bbot010_otp_relay.sql
20260614000020_bbot011_claim_reconcile.sql
20260614000030_bbot012_transfer_proof.sql
20260614000040_bbot013_telemetry.sql
```

### 2) Edge Functions — `supabase functions deploy --project-ref <REF>` (no-arg = all dirs)
New: bot-otp, bot-otp-log, bot-claim, bot-fetch-processing, bot-tx-checkpoint, bot-transfer-proof, bot-heartbeat.
Changed (re-deploy): bot-queue-mark, bot-balance, bot-config. (`_shared` bundled → no-arg deploy refreshes all.)
Then `scripts/ef-deploy-list.sh --assert` per stack (it auto-discovers the new dirs).

### 3) config.toml — ADD these 7 blocks (Bot EFs section). Without them verify_jwt defaults true → bot 401s.
```toml
[functions.bot-otp]
verify_jwt = false
[functions.bot-otp-log]
verify_jwt = false
[functions.bot-claim]
verify_jwt = false
[functions.bot-fetch-processing]
verify_jwt = false
[functions.bot-tx-checkpoint]
verify_jwt = false
[functions.bot-transfer-proof]
verify_jwt = false
[functions.bot-heartbeat]
verify_jwt = false
```

### 4) Secrets / env (per target stack)
- **`OTP_PRODUCER_ENC_KEY`** — NEW, ≥16 chars. `bot-otp-log` fails-loud (500 `otp_producer_auth_misconfigured`) without it.
- **`OTP_PRODUCER_ENV`** — optional, `prod` (default) | `sim`. Match the credential env.
- `BOT_CRED_ENC_KEY` — already set (bbot002); reused.

### 5) Test-enablement (so next-tester can exercise BOTH planes)
- Bot key per test bank_account: reuse `mint_bot_credential` (BBOT-002).
- Producer credential: `SELECT * FROM mint_otp_producer_credential('<OTP_PRODUCER_ENC_KEY>', '<env>');`
  → `(producer_key, producer_secret)` shown ONCE; hand to next-tester (env must match `OTP_PRODUCER_ENV`).

A bare/stale stack is a BLOCKER, never green (build-workflow stack-readiness gate). Full context:
`next-dev-1_bbotbot_findings.md` §4.
