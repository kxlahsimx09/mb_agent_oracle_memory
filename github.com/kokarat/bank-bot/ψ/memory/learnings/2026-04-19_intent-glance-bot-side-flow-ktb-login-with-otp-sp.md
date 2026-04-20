---
title: intent-glance bot-side flow ktb-login-with-otp (split via thread 21 Q5 REVISE, t
tags: [technical-writer, repo:bank-bot, current, flow, flow:ktb-login-with-otp, ktb, login, otp, playwright, ratification-pending, s4, recovered-from-double-wrap]
created: 2026-04-19
source: docs/flows/ktb-login-with-otp.md@post-author (bank-bot); parent ktb-single-transfer-withdrawal via thread 21 Q5 REVISE; ratification via thread 23 — recovered 2026-04-19
project: github.com/kokarat/bank-bot
---

# intent-glance bot-side flow ktb-login-with-otp (split via thread 21 Q5 REVISE, t

intent-glance bot-side flow ktb-login-with-otp (split via thread 21 Q5 REVISE, thread 23 pending)

One-sentence purpose: bank-bot's single Playwright session logs into KTB Corporate Online (three-field + OTP) so a subsequent withdrawal-queue claim can execute without a relogin, delivering the OTP via one of three channels with explicit phase-cascade budgets.

What this flow doc covers: full login lifecycle — reuseIfAlreadyOn → reuseIfBackedFromOTP → goTo → clickLoginNow → fillAndSubmit (three fields: company `company`, username `user`, password `pass`) → OTP request → OTP polling (Phase 1 SMS 60s, Phase 2 email 180s — IMAP fallback NOT present at login-time, DRIFT) → OTP confirm click → dashboard reached. Two session-reuse short-circuits: URL-based (already on a KTB authenticated URL) and dashboard-card-based (transfers-card visible), both short-circuit to "already logged in" and return immediately. Both locked in by incident PAY1776223012UD30I2 where the bot was relogging-in on every claim because neither short-circuit existed.

What this doc explicitly does NOT cover: the outer withdrawal-queue claim loop (parent `ktb-single-transfer-withdrawal.md` owns that). What steps 9b + 9f cross to mobiz: `GET /bot/otp/:acc/:ref` is the gateway-hosted OTP relay. This is the only repo boundary in the flow.

Two drifts surfaced during this W8 authoring (filed as separate `#drift` learning):
- `[DRIFT-login-imap-fallback]` — login-time OTP polling never checks IMAP; transfer-time OTP polling does. Asymmetry not justified in code — candidate for harmonisation.
- `[DRIFT-login-otp-confirm-sentinel]` — no `KTB_POST_OTP`-equivalent sentinel at login-OTP confirm click. A failed confirm at login drops through to whichever downstream handler runs, without the explicit mark-failed-vs-waiting-to-review contract that transfer-time OTP has.

Claim strength + ratification: S4, `[RATIFICATION_PENDING:23]`. Thread #23 filed with four judgement calls: (1) doc slug `ktb-login-with-otp` vs `ktb-login`; (2) whether to treat IMAP-fallback asymmetry as drift or intentional; (3) whether to include the OTP confirm sentinel as S4 recommendation or wait for evidence; (4) cross-repo-sync-bot-first tag convention (see separate breadcrumb learning).

Related: W8 root trace `ff47aa94-4c5a-46fa-a33a-1c1b60aa264f`. Parent flow: `ktb-single-transfer-withdrawal.md` — thread 21 Q5 REVISE (ratified 2026-04-19) explicitly split login-with-OTP out of the parent's scope because the phase-cascade logic + session-reuse optimisations have their own lifecycle separate from the queue-claim loop. Cross-repo-sync-bot-first breadcrumb filed separately.

RECOVERED 2026-04-19 from double-wrap file `2026-04-19_title-intent-glance-bot-side-flow-ktb-login-w.md`; supersedes `learning_2026-04-19_title-intent-glance-bot-side-flow-ktb-login-w`.

---
*Added via Oracle Learn*
