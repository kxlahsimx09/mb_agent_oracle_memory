---
title: telegram-failed — W2 amend a011daf..0897541 Step 8b (telegram_send MCP unregistered)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - repo:cross
  - current
  - telegram-failed
  - workflow-bug
created: 2026-06-17
source: W2 workflow-2-track-commit.md Step 8b @ session 2026-06-17T23:48 GMT+7
related:
  - 2026-06-17_drift-21-dangling-mdr-profile-guard
  - 2026-06-17_hotfix-543-bank-fee-wallet-super-admin-only
project: github.com/kokarat/mobiz-payment-gateway
---

# W2 Step 8b Telegram fallback — telegram_send MCP not registered

The `telegram_send` MCP tool (`github.com/Soul-Brews-Studio/mcp-telegram`) is **not registered in this session** — ToolSearch for "telegram" / "+telegram" returned no `telegram_send` tool. Per W2 Step 8b fallback, the intended Thai-language narrative is preserved here (full, unescaped) for a future session to re-send. This is the second consecutive `#telegram-failed` on a mobiz W2 pass today (the original 8.B pass for `a011daf..03d6383` also filed one).

**error string:** `telegram_send tool not available in session (mcp-telegram server not connected)`

**Intended message (Telegram HTML, parse_mode=HTML, disable_web_page_preview=true):**

```html
<b>📝 W2 mobiz-payment-gateway — PR #540 ต่อยอด: ปิดช่องโหว่ wallet + MDR (a011daf..0897541)</b>

PR #540 ติดตาม backlog ตั้งแต่ <code>a011daf</code> ซึ่งใหญ่ระดับ W1 (Finance API + Terms &amp; Conditions + งานพฤติกรรมหลายโดเมน) จึงยัง "ดองไว้รอ re-baseline" ทั้งก้อน วันนี้มี 2 hotfix ตามเข้ามา ต่อยอดเข้า PR เดิม: <b>#543</b> จำกัดกระเป๋า bank-fee ledger ให้เฉพาะ super_admin (เดิม admin ทั่วไปเห็นกำไร/ค่าใช้จ่าย MDR ของเจ้าของระบบได้ — ถือเป็นข้อมูลรั่ว) และ <b>#542</b> กัน mdr_profile ที่ถูกลบแต่ยังมีคนอ้างถึง: ลบไม่ได้ถ้ายังมี client/merchant ผูกอยู่ (<code>409</code>) และ deposit/payout จะถูกปฏิเสธ (<code>422</code>) แทนที่จะคิดค่าธรรมเนียม 0 เงียบ ๆ — กันเงินค่าธรรมเนียมหายและส่วนแบ่ง partner หาย

<b>รายละเอียด</b>
• Commits: <code>03d6383..0897541</code> (2 commits; cumulative <code>a011daf..0897541</code>)
• PR: <a href="https://github.com/kokarat/mobiz-payment-gateway/pull/540">#540</a> (amended)
• Learnings: 1 refresh (DRIFT-18 update) · 1 new (DRIFT-21) · ทั้ง PR สะสม 9
• ยังถือ baseline ที่ a011daf — Workflow 1 re-baseline คือ action ถัดไปที่ค้างอยู่

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>
```
