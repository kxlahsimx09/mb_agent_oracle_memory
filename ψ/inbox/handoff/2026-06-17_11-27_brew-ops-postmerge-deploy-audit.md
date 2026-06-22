# brew-ops post-merge deploy audit — staging `sinuw` (`sinuwgsqqyqzlpaavimf`)

**Date:** 2026-06-17 ~11:25 GMT+7 (04:24Z). **Operator:** brew-ops (slug `brew-ops-postmerge-deploy-audit`).
**Repo state:** clean `main@HEAD` = `af8e9ab` (PR #546 merge). `git fetch && checkout main && pull` → up to date, no working-tree changes.

## VERDICT
**All MERGED gateway work from the 9-PR session is LIVE + reconciled to `main@HEAD` on sinuw.** I deployed the merged EFs targeted-by-name (idempotent, from clean main) — this reconciled real `_shared/` drift. Migrations for my scope are verified live by object existence. The only residual non-green items are the EXPECTED cross-campaign topup/settlement/pullout artifacts (separate campaigns' deploy responsibility), explicitly distinguished below.

## CLI GOTCHA (fixed this run — important for next brew-ops)
The `supabase` CLI at `~/.local/bin/supabase` is a SHIM that could not find its `supabase-go` backend → **all deploys silently exit 1** (and a naive `| grep` filter swallows the error → false "done"). Fix: the backend exists at `/home/ubuntu/.local/share/supabase/supabase-go`; export `SUPABASE_GO_BINARY=/home/ubuntu/.local/share/supabase/supabase-go` before any `supabase functions deploy`. Confirmed working after the export (uploaded assets, "Deployed Functions", exit 0).

## EF FRESHNESS — my 16 merged EFs: 16/16 ACTIVE + FRESH (deployed 04:23–04:24Z, past the `_shared` floor)
Deployed targeted-by-name from `main@HEAD` af8e9ab. Versions:
- `auth-step-up-verify` v21, `auth-step-up-posture` v20 (PR #540)
- `admin-clients-create` v2 (PR #546)
- `admin-bankbot-log` v3 + bot family (PR #541): `bot-balance` v22, `bot-bank-statements-last` v22, `bot-claim` v10, `bot-config` v13, `bot-fetch-processing` v10, `bot-heartbeat` v10, `bot-otp` v10, `bot-otp-log` v10, `bot-queue-mark` v22, `bot-statements` v22, `bot-transfer-proof` v10, `bot-tx-checkpoint` v10
- `admin-payout-*` (PR #40 portal-only deps): 4/4 ACTIVE (cancel/correct/reconcile/reverse-settle) — pre-existing, confirmed ACTIVE.

## WHY THE FULL STACK READS STALE (real, but additive — not a regression)
`ef-deploy-list.sh --assert sinuw` exits 1 with ~37 STALE + 3 MISSING. ROOT CAUSE: the freshness floor is `_shared@1781629627` (commit `d700744` = **PR #546 prov-001**), which added `client:create`/`sub-client:create` to `_shared/rbac.ts`. `_shared/` is bundled into EVERY EF, so every EF deployed before that floor (the last full sweep was 2026-06-16 06:54Z / PR #534 CORS) reads stale. The change is **additive-only** (no perm removed) → the still-stale EFs (admin-payout, admin-users, auth-login, deposits, etc.) are FUNCTIONALLY CORRECT; only `admin-clients-create` actually gates on the new perms and IS freshly deployed. The whole-stack `_shared` reconcile is the next full staging PUSH-sweep's job (w2-watcher auto-deploy path); my targeted scope is complete.

## EF MISSING (3) — EXPECTED cross-campaign, NOT my scope
`admin-topups` (PR #537 topup), `admin-settlements` (#539/#542 settlement), `admin-pullout-tasks` (#544/#547 pullout). Merged but never deployed to staging = those campaigns' deploy responsibility. Matches memory `gateway-staging-deploy-targeted-not-pushall` (topup/settlement/pullout STALE/MISSING are EXPECTED + unrelated to my PRs).

## MIGRATIONS — my 5 targets verified LIVE (by object existence)
- `20260616000040` v_users (PR #543): **`public.v_users` view LIVE, 13 cols = main exactly** (id…created_at incl status/banned_until); `authenticated` SELECT grant present; `super_admin` holds `user:view`; fail-closed (0 rows without aal2 JWT — correct). app_user has 328 rows underneath.
- `20260616000050/60/70` BOTLOG (PR #541): in ledger; `bankbot_activity_log` table + its read view LIVE.
- `20260617000010` prov001 (PR #546): in ledger; `provision_client` RPC LIVE + `client.status` column LIVE.

**Ledger nuance (one finding for my scope):** ledger has **179** rows vs **190** repo files (11 pending). The pending set is EXACTLY the cross-campaign topup(4)/settlement(3)/pullout(3) migrations + the shared-prefix `20260616000040`. The `20260616000040` prefix is a **duplicate-version collision**: TWO files share it — `20260616000040_v_users_read_surface.sql` (PR #543, MINE) and `20260616000040_topup_apply_not_found_404.sql` (PR #537, topup). **Neither has a ledger row**, yet `v_users` IS live+current (its effect landed) while topup's `apply_client_topup` does NOT carry the P0002 `topup_not_found` branch (its effect did NOT land). So: my v_users is reconciled in EFFECT despite missing ledger bookkeeping; the topup half is cross-campaign-pending. Recommend the topup campaign rename one of the two `20260616000040_*` files to a distinct version so the next `db push` records both cleanly (dup prefix = a future `db push` may apply only one + ledger drift).

## LIVE SANITY (cheap probes, all green)
- CORS preflight (Origin `https://mb-next-admin-portal.vercel.app`): `admin-clients-create` / `admin-bankbot-log` / `auth-step-up-verify` / `auth-step-up-posture` → all **204 + ACAO echoes portal origin**.
- `v_users`: structurally proven (grant + gate-perm + correct view def + fail-closed). Did NOT mint an aal2 admin JWT (no gateway admin cred in slots; not "quick") — view effect confirmed via definition + grants instead.
- pgTAP (prov001 / botlog): SKIPPED — running prov001 against shared live staging would mint real auth.users identities (not a safe/quick rollback over the Management API `db/query`); objects + RPC existence already verified.

## NOT MY LANE (stated per mission)
PROD = owner-manual. PORTAL Vercel deploy = owner-manual (no auth). Not touched.

## NEXT STEPS (for orchestrator / next full sweep)
1. My merged gateway work needs no further action — live + reconciled.
2. Full staging EF reconcile (absorb the additive `_shared/rbac.ts` floor across the whole stack) = next PUSH-sweep / `supabase functions deploy --project-ref sinuw` no-arg form — and that sweep will ALSO land the 3 MISSING cross-campaign EFs + their 10 pending migrations. That is the cross-campaign deploy owner's call, not this audit.
3. Fix the `20260616000040` duplicate-version-prefix before the next `db push` (rename topup or v_users file).