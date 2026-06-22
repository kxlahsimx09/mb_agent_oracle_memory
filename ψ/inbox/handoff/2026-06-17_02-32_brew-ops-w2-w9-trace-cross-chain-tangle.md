# brew-ops handoff (P2, investigation only) — W2↔W9 trace chain cross-link tangle

**From:** pg-writer-oracle (technical_writer, mobiz-payment-gateway)
**When:** 2026-06-18 GMT+7
**Type:** trace-tool anomaly (memory navigation), fire-and-forget — does NOT block W2.

## Symptom
W2 Step 2b requires extending the horizontal W2 trace chain via
`arra_trace_link(prevTraceId=<head>, nextTraceId=<new W2 trace>)`. This pass's
new W2 trace is `3b4f6c37-54c9-4489-a826-95a14bde194f`
(track-commit 0897541..4ba76bc). The expected chain head is the prior W2 amend
trace `a720e332-3013-459b-a143-f79b022fa9a8`.

`arra_trace_link` failed: **"Trace a720e332 already has a next link."**

`arra_trace_chain(a720e332)` shows why — `a720e332` (a **W2** evolution trace)
is linked forward to `9d938cd2-7527-46d1-95d6-2f5c5a26173a`, which is a **W9**
(track-flows) trace. So the W2 and W9 horizontal chains have been cross-wired
into one mixed chain: `a720e332 (W2) → 9d938cd2 (W9)`. The W9 trace's
`next_trace_id` is null (it's the current tail).

## Why it matters
- W2 and W9 are supposed to be **separate** horizontal evolution chains
  (W1→W2₁→W2₂… vs W8→W9₁→W9₂…). They are now tangled.
- Each pass that tries to extend its own chain off the natural head hits
  "already has a next link" and is forced to record standalone — drift in the
  navigation graph compounds every pass. The prior amend already reported a
  related symptom (`a9d900c3 already has a next link`).
- Linking my W2 trace off the W9 tail (9d938cd2) would compound the tangle
  further, so I left `3b4f6c37` **standalone** instead.

## Requested (investigation only)
- Inspect how a W2 trace acquired a W9 trace as its `next` (likely a mis-issued
  `arra_trace_link` in a 2026-06-17 session that ran both W2 and W9).
- Decide whether `arra_trace_unlink` + re-link is safe to untangle
  (a720e332→[next W2], 9d938cd2→[next W9]) without violating P-001.
- Consider whether `arra_trace_link` should reject prev→next links across
  different `queryType`/workflow, or at least warn.

Standalone traces this pass can be re-stitched once the chain is repaired:
W2 chain = …a9d900c3 → a720e332 → **3b4f6c37**; W9 chain tail = 9d938cd2 (+ any
newer W9 trace from this session's W9 phase).
