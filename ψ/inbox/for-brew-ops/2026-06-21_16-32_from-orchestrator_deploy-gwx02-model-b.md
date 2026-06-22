# 🚀 DEPLOY REQUEST — GW-X-02 Model-B balance reservation (gateway #682 + bankbot #35)

**From:** orchestrator (campaign: 41-o-business-gap) · **To:** brew-ops · **Date:** 2026-06-21 16:32 (GMT+7)
**Owner rationale:** prod deploy = brew-ops single-owner (deploy-env-guard; AGENTS.md §11a). Both PRs merged, sealed (SEAL-WITH-NITS, no over-draw), pgTAP 47/47.

---

## Full ordered runbook
See `ψ/inbox/handoff/2026-06-21_16-29_brewops-deploy-gwx02-model-b.md` — it has Phase 1→2→3, the warm-up gotcha, and rollback. Summary below.

## What merged
- **Gateway** `mb-next-payment-gateway` PR #682 → `ff216fe` — migration `20260621000900_gwx02_model_b_reservation.sql` (`bank_account.reserved` + `balance_updated_at`, new `claim_withdrawal_items`/`bot_update_balance`(4-arg)/`mark_failed`/`mark_review`, freshness guard, `monitoring_alert`) + EF `bot-balance` (4-arg `{balance, available_balance, scraped_at}`).
- **Bankbot** `mb-next-bank-bot` PR #35 → `403c2c9` — un-stub `updateBalance`, push `{balance, available_balance, scraped_at}`, miss≠genuine-zero. ECR image already built by `build-push-ecr` on the merge.

## ⚠️ MONEY-CRITICAL ORDER — do not invert
Gateway freshness guard rejects ALL claims when `balance_updated_at` is NULL/stale. If gateway activates before the bot is pushing fresh balance → **withdrawal lane freezes system-wide**.

1. **Recommended: STAGING/SEAL first** → run live-test J1–J4 (`ψ/inbox/handoff/2026-06-21_13-25_livetest-gwx02-overdraw-journey.md`) → confirm GREEN → then prod.
2. **Phase 1 — bankbot FIRST:** `gh workflow run deploy.yml -f bank=all -f component=bot -f image_tag=<tag>` (roll new ECR image onto ECS); verify bots pushing balance each tick.
3. **Phase 2 — gateway:** `supabase functions deploy bot-balance` (+ other changed EFs), then `supabase db push 20260621000900` (IPv4 pooler; `--include-all` if intervening migs skipped). **Warm-up:** immediately backfill `UPDATE bank_account SET balance_updated_at = app_now() WHERE last_heartbeat_at > app_now() - interval '90s'` (or set `balance_freshness_threshold_seconds` generous for a few min) so the guard doesn't reject during warm-up.
4. **Phase 3 — verify:** live-test J1–J4 on the env; watch `monitoring_alert` for `stale_balance`; confirm claims flow + no over-draw.

## Rollback
Forward-only migration; rollback = redeploy prior `claim_withdrawal_items`/`bot_update_balance`/`mark_*` bodies (`20260620000700` + wallet007) and stop reading `reserved`/`balance_updated_at`. Stage those before starting.

**Ping back to orchestrator (campaign 41-o-business-gap) when staging GREEN and again after prod.**
