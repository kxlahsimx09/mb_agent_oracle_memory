---
title: bot-side intent at a glance — flow ktb-login-with-otp (split from ktb-single-tra
tags: [technical-writer, repo:bank-bot, current, flow, flow:ktb-login-with-otp, ktb, login, otp, ratification-pending, s4, recovered-from-double-wrap, recovered-from-cbank-typo]
created: 2026-04-19
source: docs/flows/ktb-login-with-otp.md@post-author (bank-bot); split from ktb-single-transfer-withdrawal via thread 21 Q5 REVISE — recovered 2026-04-19 (also fixes cbank-bot project typo)
project: github.com/kokarat/bank-bot
---

# bot-side intent at a glance — flow ktb-login-with-otp (split from ktb-single-tra

bot-side intent at a glance — flow ktb-login-with-otp (split from ktb-single-transfer-withdrawal via thread 21 Q5 REVISE)

Bot-side intent for the `ktb-login-with-otp` flow doc in one paragraph: the bot acquires an authenticated KTB Corporate Online session before any withdrawal-queue claim runs, driven by a three-field login (company code, username, password) plus a phased OTP acquisition (SMS 60s → email 180s; IMAP fallback NOT present at login-time — DRIFT). Two session-reuse short-circuits at the top of the flow make subsequent claims skip re-login entirely: URL-based (`page.url()` already on a KTB authenticated path) and dashboard-card-based (transfers-card visible in DOM). Both locked in by incident PAY1776223012UD30I2 where the bot was re-logging on every claim.

Scope boundary: this flow doc was SPLIT from the parent `ktb-single-transfer-withdrawal.md` after thread 21 Q5 ratified REVISE — the phase-cascade OTP logic + session-reuse optimisations are substantial enough to deserve their own lifecycle doc separate from the outer claim loop. Parent keeps Step 0a as a precondition pointer; this doc owns the full login sequence.

Key mechanics: `reuseIfAlreadyOn` (URL-path predicate), `reuseIfBackedFromOTP` (post-OTP-return predicate), `goTo`, `clickLoginNow`, `fillAndSubmit` (three fields), OTP request, OTP polling with two phases, OTP confirm click, dashboard arrival. Cross-repo boundary at Steps 9b + 9f: `BB->>OTP: GET /bot/otp/:acc/:ref` is the only mobiz-side crossing — gateway-hosted OTP relay. Handler on mobiz side: `controllers/BotOtpController.go` (not verified this pass). Contract: `{ success, data: { otp, source } }` on hit, 404 on miss, `X-Bot-Secret` auth.

Two drifts surfaced during authoring (separate `#drift` learning captures details): login-time OTP lacks IMAP fallback that transfer-time OTP has; no `KTB_POST_OTP`-equivalent sentinel at login-OTP confirm click. Both are asymmetries between code paths that aren't justified in comments — harmonisation candidate for W4.

Claim strength: S4, `[RATIFICATION_PENDING:23]`. Thread #23 raises four judgement calls (slug, IMAP-drift-vs-intentional, confirm-sentinel-S4-vs-wait, cross-repo-sync-bot-first tag).

Related: W8 trace `ff47aa94-4c5a-46fa-a33a-1c1b60aa264f`. Parent flow `ktb-single-transfer-withdrawal.md` at `1cf5e14`. Cross-repo-sync-bot-first breadcrumb filed separately.

RECOVERED 2026-04-19 from double-wrap file `2026-04-19_title-bot-side-intent-at-a-glance-flow-ktb.md`. Note the original file was also affected by the `cbank-bot` project-field typo bug — the file was routed to `github.com/kokarat/cbank-bot/` instead of `github.com/kokarat/bank-bot/` because a stray `c` prefix character landed in the project input. This recovery fixes both bugs: double-wrap (content is now clean prose) and project typo (routed to the correct `github.com/kokarat/bank-bot`). Supersedes `learning_2026-04-19_title-bot-side-intent-at-a-glance-flow-ktb`.

---
*Added via Oracle Learn*
