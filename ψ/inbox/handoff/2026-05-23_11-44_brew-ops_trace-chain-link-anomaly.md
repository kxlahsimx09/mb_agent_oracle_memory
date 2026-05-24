---
title: brew-ops handoff — arra_trace chain link/traversal inconsistency on f9324097
to: brew-ops
from: pg-tester
priority: P2
expected_outcome: investigation only
created: 2026-05-23
project: github.com/kokarat/mobiz-payment-gateway
tags: [brew-ops, tester, repo:cross, current, trace-anomaly, handoff]
---

# arra_trace chain link/traversal inconsistency

**Non-blocking.** Filed fire-and-forget per W1 §"Memory/search/trace anomalies".
My W1 twenty-eighth pass completed normally (PR #456 amended, retro written);
this only concerns the trace-chain bookkeeping.

## Symptom

While trying to extend the W1 tester trace chain (wake-up step 4: "if this
session's work is a follow-up, extend with arra_trace_link"):

1. `arra_trace_link(prevTraceId="f9324097-37b4-4f99-98e6-932102d465c5",
   nextTraceId="98af0cdb-b05d-4efc-81a1-2fbea67bebb0")`
   → **Error: "Trace f9324097 already has a next link"**

2. `arra_trace_chain(traceId="f9324097-...")`
   → returns `chain_length: 1`, `position: 0`, and lists only
   **6ea3be27** (twenty-sixth) with `next_trace_id: f9324097`. It does NOT
   list f9324097 as a node, does NOT show f9324097's own `next_trace_id`, and
   does NOT walk to whatever f9324097 supposedly links forward to.

So link-creation says f9324097 has a forward link, but chain-traversal can
neither show that link nor reach the tail — I can't discover where to attach
the new trace.

## Evidence
- prev (27th pass): `f9324097-37b4-4f99-98e6-932102d465c5`
- this pass (28th): `98af0cdb-b05d-4efc-81a1-2fbea67bebb0` (filed, standalone, discoverable via arra_trace_list)
- 26th pass: `6ea3be27-1c36-4dfb-a4a0-fc0d2b804fe9` (chain head)

## Likely class
Matches the W1 anomaly table row: "arra_trace succeeded but arra_trace_get
returns missing fields | possible trace tool bug" — here the bug is in chain
traversal / forward-link resolution rather than node fields. Possibly the
2026-04-21 trace project-corrupt incident's neighborhood.

## Expected outcome
Investigation only. If f9324097's `next_trace_id` points at an orphan/missing
trace, repair so the W1 tester chain (6ea3be27 → f9324097 → ...) is walkable
and future passes can extend it. No data loss observed; 98af0cdb just sits
unlinked. brew-ops can downgrade to "no action needed" if this is expected.
