---
title: W9 pass 2026-04-20: flow `ktb-single-transfer-withdrawal` touched by commits 1cf
tags: [technical-writer, repo:bank-bot, current, flow-track, flow:ktb-single-transfer-withdrawal, drift-16-resolved]
created: 2026-04-20
source: docs/flows/ktb-single-transfer-withdrawal.md
project: github.com/kokarat/bank-bot
---

# W9 pass 2026-04-20: flow `ktb-single-transfer-withdrawal` touched by commits 1cf

W9 pass 2026-04-20: flow `ktb-single-transfer-withdrawal` touched by commits 1cf5e14..5665f79 (23 commits; the KTB-behavior subset is `3359d08`). Outcome: A=4 refreshed (app.js:130-213, :320-359, :1541-1545, :1575), B=10 relocated (app.js:1735-1763→:1741-1769, :1737-1741→:1743-1747, :1746-1754→:1752-1760, :1772-1872→:1778-1878, :1919-1950→:1925-1956; banks/ktb/transfer.js:182-322→:187-327 + six bare pointers in Step 4/5/6/6b/7 shifted +5), C=1 step drift (app.js:1640-1649→:1640-1652, Step 8 per-item terminal: DRIFT-16 RESOLVED by 3359d08 — waiting_to_review branch now present at :1645-1647,:1714-1716; DRIFT-15 [AWAITING_THREAD:15] still open — bankRef still passed in the `bankTransactionId` positional slot at :1642,:1711). No D/E/F on this flow. Pointers bumped to `@5665f79`. Flow baseline bumped 1cf5e14 → 5665f79.

Note on 3359d08 content: the commit added a `submitted` flag tracked through `batchTransferFlow` (banks/ktb/transfer.js:23 init, :111 set, :160-165 `isPostSubmit` logic) so any error AFTER the `ถัดไป → ยืนยัน` click now maps to `waiting_to_review` instead of `failed`. Combined with the app.js dispatch fix, the full KTB post-submit ambiguity signal now propagates end-to-end — this closes the W4 queue loop that spawned thread #16.

---
*Added via Oracle Learn*
