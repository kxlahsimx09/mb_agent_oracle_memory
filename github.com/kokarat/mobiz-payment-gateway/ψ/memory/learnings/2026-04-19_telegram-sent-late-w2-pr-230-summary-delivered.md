---
title: telegram-sent-late — W2 PR #230 summary delivered on re-send at 2026-04-19 15:35
tags: [telegram-sent-late, telegram-failed, workflow-bug, repo:cross, repo:mobiz-payment-gateway, w2, bot-delivery, recovered, brew-ops, 2026-04-19]
created: 2026-04-19
source: Telegram API sendMessage response message_id=8 at 2026-04-19T15:35+07:00, recovering the 15:05 failure
project: github.com/kokarat/mobiz-payment-gateway
---

# telegram-sent-late — W2 PR #230 summary delivered on re-send at 2026-04-19 15:35

telegram-sent-late — W2 PR #230 summary delivered on re-send at 2026-04-19 15:35+07:00, message_id 8 in chat -5134176392 (`code-alert`).

Supersedes `learning_2026-04-19_title-telegram-failed-w2-step-8b-delivery-4` per its own guidance ("On re-send success, supersede this learning with a `#telegram-sent-late` note carrying `message_id`").

## Root cause of the original 404

Two latent config bugs in `~/.claude.json` discovered during the re-send:

1. **User-scope telegram MCP had a truncated token** — value was literal `"8308647893:..."` (14 chars including the `...` placeholder), producing URLs like `https://api.telegram.org/bot8308647893:.../sendMessage` → Telegram returned 404 because the token-in-path was not a real bot. Origin unclear; may have leaked from a copy-paste of an example string or an earlier `claude mcp add` call that shell-escaped the `...` wrong.
2. **maw-js project scope had the wrong `TELEGRAM_DEFAULT_CHAT_ID`** — value was `2002026175` (positive, non-group-shape) instead of `-5134176392`. Not the cause of the 404 (pg-writer was in mobiz, not maw-js) but a parallel config-rot bug that would have bitten the next maw-js-scoped caller.

## Fix applied

Per user's "Option B (strict)" preference (telegram MCP scoped to the repos that actually need it, no user-level Oracle-adjacent entries):

- Removed telegram MCP from user scope, arra-oracle-v3 project scope, maw-js project scope.
- Registered telegram MCP at **mobiz-payment-gateway** project scope and **bank-bot** project scope only — the two repos where W2 Step 8b / W2 Step 6b actually fire.
- Verified both entries: TOKEN length 46 (full), CHAT_ID `-5134176392`.
- Re-sent the verbatim HTML via curl (MCP server was unavailable in this brew-ops session context) — delivered successfully.

## Delivery confirmation

- message_id: 8
- chat_id: -5134176392 (`code-alert` group)
- timestamp: 2026-04-19 15:35+07:00 (late by ~30 minutes vs the original 15:05 attempt)
- content: unchanged from the verbatim HTML in the superseded learning, plus a trailing `<i>⚠️ late delivery — re-send หลังแก้ MCP scope bug</i>` note so readers of the Telegram channel can distinguish this as the recovered delivery.

## Follow-up for W2 spec (optional, not in this pass)

The W2 Step 8b Fallback section currently says "Do not block the W2 pass; the commit + PR are already real and useful" — which is what the pg-writer agent correctly did. Working as designed. No spec change needed.

The pg-writer agent also correctly filed the #telegram-failed learning with the verbatim HTML body, which is what made this late re-send a 1-minute cut-and-paste job instead of a rewrite. The spec's "file the intended HTML body (full, unescaped)" rule earned its keep here — worth noting as a pattern success.

Tags: telegram-sent-late, telegram-failed, workflow-bug, repo:cross, repo:mobiz-payment-gateway, w2, bot-delivery, recovered, brew-ops

---
*Added via Oracle Learn*
