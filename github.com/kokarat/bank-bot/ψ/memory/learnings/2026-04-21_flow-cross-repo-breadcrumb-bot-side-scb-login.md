---
title: flow cross-repo breadcrumb (bot side) — scb-login is a bot-first flow with no mo
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, flow, flow:scb-login, cross-repo-sync, cross-repo-sync-bot-first, mobiz-payment-gateway, scb, login, bot-first]
created: 2026-04-21
source: docs/flows/scb-login.md@pre-commit + banks/scb/login.js@c491a82 + app.js@c491a82 (no mobiz-side code referenced — bot-internal flow)
project: github.com/kokarat/bank-bot
---

# flow cross-repo breadcrumb (bot side) — scb-login is a bot-first flow with no mo

flow cross-repo breadcrumb (bot side) — scb-login is a bot-first flow with no mobiz-payment-gateway counterpart. Login is entirely bot-internal; mobiz never authenticates against a bank portal on bank-bot's behalf. The only weak crossing is the credential supplier handshake — config.credentials.{role}[0] is fetched once at init() from GET /api/v1/bot/config/:account (covered in flow:bot-bootstrap-and-status-reporting §Step 2) and cached in-process for the bot's lifetime; this flow itself makes zero direct gateway calls. Same shape and convention as flow:ktb-login-with-otp's bot-first breadcrumb (recovered version learning_2026-04-19_cross-repo-sync-bot-first-breadcrumb-bot-side). Why this breadcrumb still exists despite no counterpart: the #cross-repo-sync-bot-first tag publishes the breadcrumb so a future hypothetical mobiz-side W8 pass on a bot-credentials-handshake flow can discover this counterpart without a retag — and so any cross-repo audit of repo:cross learnings sees the bot side's reach into mobiz territory acknowledged. Contract points the bot consumes from mobiz: GET /api/v1/bot/config/:account returning credentials.{maker,approver,viewer}[0] = { username, password } (consumed once at init, not per login). Contract points the bot exposes to mobiz: none from this flow. The implicit downstream signal — caller's first updateBalance + reportStatus('online') after a successful login — is the gateway-visible "bot is up" indicator and lives in scb-dual-control-withdrawal §Postconditions and bot-bootstrap-and-status-reporting respectively. Bot W8 trace: e61db885-eb3e-43b6-ab44-731357ad01e8. Mobiz W8 trace: not yet authored (no counterpart anticipated). Decomposition note for future readers: KTB has its own login flow doc (ktb-login-with-otp, 148 lines, includes per-login OTP branch); SCB's login is simpler (no OTP at login, only at approver-time) and this doc is correspondingly tighter — same precedent, different surface size. Companion to flow-cross-repo-breadcrumb-bot-side-scb-dual-control-withdrawal which covered the dual-control transfer mechanics in the same project.

---
*Added via Oracle Learn*
