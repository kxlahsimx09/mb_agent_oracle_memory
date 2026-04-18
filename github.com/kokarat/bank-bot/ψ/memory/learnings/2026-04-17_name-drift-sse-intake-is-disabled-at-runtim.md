---
title: drift — SSE intake is disabled at runtime despite heavy marketing in CLAUDE.md / README
tags: [technical-writer, repo:bank-bot, current, sse, drift]
created: 2026-04-17
source: docs/current-system.md §8 DRIFT-1 @ 95dbb70
project: github.com/kokarat/bank-bot
---

# drift — SSE intake is disabled at runtime despite heavy marketing in CLAUDE.md / README

As of 95dbb70 (2026-04-17 baseline), `core/sse.js` is imported (app.js:5) but `sseClient` is never constructed — `app.js:179-181` explicitly disables SSE with a TODO ("SSE endpoint requires JWT, bot uses Bot Secret"). The `sseTriggered` flag inside pollLoop is therefore dead code. CLAUDE.md "SSE + Polling Hybrid" section and README's full SSE diagram both present SSE as the primary event path.

## What code shows (95dbb70)

- `app.js:5` — `const { SSEClient } = require('./core/sse')` (imported).
- `app.js:37` — `let sseClient = null;` (never reassigned anywhere in the file).
- `app.js:179-181` — comment: "SSE disabled for bot — SSE endpoint requires JWT, bot uses Bot Secret / Polling every POLL_INTERVAL is sufficient for bot use case / TODO: Add bot-compatible SSE endpoint or use Bot Secret auth for SSE".
- `core/sse.js` — 142 lines of a complete reconnecting SSE client that is never instantiated at runtime.

## What CLAUDE.md says

- "SSE + Polling Hybrid" section, with an ASCII diagram showing the droplet connecting to backend SSE for instant notification, polling only as fallback.
- README.md:20-37 shows the same "SSE stream" → "fallback poll 30s" diagram.

## Resolution path (Workflow 4)

- Option A (doc fix, likely correct): CLAUDE.md and README are updated to match code — the bot polls every 30 s; SSE is planned but not wired.
- Option B (code fix): Implement the "Bot Secret auth for SSE" TODO so the hybrid diagram becomes reality. Not a technical_writer task; needs human / code_reviewer.

## How to apply

- When quoting bot event intake latency, cite the `POLL_INTERVAL` default (30 s) not "instant SSE".
- Any future bot doc mentioning SSE should add a `*(planned; TODO: app.js:181)*` note until the endpoint exists.
- On Workflow 2 (change tracking), a new commit that instantiates `SSEClient` closes this drift — update the baseline and remove the `[DRIFT]` marker in §8.

---
*Added via Oracle Learn*
