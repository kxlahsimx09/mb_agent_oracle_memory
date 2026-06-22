---
from: orchestrator (campaign 41-o-business-gap)
to: [brew-ops]
date: 2026-06-21T00:00:00+07:00
topic: DEPLOY REQUEST — GW-X-02 Model-B balance reservation (gateway #682 + bankbot #35, both merged to main)
status: code merged + sealed + tested (pgTAP 47/47); awaiting brew-ops deploy. MONEY-CRITICAL ordering inside.
tags: [#repo:mb-next-payment-gateway, #repo:mb-next-bank-bot, #brew-ops, #deploy, #gw-x-02, #money-safety, #cross-repo]
---

# brew-ops DEPLOY ENVELOPE — GW-X-02 Model-B reserve-at-claim

Both PRs are MERGED to main, sealed (SEAL-WITH-NITS, no over-draw), pgTAP 47/47:
- **Gateway** `mb-next-payment-gateway` PR #682 → merge commit `ff216fe` — migration `20260621000900_gwx02_model_b_reservation.sql` (adds `bank_account.reserved` + `balance_updated_at`, new `claim_withdrawal_items`/`bot_update_balance`/`mark_failed`/`mark_review` bodies, freshness guard, `monitoring_alert` sink) + EF `bot-balance` (now 4-arg `{balance, available_balance, scraped_at}`).
- **Bankbot** `mb-next-bank-bot` PR #35 → merge commit `403c2c9` — un-stubs `updateBalance` (BBOT-013), pushes `{balance, available_balance, scraped_at}`, distinguishes scrape-miss from genuine-zero. ECR image already built by `build-push-ecr` on the merge.

## ⚠️ MONEY-CRITICAL: deploy ORDER must not be inverted
If the gateway freshness guard activates BEFORE the bot is pushing fresh balance, `balance_updated_at` is NULL/stale on every bank → **the guard rejects ALL withdrawal claims → withdrawal lane freezes system-wide**.

### Recommended: stage first
Deploy to **staging/seal**, run live-test J1–J4 (`ψ/inbox/handoff/2026-06-21_13-25_livetest-gwx02-overdraw-journey.md`), confirm green, THEN prod.

### Phase 1 — Bankbot FIRST (resume balance push)
- `gh workflow run deploy.yml -f bank=all -f component=bot -f image_tag=<real-bank tag>` on `mb-next-bank-bot` (rolls the new ECR image onto the ECS Fargate bots).
- Verify the bots are calling `PUT /functions/v1/bot-balance` each scrape tick (~30s deposit lane; per-transfer payout lane). At this point the OLD 3-arg EF still runs and just ignores `scraped_at` — harmless; the bot is now "warm".

### Phase 2 — Gateway (activate reservation + guard)
1. `supabase functions deploy bot-balance` (the new 4-arg EF) + any other changed EFs in the PR.
2. `supabase db push` migration `20260621000900` (IPv4 session pooler, percent-encoded; `--include-all` if the stack skipped any intervening migration — check `schema_migrations` first).
3. **WARM-UP gotcha:** the migration creates `balance_updated_at` as NULL on existing rows → the guard rejects until the next bot push stamps it via the new RPC. Mitigation — immediately after `db push`, for banks with a live heartbeat, backfill `UPDATE bank_account SET balance_updated_at = app_now() WHERE last_heartbeat_at > app_now() - interval '90s'` (trusts the warm bot to correct within one tick), OR set `balance_freshness_threshold_seconds` generously for the first few minutes. Without this, expect a ~1-tick reject window per bank (payouts retry, not lost).

### Phase 3 — verify
- Run live-test J1–J4 on the deployed env.
- Watch `monitoring_alert` for `stale_balance` storms (a storm = a bank whose push cadence exceeds the threshold, e.g. idle/maintenance — see runbook; tune threshold ≥ maintenance-window + tick).
- Confirm claims flow + no over-draw.

## Rollback
Migration is forward-only (DROP+CREATE RPCs). Rollback = redeploy the prior `claim_withdrawal_items`/`bot_update_balance`/`mark_*` bodies (the `20260620000700` + prior wallet007 versions) and stop reading `reserved`/`balance_updated_at`. Keep those prior function bodies staged before you start.

## Notes
- The §ADR-4a §Amendment 2026-06-21 (ratified, on main) is the spec; `docs/spec/withdrawal-balance-reservation-slice.md` AC-1..AC-9 the contract.
- Cross-repo contract (verified matching): bot sends `{ balance, available_balance, scraped_at }`; gateway clamps `LEAST(scraped_at, app_now())`.
- Ties the still-open prod-deploy-pending items GW-PAY-04/GW-FEE-02 backfill (separate) — batch the deploy window if convenient.
