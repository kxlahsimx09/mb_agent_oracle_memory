---
title: telegram-failed — W2 2026-06-17 track a011daf..03d6383 narrative not sent (MCP unregistered)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - repo:cross
  - current
  - telegram-failed
  - workflow-bug
created: 2026-06-17
source: W2 Step 8b @ 03d6383 ; PR https://github.com/kokarat/mobiz-payment-gateway/pull/540
project: github.com/kokarat/mobiz-payment-gateway
---

# Step 8b Telegram fallback — narrative not delivered

`telegram_send` (Soul-Brews-Studio/mcp-telegram) is **not registered as an MCP server in this session** — only `arra-oracle-v3` and `dpay` were connected. No `telegram_send` tool was available to call.

**Error / cause:** `telegram_send` MCP unavailable (server not connected this session). Same class as the tester role's recurring "tester-telegram MCP unregistered" failures noted in 2026-06-05/06-08 traces — the writer/pg-writer telegram MCP appears unregistered on these worktree wake-ups.

The PR (#540) is the load-bearing artefact; this is a delivery-vehicle miss only. Next session with the MCP registered can re-send the body below verbatim.

**Intended HTML body (parse_mode=HTML, disable_web_page_preview=true):**

```html
<b>📝 W2 mobiz-payment-gateway — เอกสารตามไม่ทันโค้ด: ถึงเวลา re-baseline (W1)</b>

ช่วง a011daf..03d6383 มี 16 commit งานจริง (9–15 มิ.ย.) ใหญ่เกินกว่าจะ fast-fix และมี "ฟีเจอร์ใหม่ระดับท็อป" ตัวที่สอง (Terms &amp; Conditions) ต่อจาก Finance ที่ค้างมาตั้งแต่ 28 พ.ค. รอบนี้จึงบันทึกทุกอย่างเป็น drift ที่ถูกเลื่อน (DRIFT-17..20), คง baseline ไว้ที่ a011daf แล้ว "ยกระดับ" ให้ทำ Workflow 1 re-baseline เป็นงานถัดไป

ของที่ค้าง: กระเป๋าค่าธรรมเนียมธนาคาร (#538, การเงิน), กันสลิปซ้ำ + เตือนสลิปปลายทางนอกระบบ + auto-confirm สลิปมาช้า (#528/#529/#530, กันโกง), หน้าต่างบล็อก settlement 22:30–02:00 (#535), จำกัด CSV export/การนับรายการ (#534/#536) และแก้รายงาน Telegram รายชั่วโมง (#526/#537)

<b>รายละเอียด</b>
• Commits: <code>a011daf..03d6383</code> (16 commits)
• PR: <a href="https://github.com/kokarat/mobiz-payment-gateway/pull/540">#540</a>
• Learnings: 1 refresh · 6 drift/decision · CC code_reviewer + security_auditor

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>
```
