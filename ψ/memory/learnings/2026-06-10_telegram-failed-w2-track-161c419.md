---
title: telegram-failed — W2 bank-bot 2026-06-10 track 161c419 narrative not sent (no telegram_send tool)
tags: [technical-writer, repo:cross, current, telegram-failed, workflow-bug, workflow-2]
created: 2026-06-10
source: W2 pass a1e405e..161c419 (PR #134) Step 6b
project: github.com/kokarat/bank-bot
related:
  - 2026-06-10_w2-pass-track-a1e405e-161c419-no-op
---

# telegram-failed — W2 2026-06-10 track 161c419

Step 6b (Telegram narrative summary) could not run: the `telegram_send` MCP tool
(`github.com/Soul-Brews-Studio/mcp-telegram`) is **not connected in this session** —
ToolSearch for "telegram" returned no such tool. Same gap as the 2026-06-01 / 06-04 / 06-06
backlog noted in the prior W2 retro. PR + baseline bump are the load-bearing artefacts and
already landed; this is the delivery vehicle only.

**Error string:** `telegram_send tool not available in session (no MCP telegram server connected)`.

**Intended HTML body (ready to re-send when the tool returns):**

```html
<b>🤖 W2 bank-bot — baseline ตามทันแล้ว (no-op pass)</b>

รอบนี้เป็น catch-up ล้วน: PR #132 (W2 รอบก่อน) merge เข้า main แล้ว
ระบบจึงเลื่อน docs/.baseline ให้ตามทัน HEAD เฉยๆ — ไม่มีโค้ดบอตเปลี่ยน
(app.js / อะแดปเตอร์ SCB+KTB / core ยังเหมือนเดิมทุกไบต์มาหลายรอบแล้ว)
จึงไม่มี doc ต้องแก้ และ current-system.md สะท้อน HEAD อยู่แล้ว

<b>รายละเอียด</b>
• Commits: <code>a1e405e..161c419</code> (2 commits, ไม่แตะ territory)
• PR: <a href="https://github.com/kokarat/bank-bot/pull/134">#134</a>
• Learnings: 0 refresh · 0 drift · 1 new (#no-drift-found)
• Cross-repo: bot-internal only — ไม่กระทบ contract กับ mobiz

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>
```

Backlog now: 4 unsent `#telegram-failed` notes (2026-06-01, 06-04, 06-06, 06-10).
Worth a brew-ops handoff to reconnect the mcp-telegram server to the bot-writer cron session.
