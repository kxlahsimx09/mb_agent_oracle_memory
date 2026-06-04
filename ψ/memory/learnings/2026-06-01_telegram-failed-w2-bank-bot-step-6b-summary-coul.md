---
title: telegram-failed — W2 bank-bot Step 6b summary could not be sent (mcp-telegram MC
tags: [technical-writer, repo:bank-bot, repo:cross, current, telegram-failed, workflow-bug, deployment, do, brand]
created: 2026-06-01
source: W2 Step 6b fallback — PR #130; docs/current-system.md §5.3
project: github.com/kokarat/bank-bot
---

# telegram-failed — W2 bank-bot Step 6b summary could not be sent (mcp-telegram MC

telegram-failed — W2 bank-bot Step 6b summary could not be sent (mcp-telegram MCP not connected in this session, 2026-06-01 GMT+7). telegram_send tool absent from the deferred-tool registry; error: "no telegram MCP tool available in session". PR #130 + 2 arra_learn entries already landed — only the Telegram delivery vehicle failed. A later session with mcp-telegram connected should re-send the HTML below verbatim (parse_mode=HTML, disable_web_page_preview=true).

INTENDED MESSAGE (HTML, ~690 chars):

<b>🤖 W2 bank-bot — DO deployment ตามทัน multi-brand แล้ว</b>

ตั้งแต่ทีม rebrand youpay→maxpayplus + ทำ AWS family ให้รองรับหลายแบรนด์ ฝั่ง DigitalOcean ยังตั้งชื่อ droplet แบบเก่า (bank-bot-&lt;account&gt;) อยู่ รอบนี้ commit 3 ตัวจับ DO ให้ใช้คอนเวนชันเดียวกับ AWS: create-bot.sh บังคับ --brand, droplet ชื่อ &lt;brand&gt;-&lt;bank_type&gt;-&lt;account&gt;, สคริปต์ ops ทั้งหมดเลิก grep ชื่อ หันไป lookup ด้วย tag (account-N) แทน — ยังทำงานกับ droplet เก่าได้เพราะทุกตัวมี tag นี้. เพิ่ม create-fleet.sh (สร้างทั้งกองจาก system_banks) + migrate-rename-legacy.sh (rename ของเดิม, zero-downtime). ตามด้วย fix: --brand รั่วเข้า positional args และ map กรอง status:1 ทำ KTB ใหม่หาย.

<b>รายละเอียด</b>
• Commits: <code>baee633..3ff2751</code> (3 commits)
• PR: <a href="https://github.com/kokarat/bank-bot/pull/130">#130</a>
• Learnings: 6 refresh · 1 drift · 2 new
• Cross-repo: bot-internal only (ops scripts; ไม่แตะ /bot/* contract)

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>

Tags: technical-writer, repo:bank-bot, repo:cross, current, telegram-failed, workflow-bug, deployment, do, brand.

---
*Added via Oracle Learn*
