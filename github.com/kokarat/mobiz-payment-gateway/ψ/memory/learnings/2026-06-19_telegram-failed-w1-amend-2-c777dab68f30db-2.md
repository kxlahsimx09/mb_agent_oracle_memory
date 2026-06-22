---
title: telegram-failed — W1 amend #2 (c777dab..68f30db, 2026-06-19) Step 7b could not s
tags: [tester, repo:cross, current, telegram-failed, workflow-bug, w1, w1-amend, slip-fraud, promotion]
created: 2026-06-19
source: workflow-1-validate-integration-tests.md Step 7b fallback + session 2026-06-19 (tester-telegram MCP not registered, fourteenth consecutive); PR #539 amend c777dab..68f30db (#559 7feb7d1 slip-fraud STALE→VALID promotion)
project: github.com/kokarat/mobiz-payment-gateway
---

# telegram-failed — W1 amend #2 (c777dab..68f30db, 2026-06-19) Step 7b could not s

telegram-failed — W1 amend #2 (c777dab..68f30db, 2026-06-19) Step 7b could not send: mcp__tester-telegram__telegram_send unavailable (FOURTEENTH consecutive).

Error: the tester-telegram MCP server (bot @ampay_test_alert_bot) is not registered/connected on this host. It was listed as "connecting" at session start but never surfaced a tool; ToolSearch for "tester-telegram telegram_send" returned only Slack/Canva/Oracle tools, no mcp__tester-telegram__*. Per task + workflow Step 7b, did NOT fall back to the generic writer-fleet `telegram` MCP (wrong channel/audience). W1 pass NOT blocked — PR #539 + docs/test-index.md are already pushed and real.

Intended Thai HTML body (parse_mode HTML, disable_web_page_preview true) that WOULD have been sent — re-send from here next session if tester-telegram comes online:

<b>🧪 W1 tester — slip-fraud test กลับมา VALID (STALE→VALID promotion)</b>

วันนี้ re-validate ทั้งชุด 49 tests หลัง #559 (7feb7d1) แก้ assertion ของ test-deposit-slip-fraud.sh ให้ตรงกับ payload/log แบบใหม่ของ #529/#532 (external-destination guard). ตรวจซ้ำกับโค้ดจริง (DepositController.go:896-918 + EvaluateSlipDestination) แล้ว — assertion ใหม่ตรงกับ behavior ปัจจุบันทุกจุด รวมถึง edge case ที่ pass ก่อนเคยกังวล (proxy receiver 9999999999 ยัง mismatch promptpay → 400 ไม่ว่า BANK_ACCOUNT จะเป็นค่าใด เพราะ slip มีแต่ proxy ไม่มี bank-account receiver) จึงเลื่อน STALE→VALID. ไม่มี regression ใหม่ — commit อื่นในช่วงนี้ (#555 k8s mem / #556 main.go log / #557 k8s secrets) inert/out-of-surface ทั้งหมด.

<b>รายละเอียด</b>
• Baseline: <code>c777dab..68f30db</code> (0 production-surface commits; 1 test-side fix #559)
• Tests validated: 49 — V=43 · S=2 · W=0 · F=0 · SUP=2 · ON_HOLD=2 · UNK=0
• Learnings: 1 (1 promotion STALE→VALID · 0 regression-candidates)
• PR: <a href="https://github.com/kokarat/mobiz-payment-gateway/pull/539">#539</a>

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>

This is a recurring infra gap (14 consecutive W1 passes since ~2026-06-01 could not send); the tester-telegram MCP has never been registered on the worktree hosts. Brew-ops / operator action needed to register it in ~/.claude.json (TELEGRAM_DEFAULT_CHAT_ID for @ampay_test_alert_bot).

---
*Added via Oracle Learn*
