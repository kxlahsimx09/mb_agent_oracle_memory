---
title: MCP operational gotchas for Claude Code — three traps observed during the 2026-0
tags: [brew-ops, mcp-tools, operational, gotcha, config-inheritance, claude-code, telegram, recovery-pattern, repo:cross, 2026-04-19]
created: 2026-04-19
source: 2026-04-19 telegram MCP setup + 404 debug + scope cleanup arc
project: github.com/soul-brews-studio/arra-oracle-v3
---

# MCP operational gotchas for Claude Code — three traps observed during the 2026-0

MCP operational gotchas for Claude Code — three traps observed during the 2026-04-19 telegram MCP setup for Soul-Brews-Studio Telegram integration. All non-obvious, all cost real debugging time.

## Gotcha 1: `claude mcp add` does not validate env values

Registering an MCP server with `--env TELEGRAM_BOT_TOKEN=...` accepts any string, including:
- Literal placeholder text like `"8308647893:..."` (copy-paste from docs where `...` was a literal character, not an ellipsis)
- Empty strings
- Wrong-format values

Observed live on 2026-04-19: global-scope telegram MCP had `TELEGRAM_BOT_TOKEN="8308647893:..."` (14 chars including the literal `...`). Caused every `sendMessage` call to hit `https://api.telegram.org/bot8308647893:.../sendMessage` → Telegram returned 404 (token-in-URL-path is invalid → endpoint doesn't exist). The MCP server itself worked fine — the upstream was being handed garbage.

Origin hypothesis: an earlier `claude mcp add` command used shell that ate the real token. Or the user pasted a placeholder from docs. Either way, `claude mcp add` silently accepted it.

Mitigation pattern (fielded in `mcp-telegram/src/index.ts` as part of the fix): **startup validation** — check token shape at MCP server boot and log a loud warning if it looks suspicious. The caller still gets a better error message than "404 Not Found" with no context.

## Gotcha 2: MCP config scope inheritance with silent override

`~/.claude.json` has three-layer scope: top-level `mcpServers` (user scope), `projects/<path>/mcpServers` (project scope), `.mcp.json` in the repo (repo scope).

A project-scope entry can **override** the user-scope entry for the same MCP name, including env vars. Claude Code resolves by matching the active project path to one of the `projects/<path>` keys.

Observed: I had `telegram` registered in three places:
- Global: correct TOKEN + correct CHAT_ID
- `projects/arra-oracle-v3`: correct TOKEN + correct CHAT_ID
- `projects/maw-js`: correct TOKEN but **WRONG CHAT_ID** (`2002026175`, looked like a timestamp fragment)

An agent running in arra-oracle-v3 picked up the arra-oracle-v3 entry (correct). An agent running in maw-js would have picked up the wrong CHAT_ID silently. Nothing warned about the divergence.

Observation during diagnosis: `claude mcp list` showed "telegram: Connected" from every repo path, which is misleading — "connected" means the MCP process starts, not that it's configured correctly for the current context.

Mitigation pattern: **strict single-scope registration**. User's preference landed as "Option B": remove telegram from user + arra + maw; register ONLY in mobiz-payment-gateway + bank-bot project scopes, which are the two repos that actually need it. Single source of truth per project. No inheritance surprises.

## Gotcha 3: MCP env is captured at `claude mcp add` time, not read dynamically

`claude mcp add --env KEY=VALUE` writes `VALUE` into `~/.claude.json` and starts the MCP process with that env. If `VALUE` changes later, the MCP process keeps the OLD value until next restart. The config JSON also keeps the old value.

To update: `claude mcp remove <name>` then `claude mcp add <name> --env KEY=NEW_VALUE ...`. No `--update` flag exists. Repeat `claude mcp add` with different env fails with `MCP server ... already exists in local config`.

Worse: the "remove" only affects the scope you invoke it from. To truly clean a server that has stale entries in multiple scopes, must remove from each scope explicitly. `claude mcp list` only shows what's visible from the current path, which can hide old entries in other scopes.

Mitigation pattern used during recovery: **audit all scopes via python on `~/.claude.json`** — walk top-level `mcpServers` + every `projects[*].mcpServers` entry, compare env values. The `claude mcp list` CLI is not sufficient for this audit.

```python
import json
d = json.load(open('/Users/dev01/.claude.json'))
for name, scope in [('global', d), *[(f'proj:{k}', v) for k, v in d.get('projects', {}).items()]]:
    mcp = scope.get('mcpServers', {}) if isinstance(scope, dict) else {}
    for srv, conf in mcp.items():
        env = conf.get('env') or {}
        print(f'{name}.{srv}: {list(env.items())}')
```

## Cross-reference

Related fix: `learning_2026-04-19_telegram-sent-late-w2-pr-230-summary-delivered` documents the specific 404 recovery + re-send workflow this set of gotchas surfaced during.

Tags: brew-ops, memory, mcp-tools, operational, gotcha, config-inheritance, claude-code, telegram, recovery-pattern, 2026-04-19

---
*Added via Oracle Learn*
