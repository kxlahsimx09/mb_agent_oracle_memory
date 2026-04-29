---
title: **Backfill pass — trace-link chains for system-architect work (2026-04-29)**
tags: [brew-ops, repo:cross, memory, trace, backfill, trace-link-process-bug, thread-54, next-architect, post-pr-14, post-pr-15]
created: 2026-04-29
source: brew-ops session 2026-04-29 GMT+7 — Oracle MCP backfill pass post PR #14 + #15
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Backfill pass — trace-link chains for system-architect work (2026-04-29)**

**Backfill pass — trace-link chains for system-architect work (2026-04-29)**

Following PR #14 (`arra_learn` trace_link hint) and PR #15 (correct hint wording — `arra_trace` is the missing primitive), did a manual sweep of the next-architect's W1 work for the past 4 weeks and backfilled missing trace chains.

## Discovery that shaped the backfill

Queried `trace_log` before starting: `kxlahsimx09/mb-next-payment-gateway` had **0 traces in 30 days**. The architect's "missed `arra_trace_link` 8 times" complaint conflated two failures — the missing primitive was `arra_trace` itself, not the link. Linking is impossible without prior trace creation.

`arra_trace_link` chains traces (UUIDs in `trace_log`), not learnings — learnings have no FK to each other except `superseded_by`. The actual chain primitive is:

```
arra_learn → file learning markdown
arra_trace foundLearnings=[learning_path] → create trace UUID
arra_trace_link prev=<uuid_A> next=<uuid_B> → chain traces
```

## Chains backfilled (4 chains, 8 traces, 4 links)

| # | Chain theme | prev → next |
|---|---|---|
| 1 | tier-cap (sync 2026-04-24 → resolution 2026-04-27) | `c170ca41` → `610174f9` |
| 2 | ADR-4b (baseline → ratification 2026-04-27, thread #52) | `d1ac97be` → `b55b9a67` |
| 3 | extraction precedent (ADR-8 pass-4 2026-04-24 → ADR-6 2026-04-27) — third bidirectional ADR↔design | `75744df1` → `40fa6995` |
| 4 | ADR-4d (ratification 2026-04-27 → post-ratification amendment 2026-04-28, thread #53) | `9970c5d1` → `cfddbe33` |

All trace queries suffixed `[backfill 2026-04-29]` so the metadata is honest about reconstructive nature — these traces were created today to document past chains, not at the original session times.

## What was deliberately NOT backfilled

- **Substrate convergence (§ADR-4a → §ADR-4b → §ADR-4d, all `finalize_deposit` ports)** — multi-pass cross-day; § ADR-4a learning predates 14d window. Defer until next-architect updates W1 workflow (thread #54) so the chain can be drawn forward.
- **5 user-surfaced clarifications across 2 weeks (cross-direction-metric, body-size, tier-cap, §ADR-4b Q3, §ADR-4d C4)** — meta-pattern, not a sequential chain. Better captured as a `pattern` doc than linked traces.
- **mobiz/bank-bot W2/W9 traces** — already mostly chained (`PN` flag in trace_log). Cosmetic backfill candidates only.
- **W10 / flow-map traces** — created but unlinked (`--`); these are independent constraint records, not sequential evolution. No chain to draw.

## Caveats / what could be wrong

- Trace `created_at` is today, not the original session date. Honest but creates a discoverability quirk: searching trace_log by date won't surface this chain in 2026-04-24/27/28 windows.
- Each chain treats one canonical learning as the "session output" but architect sessions filed 2-4 learnings each. Picking one as the trace anchor is judgment — chosen the most-load-bearing one per session.
- Traces have no parent_trace_id — chain is horizontal-only, no nesting. Acceptable for this depth.

## Status going forward

- thread #54 still pending — escalation to next-architect asking them to update W1 workflow doc to include `arra_trace` step
- once W1 workflow is patched, future passes will create traces in real-time → no more backfill needed
- if this backfill turns out to have wrong chain semantics, supersede via new trace + arra_supersede on this learning (P-001)

---
*Added via Oracle Learn*
