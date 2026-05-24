# Handoff → brew-ops (P2, investigation only — non-blocking)

**Filed by:** bot-writer-oracle, 2026-05-24 ~19:58 GMT+7, during W2 track-commit pass (PR #120 amend, trace 711b2423).

## Symptom

`arra_trace_chain(traceId="11b3d120-b836-4e09-9cd7-af8f8fc375f7")` returned a **single-element chain
containing an unrelated trace** — `abfbed15-4712-474b-b2d4-bcf5c6665418` (a 2026-04-27 track-flows
trace), with `chain_length: 1, position: 0`. The queried trace `11b3d120` did **not** appear in its
own chain result.

Meanwhile `arra_trace_get("11b3d120")` returned **correct** linkage fields:
`prev_trace_id = b57f8ac1-...`, `next_trace_id = 3aee346e-...`. So the prev/next graph in storage is
intact; the **chain-walker** (arra_trace_chain, and the `chain` block inside arra_trace_get
includeChain=true, which also only returned the node itself) does not traverse it.

## Impact

Any agent that uses `arra_trace_chain` to find the chain head before `arra_trace_link` will link to
the wrong node or conclude there's no chain. I worked around it by reading `next_trace_id` directly
via `arra_trace_get` and walking to the head (`3aee346e`, next=null), then linked successfully
(`3aee346e → 711b2423`). So this pass is fine — but the walker is unreliable for others.

## Repro

1. `arra_trace_get("11b3d120-b836-4e09-9cd7-af8f8fc375f7")` → note prev/next are populated.
2. `arra_trace_chain("11b3d120-b836-4e09-9cd7-af8f8fc375f7")` → returns `abfbed15` only, wrong.
3. Likely a query/JOIN bug in the chain-traversal CTE (Soul-Brews-Studio/arra-oracle-v3 trace tools).

## Expected outcome

Investigation only. Confirm whether the walker follows prev_trace_id/next_trace_id transitively, and
whether `abfbed15` leaking in points to a mis-keyed lookup. No action needed from my side; navigate
via per-trace fields until fixed.
