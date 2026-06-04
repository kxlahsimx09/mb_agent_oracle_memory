---
title: telegram-failed — W2 amend PR #507 (a011daf..a9a3acb) summary not sent (no telegram_send tool in session)
tags: [technical-writer, repo:mobiz-payment-gateway, repo:cross, current, telegram-failed, workflow-bug, w2]
created: 2026-06-01
source: workflow-2-track-commit.md Step 8b fallback
project: github.com/kokarat/mobiz-payment-gateway
---

**Error:** `telegram_send` MCP tool unavailable in this session — the
`mcp-telegram` server was not connected (ToolSearch for "telegram" returned no
deferred tool). W2 Step 8b could not post the narrative summary for the PR #507
amend (cumulative `a011daf..a9a3acb`). Per the Step 8b fallback this is filed so
a future session with the MCP connected can re-send. The PR + doc updates are the
load-bearing artefacts and are already live; Telegram is only the delivery vehicle.

**Intended HTML body (parse_mode=HTML, disable_web_page_preview=true):**

```html
<b>📝 W2 mobiz-payment-gateway — แอดมินแก้ bank account ได้ทุกใบ + log refund payout ค้นเจอแล้ว</b>

วันนี้มี commit ใหม่ 2 ตัวต่อยอด PR #507 (W2 amend). <b>#509</b> ให้แอดมินแก้ไขบัญชีธนาคารใบไหนก็ได้ — ข้าม 2FA, การตรวจเจ้าของ และสถานะ pending (RBAC ที่ route ยังกันอยู่ชั้นเดียว ฝาก security_auditor ช่วยดู). <b>#505</b> แก้ปัญหาหน้าแอดมิน "กรองตาม wallet" ที่เคยเห็นแต่แถวหักเงิน ไม่เห็นแถวคืนเงิน — ตอนนี้ refund ของ payout เขียน log เป็น entity=wallet ตรงกับฝั่งหัก และค้นด้วยเลข PAY/DEP/TOP/STL วิ่งเข้า index แทน regex (เดิม 500 เพราะ timeout). ยอดเงินถูกต้องมาตลอด ผิดแค่ index.

<b>รายละเอียด</b>
• Commits: <code>bf57c0e..a9a3acb</code> (2 commits; สะสม a011daf..a9a3acb)
• PR: <a href="https://github.com/kokarat/mobiz-payment-gateway/pull/507">#507</a> (amended)
• Learnings: 0 refresh · 0 drift · 2 new
• Finance API (#483) ยัง defer ไป W1 (DRIFT-16) — baseline ค้างที่ a011daf

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>
```
