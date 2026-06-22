# Brief → brew-ops (campaign `capideploy`) — cross-stack deploy of the CLIREAD build (pre-merge, VERIFY phase)

**From:** orchestrator (campaign family `capi*`). **Repo:** `github.com/kxlahsimx09/mb-next-payment-gateway`.
**Authorization:** This is the **§9b orchestrator-specified pre-merge deploy** — deploy the **named branch `campaign/capibuild` (PR #610)**, NOT `main`, to the **tester + investigator/seal** stacks so the VERIFY chain can run before merge. (You are the sole shared-stack deploy actor; tester/seal creds are yours.)

## Source to deploy
- Branch: **`origin/campaign/capibuild`** (PR #610 — `feat(§ADR-26 CLIREAD-001..007)`). next-dev self-verified **62/62 green** on dev-1; this is the build for VERIFY.
- **Deploy set (exact):**
  - **Migration (db push FIRST):** `supabase/migrations/20260619000100_cliread_client_read_poll_rpcs.sql` — SECURITY DEFINER RPCs only; reuses (never alters) `v_deposits`/`v_payouts`, `cancel_deposit`, `write_audit_log`, `bank`, `wallet`, `wallets_change_logs`.
  - **Edge Functions (functions deploy SECOND — they call the new RPCs):** `client-deposit-status`, `client-payout-status`, `client-deposits`, `client-payouts`, `client-wallet-balance`, `client-bank-codes`, `client-deposit-cancel`. All carry `config.toml` `verify_jwt = false` (included on the branch).
  - **No destructive ops; no change to any existing EF/RPC/view.**

## Targets (deploy to BOTH)
| Stack | Supabase ref | Slot |
|---|---|---|
| tester | `yupsevcrubgprsbujbpu` | `.secrets/slots/tester.env` |
| investigator (seal) | `qnccphgykzdydebmdwdf` | `.secrets/slots/investigator.env` |

(Do **NOT** deploy to staging here — staging auto-redeploys from `main` on the post-merge PUSH trigger.)

## Mechanics / gotchas
- Check out / fetch `origin/campaign/capibuild` and deploy that ref's migration + EFs (db push → functions deploy, in that order).
- If the supabase CLI shim errors "Could not find supabase-go": `export SUPABASE_GO_BINARY=/home/ubuntu/.local/share/supabase/supabase-go` (per the standing learning).
- **Post-deploy currency assert (the Stack-readiness gate the tester depends on):** confirm on EACH stack that the 7 new EFs **respond (not 404)** and the migration is in the `schema_migrations` ledger — `scripts/ef-deploy-list.sh --assert <REF>` + a quick `client-bank-codes` probe (public-ish call returns JSON, not 404). A present-but-STALE EF is NOT green — redeploy until current.

## Report back to the orchestrator
When BOTH stacks carry the migration + 7 EFs (responding, not 404, current), report "tester + seal DEPLOYED + green" so I release `next-tester` (probes) and `next-investigator` (independent seal regression). Surface any deploy failure (migration error, EF deploy error, rbac/seed drift) immediately — don't leave a half-deployed stack silent.

Before your first action run `arra_search query="soul-brews-core" type=principle limit=20`.
