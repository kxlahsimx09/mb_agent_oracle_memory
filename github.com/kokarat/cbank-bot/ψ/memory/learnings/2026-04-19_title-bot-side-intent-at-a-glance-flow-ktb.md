---
title: ---
tags: [technical-writer, repo:bank-bot, current, flow, flow:ktb-login-with-otp, ktb, login, otp, playwright, reverse-engineered, ratification-pending, s4, bot-first]
created: 2026-04-19
source: W8 authoring pass ktb-login-with-otp, 2026-04-19T18:20+07:00
project: github.com/kokarat/cbank-bot
---

# ---

---
title: bot-side intent at a glance — flow ktb-login-with-otp (split from ktb-single-transfer-withdrawal)
tags: [technical-writer, repo:bank-bot, current, flow, flow:ktb-login-with-otp, ktb, login, otp, playwright, reverse-engineered, ratification-pending, s4, bot-first]
created: 2026-04-19
source: docs/flows/ktb-login-with-otp.md@post-author (bank-bot); parent flow ktb-single-transfer-withdrawal via thread 21 Q5 REVISE
project: github.com/kokarat/bank-bot
---

# bot-side intent at a glance — flow ktb-login-with-otp (split from ktb-single-transfer-withdrawal)

One-sentence purpose: when bank-bot starts or when `ensureLoggedIn` decides the stored session is dead, the KTB module authenticates a single Playwright session against `business.krungthai.com` using three fields (`company_code` + `username` + `password`), navigates past an optional post-submit OTP challenge (SMS then email via gateway OTP relay), and persists the cookie jar so every downstream flow can skip re-authentication.

## What this doc covers

- **Bot-first flow** — no mobiz sibling exists or is anticipated. Login is entirely bot-internal.
- Three-field KTB login (different from SCB's two-field), human-typed with 100ms jitter.
- Two session-reuse short-circuits (URL-based + dashboard-card-based) locked in by incident PAY1776223012UD30I2.
- Optional OTP challenge after password submit, Phase 1 SMS 60s + Phase 2 email 180s = 240s budget, matching transfer-OTP timing.
- `dismissPopups` handling for three popup classes (session-expired, error-dialog, transfer-detail-side-panel) at multiple points.
- Two drifts filed as `#drift` learnings this pass:
  - `DRIFT-login-imap-fallback` — login OTP has no IMAP fallback; relay is a hard dependency for login-time OTP.
  - `DRIFT-login-otp-confirm-sentinel` — no `KTB_POST_OTP`-equivalent at login-OTP confirm click.

## What this doc explicitly does NOT cover

- First `updateBalance` + `reportStatus('online')` emissions after login — those belong to `ktb-single-transfer-withdrawal §Implementation pointers Step 0a`.
- KTB statement scrape / balance scrape mechanics — `deposit-auto-match-from-statement.md`.
- Transfer OTP — `ktb-single-transfer-withdrawal.md §Step 6`. Similar timing but distinct `getOTP` closure path with IMAP fallback.
- SCB login — different two-field + email-OTP-only flow; not authored yet.

## Linear vs loop-wrapped mermaid

Chose **linear** with `alt/else` for the OTP branch + nested `loop` for the Phase 1/2 polls. Divergence from sibling bot-side docs (scb-dual-control-withdrawal and ktb-single-transfer-withdrawal both loop-wrap) is intentional: per `workflow-8-flow-map.md §Design notes loop-vs-linear`, loop-wrap is for long-lived processes with distinct init/iteration phases. Login is a single-shot request-response path. Sibling consistency at the cost of misrepresenting the flow's shape would be worse than the divergence. Captured as Q2 in thread for ratification.

## Scope boundary

- **Start:** `page.goto(BASE_URL)` + first `dismissPopups`.
- **End:** `saveStorage('ktb-transfer')` after post-OTP dashboard visible.
- **Between:** 13 numbered mermaid steps (including two session-reuse short-circuits expressed as `Note over` for brevity).

## Claim strength + ratification

- Current **S4**, `[RATIFICATION_PENDING:TBD]` — thread id lands in change log post-filing.
- Four judgement calls: (Q1) bot-first framing + `#cross-repo-sync-bot-first` breadcrumb tag, (Q2) linear mermaid variant, (Q3) scope stops at `saveStorage`, (Q4) `ensureLoggedIn`/`checkSession` as re-entry guards not first-class steps.

## Related

- W8 root trace: `ff47aa94-4c5a-46fa-a33a-1c1b60aa264f` (bank-bot side).
- Parent flow: `ktb-single-transfer-withdrawal` (split from via thread 21 Q5 REVISE, ratified S2 via same thread).
- Cross-repo counterpart: NONE (bot-first). Breadcrumb still filed so a future mobiz W8 on `bot-otp-relay` can discover the boundary.
- Bot-side flow portfolio after this pass: `scb-dual-control-withdrawal`, `deposit-auto-match-from-statement`, `ktb-single-transfer-withdrawal`, `ktb-login-with-otp` -> 4 docs.

---
*Added via Oracle Learn*


---
*Added via Oracle Learn*
