---
title: W9 partial-coverage / threshold-overrun — bank-bot W9 pass 2026-05-01 over range
tags: [technical-writer, repo:bank-bot, current, flow-track, partial-coverage, threshold-overrun, deferred-sweep]
created: 2026-05-01
source: docs/flows/.baseline + W9 trace 01a64ce4-239a-4591-bfb8-22aa05101d99
project: github.com/kokarat/bank-bot
---

# W9 partial-coverage / threshold-overrun — bank-bot W9 pass 2026-05-01 over range

W9 partial-coverage / threshold-overrun — bank-bot W9 pass 2026-05-01 over range b74e745..84e6649 hit the >5-flow-doc fast-fix threshold. Only one in-territory PR landed code in the range (#110 / 20289a3 + the surrounding W2 doc commit), but its target file `app.js` is cited by 11 of 11 flow docs. PR #110 inserted +47 lines and removed -11 lines across 8 hunks confined to balance-update call sites; mechanically every flow-doc app.js pointer below line 395 (the first hunk) requires Class B line-shift correction, and every pointer's `@<short>` should refresh to `20289a3` per Class A. Doing the full sweep across 11 flow docs would exceed fast-fix scope (10+ pointers per doc in some cases). This pass scoped down to only `scb-dual-control-withdrawal.md` — the single flow whose §Implementation pointers explicitly addresses balance/dashboard concerns at Step 10/11. The remaining 10 flow docs (`bot-bootstrap-and-status-reporting`, `bot-maintenance-mode-window`, `bot-otp-imap-fallback`, `bot-otp-relay`, `ktb-keepalive-session-rotation`, `ktb-login-with-otp`, `ktb-single-transfer-withdrawal`, `queue-claim-to-processing-state-machine`, `scb-login`) carry stale-by-line-shift app.js pointers; their step claims remain semantically correct. `docs/flows/.baseline` deliberately NOT bumped (per W9 §Step 6 "bump only if every item in the affected pointer set was processed"); next W9 pass inherits the same `b74e745` baseline + same range and can complete the sweep, OR escalate to a focused per-bank-doc batch. Behavior risk is bounded: the broader app.js pointers cite unrelated functions (login, OTP, recipients, claim, dispatch). No flow's step semantic broke; only line-number pointer freshness slipped.

---
*Added via Oracle Learn*
