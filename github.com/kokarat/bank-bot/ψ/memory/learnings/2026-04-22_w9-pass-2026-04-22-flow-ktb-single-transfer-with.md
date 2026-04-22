---
title: W9 pass 2026-04-22: flow `ktb-single-transfer-withdrawal` step 8 drift DRIFT-15 
tags: [technical-writer, repo:bank-bot, current, flow-track, flow:ktb-single-transfer-withdrawal, drift-resolved, drift-15, thread-15-closed, cross-repo-sync, repo:cross]
created: 2026-04-22
source: docs/flows/ktb-single-transfer-withdrawal.md + app.js:1642,1711@5cb8cb3 + arra_thread:15 (closed 2026-04-22)
project: github.com/kokarat/bank-bot
---

# W9 pass 2026-04-22: flow `ktb-single-transfer-withdrawal` step 8 drift DRIFT-15 

W9 pass 2026-04-22: flow `ktb-single-transfer-withdrawal` step 8 drift DRIFT-15 resolved by bank-bot commit `e3db48a` (PR #72, 2026-04-19, fixes #71). Prior state: `safeMarkSuccess(itemId, result.bankRef || '', '')` — bankRef in positional slot 2 (`bankTransactionId`) instead of slot 3 (`bankReference`) at both `app.js:1642` (batch branch) and `:1711` (single-item branch). Post-fix: `safeMarkSuccess(itemId, '', result.bankRef || '')`. Thread #15 closed 2026-04-22 GMT+7 after fix evidence landed in W9 range. Flow doc markers swept in same pass (§Purpose ¶2, §Success criteria, §Error paths, §Postconditions, §Implementation pointers Step 8) — `[AWAITING_THREAD:15]` stripped, replaced with `[DRIFT-15 RESOLVED via e3db48a]`; prose tense updated from "is" to "was" (P-004) while preserving drift narrative (P-001). Cross-repo sibling: mobiz `withdrawal-queue-single-bot-transfer.md` §Error paths carries the reciprocal marker which pg-writer's next W9 sweep will mirror-strip — the closed-thread signal on arra_thread:15 is the back-channel. Mobiz W9 cannot detect this drift directly because bot's `// ext: kokarat/bank-bot` marker is opaque to mobiz scans; this learning is the breadcrumb.

---
*Added via Oracle Learn*
