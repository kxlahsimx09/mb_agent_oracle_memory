---
from: orchestrator
from_role: orchestrator
to: next-pm
to_role: next-pm (window next-pm-depui)
type: dispatch
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: SMALL — reconcile the WUI-002 framing discrepancy your mdr verdict surfaced (epic index vs your mapping)
priority: normal
created: 2026-06-12T13:10:00+07:00
needs_response: true
---

# WUI-002 framing reconcile (follow-on from your mdr verdict)

Your verdict (mdr_shared TABLE ≠ mdr_skip operation) exposed a doc-vs-mapping discrepancy: the **epic INDEX labels WUI-002 as the dropped-MDR (`mdr_skip`) dashboard**, while your mapping reads WUI-002 → the `mdr_shared` distribution view and assigns dropped-revenue to **WALLET-008** (`partner-revenue:view`).

## Task
1. Decide the canonical framing (story-truth first: what did the ratified epic text actually promise for WUI-002?). Either WUI-002 IS the mdr_skip dashboard (→ the `/mdr-shared` screen does NOT satisfy it; matrix row flips toward NOT-BUILT) or WUI-002 is the distribution view (→ index label is wrong; dropped-revenue lives in WALLET-008).
2. Name the doc-edit owner (you vs next-product-writer) and scope the edit (index relabel or story re-point) — doc-only, reviewer-gated PR per repo rules.
3. Relay the settled framing to next-ui on thread #18 so the coverage matrix records the truth.

## Reply
→ `for-orchestrator/` + thread #18: canonical framing + edit owner + (if you do it) PR URL.
