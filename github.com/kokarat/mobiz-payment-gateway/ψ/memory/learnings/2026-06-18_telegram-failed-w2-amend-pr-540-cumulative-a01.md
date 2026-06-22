---
title: telegram-failed — W2 amend PR #540 (cumulative a011daf..d53c129), 2026-06-19. Th
tags: [technical-writer, repo:mobiz-payment-gateway, repo:cross, current, telegram-failed, workflow-bug, workflow-2]
created: 2026-06-18
source: claude mcp list (telegram + tester-telegram ✘ Failed to connect) @ 2026-06-19; PR #540
project: github.com/kokarat/mobiz-payment-gateway
---

# telegram-failed — W2 amend PR #540 (cumulative a011daf..d53c129), 2026-06-19. Th

telegram-failed — W2 amend PR #540 (cumulative a011daf..d53c129), 2026-06-19. The Step 8b Telegram narrative could not be sent: both `telegram` and `tester-telegram` MCP servers show "✘ Failed to connect" in `claude mcp list` (command: `bun /home/ubuntu/Code/github.com/kxlahsimx09/mcp-telegram/src/index.ts`); no `telegram_send` tool is present in the tool registry. This is the ~12th consecutive Telegram fail per the W1/W2/W9 trace chain (prior traces note "tester-telegram MCP unregistered"). The W2 PR + commit + 3 learnings are already landed (load-bearing artifacts), so the pass is NOT blocked. Next session with a working Telegram MCP can re-send the intended message below.

INTENDED HTML BODY (parse_mode=HTML, disable_web_page_preview=true) — re-send verbatim:

&lt;b&gt;📝 W2 mobiz-payment-gateway — schedulers แยก pod กัน OOM + เครดิตฝาก atomic + เช็คคีย์ Spaces&lt;/b&gt;

รอบนี้ตามเก็บ 3 การเปลี่ยนใน territory ที่เพิ่งขึ้น main: (1) schedulers แบบรันเป็นงวด ถูกย้ายไปรันบน pod เดียว (backend-scheduler) คุมด้วย env RUN_SCHEDULERS — แก้ backend-api OOM ที่ทุก replica แย่งกันโหลด bank_statements ทุก 30 วิ (WithdrawalDispatcher ยังรันทุก pod เหมือนเดิม). (2) ตอน matcher จับคู่ statement แล้ว flip ฝากเป็น paid + เครดิต wallet ลูกค้า ตอนนี้อยู่ใน transaction เดียว — กันเคส "จ่ายแล้วไม่ได้เครดิต" (~13 รายการจริงในโปรดักชัน). (3) ตอนบูตจะเช็คว่าคีย์ DigitalOcean Spaces ยังใช้ได้ไหม + เช็คซ้ำทุก 10 นาที (จากเคสคีย์ maxpayplus ถูกเพิกถอนแล้วเงียบไปหลายวัน). เป็น doc-only ไม่แตะโค้ด; baseline ยังค้างที่ a011daf รอ W1 re-baseline (Finance + DRIFT-16..21).

&lt;b&gt;รายละเอียด&lt;/b&gt;
• Commits: &lt;code&gt;339fab5..d53c129&lt;/code&gt; (8 commits, 3 in-territory)
• PR: &lt;a href="https://github.com/kokarat/mobiz-payment-gateway/pull/540"&gt;#540&lt;/a&gt; (W2 amend)
• Learnings: 3 ใหม่ · baseline held · last-verified → 2026-06-19

&lt;i&gt;กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ&lt;/i&gt;

---
*Added via Oracle Learn*
