---
title: telegram-failed — W1 thirty-second pass Step 7b could not send: mcp__tester-tele
tags: [tester, repo:cross, current, telegram-failed, workflow-bug, w1, w1-twenty-ninth-baseline]
created: 2026-06-07
source: workflow-1-validate-integration-tests.md Step 7b fallback + session 2026-06-08 (tester-telegram MCP not registered, thirty-second pass — seventh consecutive failure); PR #517
project: github.com/kokarat/mobiz-payment-gateway
---

# telegram-failed — W1 thirty-second pass Step 7b could not send: mcp__tester-tele

telegram-failed — W1 thirty-second pass Step 7b could not send: mcp__tester-telegram__telegram_send not registered (seventh consecutive)

The dedicated tester-telegram MCP (bot @ampay_test_alert_bot) is still not registered on this machine — ToolSearch for "tester-telegram telegram_send" returned no matching deferred tool. This is the SEVENTH consecutive Step 7b failure (passes 26th, 27th, 28th, 29th, 30th, 31st all hit the same gap). Per workflow-1 Step 7b fallback the W1 pass was NOT blocked: PR #517 + docs/test-index.md are already real and merged-pending. The generic writer-fleet `telegram` MCP was deliberately NOT used as a substitute (the task + workflow restrict Step 7b to the tester channel).

Intended Telegram message (HTML, parse_mode=HTML, disable_web_page_preview=true), for a future session to re-send once the MCP is registered:

<b>🧪 W1 tester — finance book_value_thb เพิ่ม field, ชุดเทสยังตรงกับ code</b>

รอบนี้ validate ทั้ง 49 เทสบนช่วง bb02f02..8315189 (มี production-surface commit ใหม่ 1 ตัวตั้งแต่ baseline เดิม). #515 เพิ่ม field book_value_thb แบบ additive ลงใน /api/v1/finance balance — โค้ด finance ทั้งก้อนยังไม่มีเทสแตะเลย (grep finance ใน integration-tests = 0 hits) เลยเป็น NEUTRAL ล้วน, 0 regression. อีกสองคอมมิต (#516/#511) เป็น k8s ล้วน. baseline ขยับ bb02f02->8315189; ไม่ต้องแก้อะไรในชุดเทส.

<b>รายละเอียด</b>
• Baseline: <code>bb02f02..8315189</code> (1 production-surface commit)
• Tests validated: 49 — V=44 · S=1 · W=0 · F=0 · SUP=2 · UNK=0 (+2 ON_HOLD)
• Learnings: 1 (0 STALE · 0 WRONG-SETUP · 0 FLAKY · 0 regression-candidates) + 1 coverage-gap (finance book_value_thb)
• PR: <a href="https://github.com/kokarat/mobiz-payment-gateway/pull/517">#517</a>

<i>กดลิงก์ PR เพื่อรีวิว — ยังไม่ merge จนกว่าจะได้รับอนุมัติ</i>

Error string: ToolSearch "tester-telegram telegram_send" -> "No matching deferred tools found"; MCP server tester-telegram absent from this session's registered servers.

Recurring fix: register the tester-telegram MCP (TELEGRAM_DEFAULT_CHAT_ID + @ampay_test_alert_bot token) in ~/.claude.json on the machine that runs pg-tester wake-prompts, so Step 7b stops degrading to this fallback every pass.

---
*Added via Oracle Learn*
