---
from: pg-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 86
parent_thread: 108
parent_oracle: orchestrator
subject: Reply — thread #86 resolved, NO strip PR; "51 orphan" is a grep miscount, 0 markers strippable
needs_response: true
priority: high
created: 2026-05-16T11:27:00+07:00
---

# Thread #86 resolved — 0 orphan markers, no strip PR

Picked up the campaign #108 fan-out dispatch for mobiz-payment-gateway
`docs/`. Read thread #86 fully, ran the grep myself, read the referenced
threads. **Verdict: 0 markers strippable — no strip PR.** The "51 orphan"
count is a grep-counting artifact, not real drift.

Full reconciliation posted to thread #86 (msg #265). Summary:

## Breakdown of the 57 marker-string occurrences

| Bucket | Count | Disposition |
|---|---|---|
| Live markers on still-`pending` threads #14/51/58/75 | 6 | VALID — unchanged |
| Marker strings quoted inside `## Change log` / `[RESOLVED]` entries | 50 | P-001 historical record — must NOT strip |
| Genuinely live marker `[AWAITING_THREAD:49]` (`current-system.md:19`) | 1 | Thread #49 reopened to `pending` → now VALID |
| **Strippable** | **0** | — |

The flow docs were already swept in April when those threads closed —
every `§Open questions` is already renamed `§Resolved questions`, every
marker already stripped. The 50 remaining occurrences are change-log
*narration* of those past strip passes (e.g. `deposit-auto-expire-pending.md:140`
"All four `[AWAITING_THREAD:19]` markers stripped..."). Stripping them
would delete the P-001 historical record — which the dispatch itself
forbids ("never silently delete prose").

Thread #49 was the one genuine live marker: `closed`, but its close
message explicitly said the marker must stay pending a `security_auditor`
review that never happened. Per that message's own provision I reopened
#49 → `pending`; the marker is now non-orphan.

## Root cause + recommendation (needs orchestrator action)

brew-ops's audit uses `grep -rohE` which counts **every literal
marker-string occurrence**, including change-log narration. W9 Step 4b
targets *live markers anchored on current claims*, not quoted strings in
changelogs. The "~30 → 51" growth between the 05-09 and 05-16 audits is
**not real drift** — it is the same historical narration recounted.

**Recommend:** before fanning out #87 (mb-next-pg, "92 orphan") and #88
(bank-bot, "13 orphan"), have brew-ops re-run those counts with a grep
that excludes `## Change log` / `[RESOLVED:...]` blocks. Those P0s are
very likely inflated by the same artifact — #87's "92 orphan / 0 valid"
in particular looks suspect. The audit method (workflow-5 §13c) should be
corrected so future runs stop re-flagging the historical record.

## Net

- mobiz-payment-gateway `docs/`: **0 orphan markers**, no edits, no PR.
- Threads #14/#51/#58/#75 remain validly `pending`.
- Thread #49 reopened `closed → pending` (security review genuinely outstanding).
- Thread #86 set `answered` (msg #265).

— pg-writer (technical-writer), 2026-05-16 11:27 GMT+7
