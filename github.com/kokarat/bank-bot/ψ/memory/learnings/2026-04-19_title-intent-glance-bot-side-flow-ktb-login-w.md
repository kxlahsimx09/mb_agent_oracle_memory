---
title: intent-glance bot-side flow ktb-login-with-otp (split via thread 21 Q5 REVISE, thread 23 pending)
tags: [technical-writer, repo:bank-bot, current, flow, flow:ktb-login-with-otp, ktb, login, otp, playwright, reverse-engineered, ratification-pending, s4, bot-first]
created: 2026-04-19
source: docs/flows/ktb-login-with-otp.md@post-author (bank-bot); parent ktb-single-transfer-withdrawal via thread 21 Q5 REVISE; ratification via thread 23
project: github.com/kokarat/bank-bot
---

# intent-glance bot-side flow ktb-login-with-otp (split via thread 21 Q5 REVISE, thread 23 pending)

One-sentence purpose: authenticate a single Playwright session against KTB Business using three fields, navigate past optional post-submit OTP challenge (SMS then email via gateway OTP relay, 240s budget), persist cookie jar so downstream flows can skip re-auth.

## What this doc covers
- Bot-first flow — no mobiz sibling exists or anticipated.
- Three-field KTB login (different from SCB two-field).
- Two session-reuse short-circuits locked by incident PAY1776223012UD30I2.
- Optional OTP challenge, Phase 1 SMS 60s + Phase 2 email 180s.
- `dismissPopups` handling for three popup classes.
- Two inline drifts (`DRIFT-login-imap-fallback`, `DRIFT-login-otp-confirm-sentinel`) filed as learnings this pass.

## Linear vs loop-wrapped mermaid
Chose **linear** with `alt/else` for OTP branch + nested `loop` for polls. Intentional divergence from loop-wrapped siblings (scb-dual-control-withdrawal, ktb-single-transfer-withdrawal) because login is single-shot request-response, not long-running. Captured as Q2 in thread 23.

## Scope boundary
- Start: `page.goto(BASE_URL)` + first `dismissPopups`.
- End: `saveStorage('ktb-transfer')` after post-OTP dashboard visible.
- First `updateBalance` + `reportStatus('online')` explicitly OUT OF SCOPE (belongs to ktb-single-transfer-withdrawal Step 0a).

## Claim strength
- **S4**, `[RATIFICATION_PENDING:23]`.
- Four judgement calls in thread 23: bot-first framing, linear mermaid, scope at saveStorage, ensureLoggedIn positioning.

## Related
- W8 root trace: `ff47aa94-4c5a-46fa-a33a-1c1b60aa264f`.
- Parent flow: `ktb-single-transfer-withdrawal` (split via thread 21 Q5 REVISE, ratified S2 via same thread).
- Cross-repo counterpart: NONE (bot-first). Only cross-repo crossing is Steps 9b/9f OTP relay.
- Bot-side portfolio after this pass: 4 docs (`scb-dual-control-withdrawal`, `deposit-auto-match-from-statement`, `ktb-single-transfer-withdrawal`, `ktb-login-with-otp`).

## Supersedes (housekeeping)
Replaces typo learning `learning_2026-04-19_title-bot-side-intent-at-a-glance-flow-ktb` (project field had typo `cbank-bot` instead of `bank-bot`, causing file to land in a bogus ghq path). Same content, correct project.

---
*Added via Oracle Learn*


---
*Added via Oracle Learn*
