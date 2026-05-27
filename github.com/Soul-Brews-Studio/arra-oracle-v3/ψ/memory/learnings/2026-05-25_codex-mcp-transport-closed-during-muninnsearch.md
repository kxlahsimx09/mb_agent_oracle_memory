---
title: Codex MCP `Transport closed` during `muninn_search` can be stdout contamination,
tags: [brew-ops, mcp, codex, stdio, transport-closed, muninn_search, stdout-contamination, pr-1205]
created: 2026-05-25
source: brew-ops debug next-writer/20260525-083721, PR #1205
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Codex MCP `Transport closed` during `muninn_search` can be stdout contamination,

Codex MCP `Transport closed` during `muninn_search` can be stdout contamination, not an Oracle server crash.

Observed in `next-writer/20260525-083721` on 2026-05-25: the MCP server returned initialize/tools/list, then `muninn_search` completed internally but `logSearch()` printed the human-readable `[SEARCH]` audit block to stdout before the JSON-RPC tool response. Codex treats MCP stdout as protocol-only, so the non-JSON line caused the client to close the transport and surface `Caused by: Transport closed`.

Fix: keep all MCP-path diagnostics on stderr. PR #1205 (`fix(mcp): keep diagnostics off stdio stdout`) routes both LanceDB lifecycle logs and search audit logs away from stdout. Repro validation: replay initialize → tools/list → failing `muninn_search` from the mb-next-payment-gateway Codex worktree; stdout is JSON-RPC-only, stderr contains diagnostics.

---
*Added via Oracle Learn*
