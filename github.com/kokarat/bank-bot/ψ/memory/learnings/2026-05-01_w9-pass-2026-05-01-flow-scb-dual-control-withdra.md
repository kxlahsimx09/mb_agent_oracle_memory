---
title: W9 pass 2026-05-01: flow `scb-dual-control-withdrawal` touched by commits b74e74
tags: [technical-writer, repo:bank-bot, current, flow-track, flow:scb-dual-control-withdrawal, scb, balance]
created: 2026-05-01
source: docs/flows/scb-dual-control-withdrawal.md
project: github.com/kokarat/bank-bot
---

# W9 pass 2026-05-01: flow `scb-dual-control-withdrawal` touched by commits b74e74

W9 pass 2026-05-01: flow `scb-dual-control-withdrawal` touched by commits b74e745..84e6649 (one in-territory PR: #110 / 20289a3 — SCB dashboard fallback regex-match guard + SCB→backend balance mapping swap). Outcome: A:1 hash refresh (banks/scb/dashboard.js), B:3 line-shift relocations (app.js Step 10/Step 11/viewer pointers — +10 line shift from PR #110's two upstream comment-block hunks at line 395 and 660), C:0, D:0, E:0, F:0. Plus a flow-doc Step 11 prose update enumerating the 8 SCB api.updateBalance call sites and their newly-swapped semantics (backend `balance` ← SCB cash-available, backend `available_balance` ← SCB account-total). The flow's higher-level step claim ("balance is updated", "scrape balance") is unaffected — the swap is below the abstraction level the flow doc commits to. Note: this pass is partial. >5 flow docs cite app.js pointers (11 total). The other 10 flow docs' app.js pointers below line 395 are unshifted (Class A) but pointers above are shifted (Class B); per fast-fix threshold (>5 affected flows = escalate), only the dashboard/balance-explicit flow was processed. `docs/flows/.baseline` NOT bumped this pass; partial-coverage learning filed; next W9 catches up. W9 trace: 01a64ce4-239a-4591-bfb8-22aa05101d99 (chained from W2 trace 16fe84a6-4805-4718-b4b3-8ccc3828cefc).

---
*Added via Oracle Learn*
