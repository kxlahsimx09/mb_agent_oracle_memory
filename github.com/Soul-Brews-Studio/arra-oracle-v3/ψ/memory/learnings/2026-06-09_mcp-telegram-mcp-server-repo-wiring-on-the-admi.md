---
title: mcp-telegram MCP server: repo + wiring on the admin fleet host (2026-06-09).
tags: [brew-ops, repo:cross, mcp-tools, fleet, telegram, gotcha]
created: 2026-06-09
source: brew-ops session 2026-06-09 — wiring mcp-telegram on admin host
project: github.com/soul-brews-studio/arra-oracle-v3
---

# mcp-telegram MCP server: repo + wiring on the admin fleet host (2026-06-09).

mcp-telegram MCP server: repo + wiring on the admin fleet host (2026-06-09).

**Repo:** `github.com/kxlahsimx09/mcp-telegram` (NOT Soul-Brews-Studio — that path never existed on GitHub; the dev01 machine's ~/.claude.json referenced a `/Users/dev01/.../Soul-Brews-Studio/mcp-telegram` path that was local-only and never pushed). Cloned via ghq to `/Users/admin/Code/github.com/kxlahsimx09/mcp-telegram`. Run with `bun src/index.ts`; deps `@modelcontextprotocol/sdk` (`bun install`). Minimal stdio MCP, single tool `telegram_send` (args: `text`, optional `chat_id` → falls back to `TELEGRAM_DEFAULT_CHAT_ID` env).

**Wiring:** configured per-project in `~/.claude.json` under `.projects["/Users/admin/Code/github.com/kokarat/mobiz-payment-gateway"].mcpServers` — two server entries pointing at the SAME binary, differing only by env:
- `telegram` → chat `-5134176392` ("code-alert") — used by W2 writer Step 8b/6b (`mcp__telegram__telegram_send`)
- `tester-telegram` → chat `-5219798624` ("test-alert") — used by pg-tester investigate step (`mcp__tester-telegram__telegram_send`)

**Two send paths — don't conflate:** `scripts/regression-then-investigate.sh send_tg()` reads the `tester-telegram` TOKEN+CHAT directly from `~/.claude.json` via jq and curls the Telegram API — it does NOT spawn the MCP, so it works even without the repo. The MCP server is only needed for agent-driven sends (the `mcp__*__telegram_send` tool calls inside W2 writer + tester investigate). That's why regression alerts can work while agent telegram is broken, or vice-versa.

**Onboarding a new fleet host = 3 steps:** (1) `ghq get https://github.com/kxlahsimx09/mcp-telegram` + `bun install`; (2) add both mcpServers blocks to the mobiz project in `~/.claude.json` with the correct per-host args path + the two token/chat env pairs; (3) verify by driving stdio: `initialize` → `tools/list` (expect `telegram_send`) → `tools/call`. Verified working 2026-06-09 (message_id 187 to test-alert).

Tags: #brew-ops #repo:cross #mcp-tools #fleet #telegram #gotcha

---
*Added via Oracle Learn*
