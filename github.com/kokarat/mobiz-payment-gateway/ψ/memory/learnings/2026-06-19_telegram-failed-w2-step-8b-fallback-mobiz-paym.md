---
title: telegram-failed (W2 Step 8b fallback) — mobiz-payment-gateway W2 amend 2026-06-1
tags: [telegram-failed, workflow-bug, repo:cross, technical-writer, current, repo:mobiz-payment-gateway, w2-track-commit, spaces-credential-rotation]
created: 2026-06-19
source: W2 Step 8b fallback; PR #540 @ba2e315; commit 40a282e #557
project: github.com/kokarat/mobiz-payment-gateway
---

# telegram-failed (W2 Step 8b fallback) — mobiz-payment-gateway W2 amend 2026-06-1

telegram-failed (W2 Step 8b fallback) — mobiz-payment-gateway W2 amend 2026-06-19 ~12:03 GMT+7, cumulative a011daf..40a282e (PR #540).

Error: Telegram MCP unavailable — `telegram_send` tool not present this session. Only `arra-oracle-v3` + `dpay` MCP servers are connected; no `Soul-Brews-Studio/mcp-telegram` server registered (same unregistered-MCP condition the tester W1 passes have hit repeatedly). Not a transient send failure — the tool simply isn't wired in this environment. PR + commit + trace are already real; per W2 Step 8b fallback the narrative is preserved here for a future session with Telegram access to re-send.

Intended Thai-HTML narrative (parse_mode HTML, disable_web_page_preview true), ~780 chars:

```html
<b>📝 W2 mobiz-payment-gateway — maxpayplus กู้คืน slip upload (หมุนคีย์ DO Spaces)</b>

ต่อจากตัวตรวจ credential ที่เพิ่งใส่ไป (#553/#554) ที่คอยเช็ก DO Spaces ทุก 10 นาที — มันจับได้ว่า access key ของ maxpayplus ถูกลบทิ้ง ทำให้อัปสลิป/QR ขึ้น 403 ทุกครั้ง วันนี้ #557 หมุนไปใช้คีย์ ampay (account-wide) ที่ยังใช้ได้กับ bucket youpay สลิปอัปได้ตามปกติแล้ว เป็นการ "แก้ของจริง" หลังจากตัวตรวจส่งสัญญาณเตือนมาตลอด.

<b>รายละเอียด</b>
• Commits: <code>84b515f..40a282e</code> (1 commit, นอก territory — k8s secret, devops ดูแล)
• PR: <a href="https://github.com/kokarat/mobiz-payment-gateway/pull/540">#540</a> (amended, cumulative a011daf..40a282e)
• Learnings: 0 refresh · 0 drift · 0 new (ไม่แตะ Go code)
• Baseline ยังค้างที่ a011daf (W1 re-baseline ค้าง: Finance + T&C + DRIFT-16..21)

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>
```

Recurring infra gap: register the mcp-telegram server for the pg-writer/pg-tester fleet panes (TELEGRAM_DEFAULT_CHAT_ID) so Step 8b/7b stop falling back. Tracked here as #telegram-failed + #workflow-bug + repo:cross.

---
*Added via Oracle Learn*
