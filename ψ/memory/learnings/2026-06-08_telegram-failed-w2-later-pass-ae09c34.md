---
title: telegram-failed — W2 2026-06-08 later pass (8315189..ae09c34, PR #513) narrative not sent
tags: [technical-writer, repo:mobiz-payment-gateway, repo:cross, current, telegram-failed, workflow-bug, w2]
created: 2026-06-08
source: workflow-2-track-commit.md Step 8b fallback; PR #513
project: github.com/kokarat/mobiz-payment-gateway
---

**Error:** `telegram_send` MCP tool unavailable in this session (ToolSearch for "telegram_send"
returns no such tool — only PushNotification / arra_thread / etc.). This is the continuation of a
multi-session outage: prior fallback learnings on 2026-06-01 (PR #507), 2026-06-04 (no-op cadence
note), and 2026-06-04 (PR docs/track-e0e48a6) all record the same absence. The MCP
(`github.com/Soul-Brews-Studio/mcp-telegram`) is not registered for the pg-writer panes.

Per W2 Step 8b fallback: the PR + doc updates are the load-bearing artefacts and are already real;
Telegram is only the delivery vehicle. Next session that has `telegram_send` can re-send the body
below.

**Intended HTML body (unescaped):**

```html
<b>📝 W2 mobiz-payment-gateway — Finance surface โตต่อ แต่ยัง deferred ลง W1</b>

วันนี้มี commit ใหม่เข้า main 2 ตัว ทั้งคู่เป็น Finance API — ฟีเจอร์ใหม่ทั้งก้อนที่ยังไม่ถูก
documentate ใน current-system.md และถูกตั้งพักไว้รอ Workflow 1 re-baseline (DRIFT-16) มาตั้งแต่
ปลายพ.ค. รอบนี้จึงไม่ fast-fix แต่บันทึกทั้งสองตัวเข้าไปใน DRIFT-16 แทน แล้ว amend ต่อ PR #513 เดิม
(ไม่เปิด PR ใหม่). #519 เพิ่มปุ่มให้ฝ่าย operator เลือกแถวรายได้ MDR เป็น THB หลายแถวแล้วแปลงเป็น
USDT ทีเดียวตามเรทที่กรอก (กันแปลงซ้ำด้วย converted_pair_id); #518 แก้บั๊กที่ตัว auto-importer
หยุด import settlement ใหม่เงียบ ๆ เมื่อ owner มี settlement เกิน 200 รายการ (5 รายการค้าง ~775k
บาท ถูก backfill มือแล้ว). baseline ยังคาที่ a011daf — งานที่ค้างจริงคือ W1 re-baseline ของก้อน Finance.

<b>รายละเอียด</b>
• Commits: <code>8315189..ae09c34</code> (2 commits ใหม่ · cumulative <code>a011daf..ae09c34</code>)
• PR: <a href="https://github.com/kokarat/mobiz-payment-gateway/pull/513">#513</a> (amended)
• Learnings: 0 refresh · 1 drift (DRIFT-16 fold-in) · 0 new section
• ยังไม่ merge — รอ human review

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>
```

When re-sending: `telegram_send(text=<above>, parse_mode="HTML", disable_web_page_preview=true)`.
Capture the returned message_id in that session's retro.
