---
title: telegram-failed — W2 2026-06-01 mobiz track a011daf..bf57c0e summary not sent (MCP unreachable)
tags: [technical-writer, repo:cross, current, telegram-failed, workflow-bug]
created: 2026-06-01
source: PR #507 @bf57c0e
project: github.com/kokarat/mobiz-payment-gateway
---

Step 8b Telegram narrative summary for the 2026-06-01 W2 pass (PR #507) could NOT be sent: the `telegram_send` MCP tool (`Soul-Brews-Studio/mcp-telegram`) is **not connected in this session** — `ToolSearch` for "telegram_send" returned no such tool. No error string from the tool itself; the cause is MCP-not-registered in this headless/cron-style wake context. The PR + doc update + 5 learnings are already real and useful; only the Telegram delivery is missing. Next session should re-send the HTML below.

Intended `telegram_send(parse_mode="HTML", disable_web_page_preview=true)` body:

```html
<b>📝 W2 mobiz-payment-gateway — perf รอบใหญ่ + กัน race เงินคืน Payout</b>

หลังเหตุการณ์ pod OOM 29 พ.ค. ทีมไล่อุดคิวรีช้าหลายจุด: ใส่ Redis cache (30 วิ) ให้ตัวนับ pagination ของ list deposit/payout/settlement/topup (CachedCount), แก้ sort ให้ใช้ index ในหน้า withdrawal-queue + ค้นหา bank-statement ด้วย request-id ตรง ๆ. นอกจากนี้แก้ race ตอน payout ล้มแล้ว auto-reconcile กับการคืนเงินชนกัน (เคส PAY1780057287) — เงินไม่หาย แต่ log เคยสลับลำดับ ตอนนี้กันด้วย CAS guard + sort เสถียร. และแก้ปุ่ม Restart Bot ฝั่ง DigitalOcean ให้หา droplet ด้วย tag account-&lt;เลขบัญชี&gt; แทนชื่อ (ชื่อ droplet เปลี่ยนเป็น brand-bank-account แล้ว).

<b>รายละเอียด</b>
• Commits: <code>a011daf..bf57c0e</code> (8 in-territory)
• PR: <a href="https://github.com/kokarat/mobiz-payment-gateway/pull/507">#507</a>
• Learnings: 4 refresh · 1 drift · 0 new
• ⚠️ Finance API (#483) เป็นฟีเจอร์ใหม่ใหญ่ — เลื่อนไปทำ baseline เต็ม (W1)

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>
```
