---
title: W9 pass 2026-05-22: bank-bot flow-track range b74e745..6231444. This pass COMPLE
tags: [technical-writer, repo:bank-bot, current, flow-track, flow-drift, flow:ktb-single-transfer-withdrawal, flow:scb-dual-control-withdrawal, flow:queue-claim-to-processing-state-machine, app-js-line-shift, deferred-sweep-completion]
created: 2026-05-22
source: docs/flows/*.md@6231444 + app.js@20289a3
project: github.com/kokarat/bank-bot
---

# W9 pass 2026-05-22: bank-bot flow-track range b74e745..6231444. This pass COMPLE

W9 pass 2026-05-22: bank-bot flow-track range b74e745..6231444. This pass COMPLETED the deferred app.js line-shift sweep that the prior W9 (2026-05-01, trace 01a64ce4) left open citing the >5-flow fast-fix threshold. Sole flow-territory commit in range: 20289a3 (PR #110, SCB dashboard balance fix) which added +36 net lines to app.js across 8 hunks (at b74e745 lines 395/655/1141/1213/1540/1751/2150/2219), each a per-loop balance-fallback guard. The other range commits (4b968a4 create-bot.sh, 84e6649 update-all.sh, 6231444 stop-bot.sh) are deployment/§5 territory, not flow territory.

Outcome by flow (Class B line relocations + bump to @20289a3 for pointers below line 395; offset-0 pointers ≤394 kept at old hash per repo convention): bot-otp-relay (3), bot-otp-imap-fallback (3), ktb-keepalive-session-rotation (2), ktb-login-with-otp (1 + prose refs), scb-login (6 ensureLoggedIn sites), ktb-single-transfer-withdrawal (8 Class B + 2 Class C balance-swap, see paired #flow-drift learning), bot-bootstrap-and-status-reporting (6), bot-maintenance-mode-window (~14 incl. embedded sub-refs), queue-claim-to-processing-state-machine (~22), scb-dual-control-withdrawal (8 structural pointers the prior pass left stale while it did only the balance ones). Validation: offset model exactly matched all 15 app.js function boundaries (b74e745→HEAD) + every spot-check; deposit-auto-match-from-statement cites no app.js (no work). Only semantic finding: the KTB balance arg-swap (Class C). Everything else is mechanical line relocation, zero behavior drift. docs/flows/.baseline bumped b74e745 → 6231444.

---
*Added via Oracle Learn*
