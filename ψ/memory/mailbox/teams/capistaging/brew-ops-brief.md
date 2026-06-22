# Brief → brew-ops (campaign `capistaging`) — deploy the CLIREAD build to STAGING (go-live)

**From:** orchestrator (campaign family `capi*`). **Repo:** `github.com/kxlahsimx09/mb-next-payment-gateway`.
**Why manual:** PR #610 (the CLIREAD build) is **MERGED to `main`** (squash `70cfa55d0`, now the main tip), but the staging PUSH auto-trigger has **not** deployed it after ~20 min (staging `client-bank-codes` still 404). No other brew-ops is mid-deploy. **Orchestrator-authorized manual targeted deploy from `main@HEAD`** to make the merchant read/poll surface live on staging.

## Deploy — TARGETED, from main@HEAD, to staging only
- **Stack:** staging (sinuw) — Supabase ref `sinuwgsqqyqzlpaavimf`, slot `.secrets/slots/staging.env`.
- **Source:** `origin/main` @ `70cfa55d0` (or current main tip — it carries the CLIREAD build).
- **Deploy set (exact — TARGETED, do NOT push-all; sinuw shares the stack with in-flight campaigns, per the standing "targeted-not-pushall" rule):**
  - **db push FIRST:** `supabase/migrations/20260619000100_cliread_client_read_poll_rpcs.sql` — **additive only** (9 new SECURITY DEFINER RPCs + grants; reuses, never alters `v_deposits`/`v_payouts`/`cancel_deposit`/`write_audit_log`/`bank`/`wallet`). No destructive ops.
  - **functions deploy SECOND** (they call the new RPCs): `client-deposit-status`, `client-payout-status`, `client-deposits`, `client-payouts`, `client-wallet-balance`, `client-bank-codes`, `client-deposit-cancel` — all `verify_jwt=false` (on main's config.toml).

## Mechanics / gotchas
- If the supabase CLI shim errors "Could not find supabase-go": `export SUPABASE_GO_BINARY=/home/ubuntu/.local/share/supabase/supabase-go`.
- `ef-deploy-list.sh --assert` whole-stack FAIL + rbac seed-drift on sinuw are **EXPECTED** (pre-existing, other campaigns) — you are deploying the CLIREAD scope only; do NOT chase the unrelated drift, do NOT push-all.

## Post-deploy assert (confirm go-live)
On staging sinuw, confirm: the migration is in `schema_migrations`; the 7 EFs **respond (not 404)** — e.g. `client-bank-codes` with a header `apikey: <anon>` returns JSON or `401 missing_x_client_id` (EF live), and `client-deposit-status/<random-uuid>` returns `404 deposit_not_found` (EF live, not platform-404).

Report "staging DEPLOYED — 7 CLIREAD EFs + migration live on sinuw" when done (this is the go-live that closes the gaps for merchants on staging). Surface any failure immediately.

Before your first action run `arra_search query="soul-brews-core" type=principle limit=20`.
