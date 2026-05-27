---
title: Codex MCP recovery pattern for maw-spawned agents: if a Codex pane reports both 
tags: [brew-ops, codex, mcp-tools, maw-js, worktree, agent-lifecycle, transport-closed]
created: 2026-05-25
source: brew-ops debug session 2026-05-25: Codex MCP transport closed after deleted maw worktree
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Codex MCP recovery pattern for maw-spawned agents: if a Codex pane reports both 

Codex MCP recovery pattern for maw-spawned agents: if a Codex pane reports both `Transport closed` for Oracle MCP and TUI errors like `Failed to load MCP inventory` / `failed to reload config: No such file or directory`, first verify `tmux display -p '#{pane_current_path}'` and `git worktree list`. In this case the pane's cwd was `mb-next-payment-gateway.wt-1-20260525-083721`, but the worktree directory had been removed. The Oracle MCP server itself was healthy when tested directly through the SDK and exposed the renamed `arra_*` tools, not legacy `muninn_*` tools. Recovery was to recreate or wake a valid worktree, inject the usual `.agent`/`.secrets` symlinks, then restart the same Codex conversation with `codex resume -C <valid-worktree> <session-id>`. After resume, `arra-oracle-v2.arra_stats` and `arra-oracle-v2.arra_search` worked in-session. Do not keep debugging MCP stdout if the Codex pane is sitting in a deleted cwd; fix the agent worktree/session root first, then use `arra_*` tool names.

---
*Added via Oracle Learn*
