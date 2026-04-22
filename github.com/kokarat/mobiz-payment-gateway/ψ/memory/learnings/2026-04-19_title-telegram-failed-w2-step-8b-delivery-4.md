---
title: telegram-failed — W2 Step 8b delivery 404 on mobiz PR #230 summary
tags: [telegram-failed, workflow-bug, repo:cross, repo:mobiz-payment-gateway, w2, bot-delivery]
created: 2026-04-19
source: telegram_send() returned {"ok": false, "error": "Not Found", "error_code": 404} at 2026-04-19T15:05+07:00
related:
  - 2026-04-19_title-payout-admin-cancel-endpoint-put-pay
project: github.com/kokarat/mobiz-payment-gateway
---

# telegram-failed — W2 Step 8b delivery 404

## What happened

`telegram_send` (MCP `@mcp-telegram`) returned `{"ok": false, "error": "Not Found", "error_code": 404}` on the W2 Step 8b narrative summary for PR #230 (mobiz-payment-gateway). No `chat_id` was passed — MCP server relies on `TELEGRAM_DEFAULT_CHAT_ID` env. The 404 implies either the env isn't set, the bot is not a member of the target chat, or the chat id is stale. Not this workflow's mandate to diagnose; next session re-sends from this learning.

## Error classification

- Not a W2 content problem — the PR is real, the doc is committed, the `arra_learn` for the actual durable fact landed. Telegram is delivery-only.
- Per `references/workflow-2-track-commit.md` §Step 8b Fallback, the correct action is file this learning + continue. Done.

## Intended HTML body (verbatim, unescaped — for re-send)

```html
<b>📝 W2 mobiz-payment-gateway — admin cancel payout ได้แบบไม่ต้องผ่าน /status</b>

PR #228 (<code>153a4f6</code>) เพิ่ม endpoint ใหม่ <code>PUT /payouts/:id/cancel</code> สำหรับ admin ยกเลิก payout ที่ยัง <code>pending</code> แล้วคืนยอดเข้ากระเป๋า client อัตโนมัติ — เดิมทำผ่าน <code>/status</code> แต่มีความเสี่ยง double-refund เพราะ queue กับ wallet ไม่ sync กัน. ของใหม่เช็ค withdrawal_queue ก่อน: ถ้า bot กำลังโอน (<code>processing</code>) จะ refuse ทันที, ถ้า <code>pending</code> ก็ cancel queue + payout + คืนยอด (amount + fee) + ส่ง callback <code>EventPayoutCancelled</code> ให้ client. Validator ของ <code>/status</code> ถูกตัด <code>cancelled</code> ออกเพื่อปิดช่อง double-refund อย่างเด็ดขาด.

<b>รายละเอียด</b>
• Commits: <code>37dfb26..1ffafc1</code> (7 commits, 1 in-territory code)
• PR: <a href="https://github.com/kokarat/mobiz-payment-gateway/pull/230">#230</a>
• Learnings: 1 new (payout admin-cancel endpoint) · 0 drift · 0 refresh-only
• Flow affected: `payout-request` (มี terminal ใหม่ = admin-cancel)

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>
```

## Next action for whoever finds this

1. Check `TELEGRAM_DEFAULT_CHAT_ID` env on the MCP server (`claude mcp list | rg telegram`).
2. Verify the bot is a member of the intended chat.
3. If re-sending by hand, the HTML above is ready to paste into `telegram_send(text=..., parse_mode="HTML", disable_web_page_preview=true)`.
4. On re-send success, supersede this learning with a `#telegram-sent-late` note carrying `message_id` so the retro trail closes.

## Why filed here and not as #drift

Delivery failure isn't documentation drift; the PR is the load-bearing artefact and is already open. This is a workflow-operations bug (MCP/env/chat-membership), tagged `#workflow-bug` + `#telegram-failed` for Step 8b sweep.

---
*Added via Oracle Learn*
