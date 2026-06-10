---
title: "#telegram-failed — W2 2026-06-08 narrative (PR #513 amend, Finance #515) could not be sent; telegram_send MCP unavailable"
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - repo:cross
  - current
  - finance
  - telegram-failed
  - workflow-bug
created: 2026-06-08
source: W2 Step 8b (telegram_send MCP not registered in this session)
related:
  - 2026-06-08_w2-finance-book-value-thb-folds-into-drift16
project: github.com/kokarat/mobiz-payment-gateway
---

W2 Step 8b could not post the Telegram narrative summary: the `telegram_send` MCP tool (`github.com/Soul-Brews-Studio/mcp-telegram`) is **not registered / not reachable** in this session (ToolSearch "telegram send message" returns no telegram tool). This is the same gap the 2026-06-06 pass (PR #513 original) hit. Error effectively: `tool unavailable — telegram MCP not configured`. Per W2 §Step 8b fallback the PR + doc edits are the load-bearing artifacts and were not blocked; this learning preserves the intended message so a future session with the MCP registered can re-send.

**Intended HTML body (parse_mode=HTML, disable_web_page_preview=true):**

```html
<b>📝 W2 mobiz-payment-gateway — Finance ยังถูกเลื่อน (deferred) ต่อ; โผล่ commit ใหม่ #515/#516</b>

PR #513 (ตัว track รายวันของ repo นี้) ถูก amend ต่อให้ครอบ commit ใหม่ 2 ตัวที่เพิ่งลง main. ตัวสำคัญคือ #515 ที่เพิ่ม <code>book_value_thb</code> รายบัญชีในหน้า balance ของ Finance — ทำให้ dashboard โชว์ Net Worth ที่ "ราคาทุน" (USDT คิดตามเรตตอนซื้อรายแถว ไม่ revalue) แล้ว reconcile กับ cashbook มือได้ (ก่อนหน้านี้เพี้ยน ~53k บาทบน ampay). แต่ทั้งฟีเจอร์ Finance ยังไม่มีใน current-system.md เลย — มันคือก้อนใหญ่ ~3,097 LOC ที่รอ re-baseline (Workflow 1) อยู่ (DRIFT-16) เลยแค่ "พับรวม" #515 เข้าไป ไม่ fast-fix. อีกตัว #516 เป็นแค่ k8s rolling-update นอกขอบเขต docs. baseline จึงยังตรึงที่ a011daf เหมือนเดิม — งานที่ค้างจริงคือ W1 finance pass ที่เริ่ม overdue.

<b>รายละเอียด</b>
• Commits: <code>602b6e3..8315189</code> (2 commits; cumulative a011daf..8315189)
• PR: <a href="https://github.com/kokarat/mobiz-payment-gateway/pull/513">#513</a>
• Learnings: 0 refresh · 1 drift (folded) · 0 new section
• baseline: HELD ที่ a011daf (Finance รอ W1 re-baseline)

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>
```

When the MCP is restored, re-send the block above to `TELEGRAM_DEFAULT_CHAT_ID` and record the returned `message_id`.
