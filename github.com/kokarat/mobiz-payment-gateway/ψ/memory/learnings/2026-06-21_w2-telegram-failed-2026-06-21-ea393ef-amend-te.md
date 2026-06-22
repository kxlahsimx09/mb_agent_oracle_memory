---
title: W2 telegram-failed (2026-06-21, ea393ef amend): Telegram MCP unregistered — fall
tags: [technical-writer, repo:mobiz-payment-gateway, current, telegram-failed, workflow-bug, repo:cross, w2, track-commit]
created: 2026-06-21
source: W2 Step 8b fallback @ea393ef; PR #540; trace 00916284
project: github.com/kokarat/mobiz-payment-gateway
---

# W2 telegram-failed (2026-06-21, ea393ef amend): Telegram MCP unregistered — fall

W2 telegram-failed (2026-06-21, ea393ef amend): Telegram MCP unregistered — fallback to learning per W2 Step 8b. Sixteenth+ consecutive Telegram failure for pg-writer/tester passes (telegram MCP server never registered in this session: ToolSearch "telegram send" returned no matching deferred tools; only arra-oracle-v3 + dpay MCP servers connected). The W2 PR #540 amend + arra_trace are the load-bearing artefacts and are real; only the Telegram delivery channel is unreachable. Next session can re-send from this learning when the MCP lands.

Intended Telegram HTML (parse_mode=HTML, disable_web_page_preview=true), unsent:

&lt;b&gt;📝 W2 mobiz-payment-gateway — slip-fraud test #558 ไม่กระทบ doc (baseline ยัง held&lt;/b&gt;

วันนี้ commit ใหม่ที่เข้า main มีแค่ #558 (4bd826a) ที่ปรับ assertion ของ regression test slip-fraud ให้ตรงกับ payload/log V2 — แต่ไฟล์ที่แตะคือ integration-tests/test-deposit-slip-fraud.sh ซึ่งเป็นของทีม tester ไม่ใช่ territory ของ pg-writer และ tree หลัง merge เท่ากับ 68f30db เป๊ะ (byte-identical) เพราะ #558 ถูก #559 กลืนไปก่อนแล้ว ดังนั้นไม่มี doc เปลี่ยน — แค่ขยาย PR #540 ให้ครอบคลุมถึง ea393ef แล้วเลื่อน last-verified baseline ยัง held @a011daf รอ W1 re-baseline (Finance API + Terms&amp;Conditions + DRIFT-16..21)

&lt;b&gt;รายละเอียด&lt;/b&gt;
• Commits: &lt;code&gt;68f30db..ea393ef&lt;/code&gt; (2 commits, net-zero, out-of-territory)
• PR: &lt;a href="https://github.com/kokarat/mobiz-payment-gateway/pull/540"&gt;#540&lt;/a&gt; (amended, cumulative a011daf..ea393ef)
• Learnings: 0 refresh · 0 drift · 0 new (in-territory)

&lt;i&gt;กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ&lt;/i&gt;

Error string: ToolSearch query "telegram send" / "+telegram send" → "No matching deferred tools found" (telegram MCP not in connected-server set). Tags: technical-writer, repo:mobiz-payment-gateway, current, telegram-failed, workflow-bug, repo:cross, w2, track-commit.

---
*Added via Oracle Learn*
