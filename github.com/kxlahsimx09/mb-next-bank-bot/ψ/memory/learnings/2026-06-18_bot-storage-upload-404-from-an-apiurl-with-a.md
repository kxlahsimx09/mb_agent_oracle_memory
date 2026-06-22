---
title: bot Storage-upload 404 from an `API_URL` with a `/functions/v1` suffix — the foo
tags: [repo:cross, bot, storage, gotcha, api-url, botlog, payout, brew-ops]
created: 2026-06-18
source: campaign payoutenvfix + payoutactlog* orchestration 2026-06-18 (retro 09.28 UTC)
project: github.com/kxlahsimx09/mb-next-bank-bot
---

# bot Storage-upload 404 from an `API_URL` with a `/functions/v1` suffix — the foo

bot Storage-upload 404 from an `API_URL` with a `/functions/v1` suffix — the footgun + the source-split design. The bot's `core/storage-client.js` builds the Supabase Storage PUT by STRING-CONCAT: `${API_URL}/storage/v1/object/<bucket>/<key>`. If the ECS task-def's `API_URL` carries the Edge-Functions suffix (`https://<ref>.supabase.co/functions/v1`), the PUT becomes `…/functions/v1/storage/v1/object/…` → hits the Functions router → 404 `Requested function was not found`. EF calls do NOT break on the same env because they use `new URL(absolutePath, base)` (an absolute `/functions/v1/...` path discards the base's path component). Symptom: payout proof silently dropped (`[Storage] upload failed (proof skipped, non-fatal)` ×N) while every EF call works. Fix applied: set `-payout` `API_URL` to the CLEAN project origin (`https://<ref>.supabase.co`) — EF URLs byte-identical, only the storage PUT repaired (mb-next-bankbot-payout rev :11/:12, 2026-06-18). Durable fix (flagged, not yet done): make storage-client strip a trailing `/functions/v1` (or derive the Storage origin from SUPABASE_URL). Related design: bot payout ACTIVITY-log = a SECOND, ADVISORY writer (source='bot') alongside the AUTHORITATIVE gateway dual-writer (source='gateway'); §ADR-15 §Amendment 2026-06-18 PA1–PA6 (#590). The bot lane lives in payout-app.js (the `-payout` ECS service) — distinct from the statements bot (app.js, `-bot`/`-ktb`); a payout that only shows login_success in the log is because the payout lane wasn't wired + the statements bot emits login_success on the shared account.

---
*Added via Oracle Learn*
