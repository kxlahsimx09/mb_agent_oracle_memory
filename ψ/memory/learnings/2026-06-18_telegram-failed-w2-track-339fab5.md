---
title: telegram-failed — W2 amend a011daf..339fab5 (#544 backfill) Step 8b summary not sent (telegram_send MCP absent)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - repo:cross
  - current
  - telegram-failed
  - workflow-bug
  - w2
created: 2026-06-18
source: W2 workflow-2-track-commit.md Step 8b @ session 2026-06-18T04:36 GMT+7 ; PR https://github.com/kokarat/mobiz-payment-gateway/pull/540
related:
  - 2026-06-18_mdr-backfill-prismapays-cf-339fab5
  - 2026-06-18_telegram-failed-w2-track-4ba76bc
  - 2026-06-17_telegram-failed-w2-track-03d6383
project: github.com/kokarat/mobiz-payment-gateway
---

**Error:** `telegram_send` MCP tool unavailable in this session. The `telegram` (and `tester-telegram`) MCP server was listed as "still connecting" at session start but exposed **no callable tool** — two `ToolSearch` queries ("telegram send message chat", "+telegram send") returned zero telegram tools. Same condition as the 2026-06-01 → 2026-06-18 streak of `#telegram-failed` learnings; the tool has been unregistered for many consecutive W2 sessions. The W2 pass itself completed normally (PR #540 amended, learning filed, baseline last-verified bumped) — only the Telegram narrative could not be delivered.

The W2 pass is NOT blocked (PR + doc update are the load-bearing artefacts). Re-send the HTML below from a future session if/when `telegram_send` is registered again.

**Intended Telegram message (HTML, `parse_mode=HTML`, `disable_web_page_preview=true`):**

```html
<b>📝 W2 mobiz-payment-gateway — Backfill ค่า MDR ที่หายไปของ CF8/CF9/LO8 (Prismapays)</b>

ลูกค้า CF8/CF9/LO8 (merchant Prismapays) เคยชี้ไปที่ MDR profile ที่ถูกลบไปแล้ว ทำให้ตั้งแต่ 10/06 ทุก deposit ที่จ่ายแล้ว/payout ที่สำเร็จ <b>เก็บค่าธรรมเนียม 0</b> และไม่สร้าง mdr_shared — partner (Owner-MDR/YP/TTWD168/Bitly) ไม่ได้ส่วนแบ่งเลย. โค้ด guard <code>#542</code> (DRIFT-21) ปิดช่องนี้ไปแล้วสำหรับรายการใหม่; รอบนี้คือฝั่ง <i>ข้อมูล</i> — สคริปต์ one-off <code>#544</code> (<code>#541</code>) replay การกระจาย MDR ที่ขาดหายย้อนหลัง อ่าน % สดจาก profile ที่ถูกต้อง (TTWD 2.6/0.4), เครดิต partner + หักค่าธรรมเนียมจาก client, dry-run เป็น default, 1 Mongo txn ต่อรายการ, idempotent. สคริปต์อยู่นอก territory ของเอกสาร — ไม่มี doc fast-fix, baseline ยัง held ที่ <code>a011daf</code> (ยังค้าง W1 re-baseline ก้อนใหญ่: Finance + Terms + DRIFT-17..21).

<b>รายละเอียด</b>
• Commits: <code>4ba76bc..339fab5</code> (1 commit ใหม่; cumulative <code>a011daf..339fab5</code>)
• PR: <a href="https://github.com/kokarat/mobiz-payment-gateway/pull/540">#540</a> (amended)
• Learnings: 0 refresh · 0 drift · 1 ops (backfill, ผูกกับ DRIFT-21 guard)

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>
```

**Char count of the narrative body** (between the title line and the `<b>รายละเอียด</b>` block): ~640 chars, within the ~700 target / 800 hard cap.
