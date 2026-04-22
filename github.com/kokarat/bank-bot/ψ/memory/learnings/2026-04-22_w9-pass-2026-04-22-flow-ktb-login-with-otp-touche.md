---
title: W9 pass 2026-04-22: flow ktb-login-with-otp touched by commits 5cb8cb3..338070b 
tags: [technical-writer, repo:bank-bot, current, flow-track, flow:ktb-login-with-otp]
created: 2026-04-22
source: docs/flows/ktb-login-with-otp.md
project: github.com/kokarat/bank-bot
---

# W9 pass 2026-04-22: flow ktb-login-with-otp touched by commits 5cb8cb3..338070b 

W9 pass 2026-04-22: flow ktb-login-with-otp touched by commits 5cb8cb3..338070b (single in-territory commit c4e0cf7 PR #96). Outcome: A=1 (Step 5 welcome click hash refresh), B=4 (Step 7 submit click line shifted 452→461; Step 8 dashboard poll 456-493→465-502; Step 8a break 483→492; Step 8b OTP path 497-506→506-515 — all due to +9 LOC inserted in fill block above), C=1 (Step 6 three-field humanType — impl description omits new field.fill('') clear-before-type behavior), D=0, E=0, F=0. One orphan-marker also surfaced (header [RATIFICATION_PENDING:23] still live though thread #23 closed 2026-04-20). Cross-repo: flow is bot-internal (no mobiz sibling per its own §Related flows), so Step 5e #cross-repo-sync not fired here; the placeholder-rename's cross-repo dimension is captured in tester's mock-bank drift learning, not in this W9.

---
*Added via Oracle Learn*
