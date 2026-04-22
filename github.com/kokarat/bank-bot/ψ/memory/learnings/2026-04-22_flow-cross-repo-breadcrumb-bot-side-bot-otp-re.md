---
title: flow cross-repo breadcrumb (bot side) — bot-otp-relay crosses from bank-bot into
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, flow, flow:bot-otp-relay, cross-repo-sync, mobiz-payment-gateway, otp, gateway-relay, bot-first]
created: 2026-04-22
source: docs/flows/bot-otp-relay.md@b71aff4 + mobiz-payment-gateway/controllers/BotConfigController.go:119-165 + :231-320 + routes/bot.go:37-52
project: github.com/kokarat/bank-bot
---

# flow cross-repo breadcrumb (bot side) — bot-otp-relay crosses from bank-bot into

flow cross-repo breadcrumb (bot side) — bot-otp-relay crosses from bank-bot into mobiz-payment-gateway territory at step 2 (the `GET /api/v1/bot/otp/:acc_number/:reference_code` HTTP call). Our side owns the poll-loop mechanics: timeout budget, pollMs cadence, 404-retry, 5xx-swallow, hit-return. The mobiz-payment-gateway side owns the handler at `controllers/BotConfigController.go:119-165 / GetOTP` — a MongoDB findOne on `otp_logs` filtered by (acc_number, otp_expires_at > now, reference_code). Everything downstream of that findOne — the upstream POST writer (`BotConfigController.go:231-320 / SaveOTPLog`, the /bot/otp-log endpoint called by the separate OTP service) plus the otp_logs TTL policy plus the source field semantics — is mobiz-side territory. Bank-bot never POSTs to /otp-log; only the external OTP service does. No mobiz-side counterpart `docs/flows/bot-otp-relay.md` has been authored on the mobiz-payment-gateway repo at this time — when mobiz W8 runs on this slug, it should file the symmetric breadcrumb with the mirror tag set and arra_trace_link(prev=ce35d223-bab7-4bab-bc9f-94b3875a002d, next=<mobiz W8 trace>). Contract points bank-bot exposes to the OTP service (via Gateway, not directly): none — the OTP service writes to Gateway; bank-bot reads from Gateway. Contract points Gateway exposes to bank-bot: `GET /api/v1/bot/otp/:acc_number/:reference_code` returns `{success:true, data:{otp, source, reference_code, expires_at}}` on hit, `{success:false, message:"No OTP available"}` with HTTP 404 on miss, arbitrary 5xx on Gateway/Mongo outage (bot swallows and retries). Empty-ref `''` substitutes `_` placeholder at `core/api.js:143` and Gateway treats `_` as a wildcard returning the latest unexpired row for the account. Bot W8 trace: ce35d223-bab7-4bab-bc9f-94b3875a002d. Mobiz W8 trace: not yet authored. Ratification thread: #39 (bank-bot side). Related prior breadcrumbs naming this slug as future territory: `learning_2026-04-19_cross-repo-sync-bot-first-breadcrumb-bot-side` (from ktb-login-with-otp W8 pass, 2026-04-19).

---
*Added via Oracle Learn*
