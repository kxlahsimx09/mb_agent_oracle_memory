---
title: telegram-failed — W2 bb02f02 narrative not sent (mcp-telegram not connected this session)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - repo:cross
  - current
  - telegram-failed
  - workflow-bug
  - payout
  - wallet-change-log
created: 2026-06-02
source: docs/current-system.md §3 @bb02f02 ; PR #507
project: github.com/kokarat/mobiz-payment-gateway
---

W2 Step 8b could not run: the `mcp-telegram` server (`telegram_send`) was **not connected** in this session (only `arra-oracle-v3` MCP was up; `telegram_send` did not resolve via ToolSearch). Error: tool unavailable / MCP not registered this session.

Per W2 Step 8b fallback, the PR (#507) + doc + learning are the load-bearing artifacts and already landed; this learning carries the intended Thai HTML body so the **next session can re-send** via `telegram_send(parse_mode="HTML", disable_web_page_preview=true)`.

## Intended message (HTML, ~700 chars)

```html
<b>📝 W2 mobiz-payment-gateway — payout override/refund กลับมาค้นเจอด้วย PAY id แล้ว</b>

เมื่อวาน #505 เพิ่งเปลี่ยนการค้นหา wallet-change-logs ด้วยเลข PAY ให้วิ่งผ่าน index <code>reference_id</code> (เร็วขึ้นมาก) แต่แถวที่เกิดจากการ <i>override</i> และ <i>confirm-completed</i> ของ payout ดันไม่เคยใส่ <code>reference_id</code> ไว้ — operator จึงค้นด้วยเลข PAY แล้วไม่เจอ ทั้งที่เงินถูกต้องครบ (เคส PAY1780341235HG6XK0 มีแถว refund +302.40 อยู่จริง). #510 เติม <code>reference_id</code>+<code>reference_type</code> ให้ครบทั้ง 4 จุด และเพิ่ม index 2 ตัวบน wallets_change_logs ทำให้หน้า list เร็วขึ้นจาก ~5.2 วินาที เหลือ ~1 มิลลิวินาที. แถวเก่ามี backfill script รันแยกนอกรอบ.

<b>รายละเอียด</b>
• Commits: <code>a9a3acb..bb02f02</code> (1 commit; cumulative a011daf..bb02f02)
• PR: <a href="https://github.com/kokarat/mobiz-payment-gateway/pull/507">#507</a> (amended)
• Learnings: 1 refresh · 0 drift · 0 new · 1 deferral (Finance #483 → W1)

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>
```

Tool call to repeat next session:
`telegram_send(text=<above>, parse_mode="HTML", disable_web_page_preview=true)` — chat_id defaults to `TELEGRAM_DEFAULT_CHAT_ID`.
