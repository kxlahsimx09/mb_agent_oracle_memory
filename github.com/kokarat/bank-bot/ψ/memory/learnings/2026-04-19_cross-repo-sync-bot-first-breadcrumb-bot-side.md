---
title: cross-repo-sync-bot-first breadcrumb (bot side) — ktb-login-with-otp has no mobi
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, flow, flow:ktb-login-with-otp, cross-repo-sync-bot-first, ktb, login, otp, bot-first, recovered-from-double-wrap]
created: 2026-04-19
source: docs/flows/ktb-login-with-otp.md@post-author (bank-bot) — no mobiz sibling at authoring time (recovered 2026-04-19)
project: github.com/kokarat/bank-bot
---

# cross-repo-sync-bot-first breadcrumb (bot side) — ktb-login-with-otp has no mobi

cross-repo-sync-bot-first breadcrumb (bot side) — ktb-login-with-otp has no mobiz sibling, only a gateway-OTP-relay crossing

Bot-side W8 flow `ktb-login-with-otp` (file: `docs/flows/ktb-login-with-otp.md`) is bot-first — no mobiz-side sibling exists at authoring time 2026-04-19 and none is anticipated. Login to a bank portal is entirely bot-internal; mobiz never logs into a bank on behalf of bank-bot.

The only cross-repo crossing is Steps 9b + 9f of the bot-side sequence: `BB->>OTP: GET /bot/otp/:acc/:ref` — the bot polls the gateway-hosted OTP relay for SMS (Phase 1, 60s budget) or email (Phase 2, 180s budget). Handler on mobiz side is at `controllers/BotOtpController.go` (path not verified in this pass). Contract is stable: `{ success, data: { otp, source } }` on hit, `404` when no OTP available, `X-Bot-Secret` auth.

Why `#cross-repo-sync-bot-first`, not `#cross-repo-sync`: convention — a bot-side flow that has NO mobiz counterpart but DOES cross a repo boundary gets tagged `#cross-repo-sync-bot-first`. Tag precedent: `scb-dual-control-withdrawal.md` when authored 2026-04-19 had no exact mobiz counterpart and used this tag. The `-bot-first` suffix signals "this breadcrumb is waiting for the mobiz side to author a counterpart — if they do, the suffix is dropped on the next revision".

Query patterns this breadcrumb enables:
- `arra_search query="flow:ktb-login-with-otp cross-repo-sync"` returns this breadcrumb via `cross-repo-sync-bot-first` tag match on the prefix.
- `arra_search query="ktb-login-with-otp mobiz-payment-gateway"` returns this breadcrumb because the body names `mobiz-payment-gateway` in the "Handler on mobiz side" sentence.
- `arra_search query="bot-otp-relay cross-repo-sync"` — a future query from mobiz-writer authoring `bot-otp-relay.md` surfaces this breadcrumb as a pre-existing bot-side consumer of the endpoint.

Trace ids: bot-side W8 trace `ff47aa94-4c5a-46fa-a33a-1c1b60aa264f` (this pass, 2026-04-19). Mobiz-side W8 trace: none — if one gets authored on `bot-otp-relay`, this breadcrumb should be superseded by a `#cross-repo-sync` (no `-bot-first` suffix) variant that names both trace ids.

Bot-side-specific content NOT in any sibling: three-field login (unique to KTB corporate — SCB has two fields, BBL/KBANK unknown); two session-reuse short-circuits (URL-based + dashboard-card-based) locked in by incident PAY1776223012UD30I2; `[DRIFT-login-imap-fallback]` — login-time OTP has no IMAP fallback, unlike transfer-time OTP; `[DRIFT-login-otp-confirm-sentinel]` — no `KTB_POST_OTP`-equivalent sentinel at login-OTP confirm click.

Parent flow: `ktb-single-transfer-withdrawal.md` — its Q5 REVISE (thread 21 ratification 2026-04-19) explicitly split this scope out. Its Step 0 Note and §Implementation pointers Step 0 point here. `banks/ktb/login.js` entry points were preserved in the parent's §Implementation pointers as author hints for this future sibling; this pass consumed those hints.

RECOVERED 2026-04-19 from double-wrap file `2026-04-19_title-cross-repo-sync-bot-first-breadcrumb-b.md`; supersedes `learning_2026-04-19_title-cross-repo-sync-bot-first-breadcrumb-b`.

---
*Added via Oracle Learn*
