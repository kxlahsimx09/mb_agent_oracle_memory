---
title: flow cross-repo breadcrumb (bot side) — ktb-keepalive-session-rotation is bot-fi
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, flow, flow:ktb-keepalive-session-rotation, cross-repo-sync, cross-repo-sync-bot-first, mobiz-payment-gateway, ktb, keepalive, session, angular-router, reverse-engineered, ratification-pending, thread-32]
created: 2026-04-21
source: W8 flow-map authoring pass — ktb-keepalive-session-rotation, 2026-04-21 GMT+7
project: github.com/kokarat/bank-bot
---

# flow cross-repo breadcrumb (bot side) — ktb-keepalive-session-rotation is bot-fi

flow cross-repo breadcrumb (bot side) — ktb-keepalive-session-rotation is bot-first, no mobiz sibling anticipated

Keepalive is entirely bot-internal: `KTBModule.keepSessionAlive` (`banks/ktb/index.js:232-312`) rotates the Playwright session through a real Angular route change (click account card → dashboard/account-detail → sidebar → back to dashboard) so KTB's server-side session timer actually resets. No gateway endpoint is called, no `withdrawal_queue` row is touched, no bank-statement payload is produced, no OTP is fetched. The only way mobiz-payment-gateway learns about a keepalive failure is indirectly via the `bot-bootstrap-and-status-reporting.md §Step 8c` contract: when keepalive throws `KTB_SESSION_DEAD`, the caller runs `resetBrowser`, and the bot reports `status=offline msg=login-not-ready` on the subsequent pollLoop tick while the new Chromium reboots.

**This breadcrumb exists so a future hypothetical mobiz-side W8** — e.g. a `bot-health-dashboard` flow that renders keepalive telemetry or a `bot-session-lifecycle-monitor` that ingests `KTB_SESSION_DEAD` events into bot-health dashboards — can discover this counterpart via a cross-repo search on `flow:ktb-keepalive-session-rotation` or `cross-repo-sync ktb-keepalive` without needing a retag. Per scb-dual-control-withdrawal's cross-repo breadcrumb (`#cross-repo-sync-bot-first`), bot-first flows still publish a reciprocal even when no mobiz sibling is expected today — the cost of the breadcrumb is a few learnings, the benefit is cross-repo discoverability indefinitely.

**Why keepalive warrants its own flow doc rather than a subsection of ktb-single-transfer-withdrawal:** per the W8 spec decomposition-asymmetry note, the rotation choreography has distinct actors (BankBot ↔ KTBPortal only; no Gateway, no OTPService), distinct preconditions (idle-only, no maintenance), distinct incident history (`0170681475` 24h stall 2026-04-11 + `0170679675`/`0170689786` stuck-on-detail 2026-04-13), distinct error class hierarchy (`KTB_KEEPALIVE_CARD_MISSING` latent, `KTB_SESSION_DEAD` fatal-to-caller, `KTB_KEEPALIVE_NON_FATAL` swallowed), and distinct recovery contract (throw sentinel → caller resetBrowser). Subsuming it into `ktb-single-transfer-withdrawal` § Idle branch would make the sibling flow carry its full 250-line complexity as a sub-point when the keepalive is called from TWO different idle branches (transfer-idle at `app.js:1836` AND pollLoop-idle at `app.js:2129`) and is also called privately from `scrapeStatement` at `banks/ktb/index.js:158` — the flow is shared across three call sites that belong to three different owning flows.

**Sibling flow cross-links:** `ktb-single-transfer-withdrawal.md §Idle branch + §Implementation pointers Step 10` references keepalive; `deposit-auto-match-from-statement.md` references it indirectly via the scrape-time `_keepSessionAlive` internal helper; `bot-bootstrap-and-status-reporting.md §Postconditions` + §Step 8c covers the `resetBrowser` contract that fires on `KTB_SESSION_DEAD`. This flow is the single source of truth for the rotation mechanics; sibling flows link here rather than re-describing.

**W8 trace:** `64ac74f3-0749-4d9b-9681-bf4bc3b6cba9` (bot-first, no mobiz trace to sibling-link).
**Ratification thread:** `32` (four judgement calls: scope boundary, `[DRIFT-keepalive-err-code-string-vs-constant]` promotion, mermaid linear-vs-loop, incident-ID citation style).
**Commit:** `docs/flows/ktb-keepalive-session-rotation.md@<new-commit>` on branch `docs/flow-ktb-keepalive-session-rotation`.

Tags: technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, flow, flow:ktb-keepalive-session-rotation, cross-repo-sync, cross-repo-sync-bot-first, mobiz-payment-gateway, ktb, keepalive, session, angular-router, reverse-engineered, ratification-pending, thread-32

---
*Added via Oracle Learn*
