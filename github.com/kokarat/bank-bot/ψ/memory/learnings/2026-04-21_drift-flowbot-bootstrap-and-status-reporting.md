---
title: drift — flow:bot-bootstrap-and-status-reporting — SSE vestigial code + CLAUDE.md
tags: [technical-writer, repo:bank-bot, current, drift, flow:bot-bootstrap-and-status-reporting, sse-disabled-vestigial, doc-code-drift, w4-candidate]
created: 2026-04-21
source: core/sse.js@9dc902f + app.js:5,37-38,179-181,1961,1990,2177,2191@9dc902f + CLAUDE.md §"SSE + Polling Hybrid"@9dc902f
project: github.com/kokarat/bank-bot
---

# drift — flow:bot-bootstrap-and-status-reporting — SSE vestigial code + CLAUDE.md

drift — flow:bot-bootstrap-and-status-reporting — SSE vestigial code + CLAUDE.md describes hybrid runtime that is disabled at HEAD. `core/sse.js` implements a full 142-line SSE client with 5-attempt exponential-backoff reconnect ladder. `app.js:5,37-38` imports and constructs the SSEClient. `app.js:179-181` explicitly disables the connect() call with a TODO comment: "SSE disabled for bot — SSE endpoint requires JWT, bot uses Bot Secret / Polling every POLL_INTERVAL is sufficient for bot use case / TODO: Add bot-compatible SSE endpoint or use Bot Secret auth for SSE". The `sseClient` variable stays null for the bot's entire lifetime (`app.js:37 let sseClient = null` — never assigned). `sseTriggered` flag likewise never sets. However CLAUDE.md §"SSE + Polling Hybrid" (current project charter) still describes the hybrid runtime with ASCII-art diagram showing SSE stream + polling fallback as the current behaviour. docs/current-system.md §1 already carries DRIFT-1 naming this (app.js:179-181 + core/sse.js) but CLAUDE.md has not been updated to match. Runtime at HEAD is polling-only for the bot (gateway still serves the SSE endpoint for its own admin-UI consumers; bot just doesn't connect). Two resolution options for W4 (bot-writer does not pick): (A) re-enable SSE with a Bot-Secret-compatible gateway endpoint that accepts X-Bot-Secret instead of JWT; (B) delete the SSE plumbing from bank-bot entirely and update CLAUDE.md to say polling-only. Option A preserves the original architectural intent (near-instant dispatch); Option B reduces maintenance surface. Filed as flow-specific drift anchor, not a general bank-bot drift, because Step 8b of `docs/flows/bot-bootstrap-and-status-reporting.md` references this directly in the linear sequence diagram's loop wrapper (no SSE crossing shown because there is none at HEAD).

---
*Added via Oracle Learn*
