---
title: brew-ops handoff — arra_* MCP tools unreachable via ToolSearch + no HTTP trace-create endpoint
from: pg-writer-oracle (technical_writer, mobiz-payment-gateway)
to: brew-ops
priority: P2
expected_outcome: investigation only
created: 2026-06-06
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - workflow-bug
  - trace-anomaly
  - handoff
project: github.com/kokarat/mobiz-payment-gateway
---

## Symptom

During the 2026-06-06 W2 + W9 cron session (Claude Code harness, model opus-4-8),
the `arra-oracle-v3` MCP server reported `✓ Connected` in `claude mcp list`, but its
tools (`arra_search`, `arra_learn`, `arra_thread*`, `arra_trace*`, `arra_reflect`,
`arra_inbox`, …) could **not** be loaded via the harness `ToolSearch` mechanism.
Every query form returned "No matching deferred tools found", including exact
`select:mcp__arra-oracle-v3__arra_search` and `select:arra_search`. The tools never
appeared in any deferred-tool system-reminder either. (`dpay` MCP tools loaded fine
in the same session, so the harness MCP plumbing itself works.)

## Workaround used this session

- Search / grounding → `GET http://localhost:47778/api/search?q=…` (works)
- Threads (Step 0) → `GET /api/threads?status=…` + `GET /api/thread/:id` (works)
- Learnings → **direct vault file writes** to `ψ/memory/learnings/` (SKILL option 2)
- Retros → direct vault file writes (normal path anyway)

## Gap that has no workaround

The Oracle **HTTP API has no trace-create endpoint** — `/api/traces` is GET (list)
only; create lives solely on the MCP `arra_trace` tool. So W2 Step 2b (evolution-chain
trace) and W9 Step 2b (W9 root trace) + their `arra_trace_link` chain continuation
**could not be created** this session. The evolution chain has a one-session gap for
2026-06-06. Per-finding child traces (W9 Step 5b) likewise skipped — but this pass
produced no C/E drift so none were owed.

## Secondary observation (low priority)

Doc-anchored threads `#14 #49 #51 #58 #75` (live `[AWAITING_THREAD:*]` markers in
`docs/current-system.md` + `docs/flows/withdrawal-queue-dispatch-and-claim.md`) return
`{"error":"Thread not found"}` from the current thread store, which only holds ids 3–9.
Looks like the `forum_threads` table was reset/rebuilt at some point. Markers were left
intact (correct per the doc-anchored model — they are not in `answered` status). Flag in
case the reset was unintentional and the old human answers were lost.

## Ask

1. Why are `arra-oracle-v3` MCP tools invisible to `ToolSearch` on opus-4-8 despite a
   connected server? (Possible `tengu_tool_search_unsupported_models` interaction, or a
   late-registration race.)
2. Should an HTTP `POST /api/traces` create endpoint be added so trace writes survive a
   ToolSearch outage? Today a trace can only be born through the MCP tool.
3. Confirm whether the thread-store reset (ids 3–9 only) was intentional.

Fire-and-forget — my W2/W9 passes completed without waiting on this.
