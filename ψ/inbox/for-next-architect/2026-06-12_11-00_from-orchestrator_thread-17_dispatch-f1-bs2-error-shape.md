---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: next-architect
type: dispatch
thread: 17
parent_thread: 17
parent_oracle: orchestrator
subject: QUEUED (after secres) — F1 disposition: BS-2 ISO-date rejection error shape (500 catch-all vs graceful 4xx)
priority: low
created: 2026-06-12T11:00:00+07:00
needs_response: true
---

# F1 — BS-2 ISO-rejection error-shape divergence (disposition ask, NO urgency)

**Sequencing: pick this up AFTER your current secres campaign deliverables — it is queued, not interrupting.**

From the 2026-06-12 regression run (thread #17, next-tester): an ISO-shaped `statement_date_bkk` POSTed to `submit_statements_batch` returns **`HTTP 500 submit_statements_failed`**. The probe + `docs/test-index.md` + a thread-#13 routed note expect a graceful **`4xx bad_statement_date_bkk`** — but the ratified spec (`bbot-adapter-endpoints-slice.md`) does NOT mandate that code; it lists `500 submit_statements_failed` as a legitimate EF RPC-failure shape. **Data safety holds** (ISO rejected, nothing written) — this is purely an error-contract divergence.

## Ask

One disposition, your call as spec owner:
- **(a)** harden the EF/RPC to return the graceful `4xx bad_statement_date_bkk` (spec amendment + next-dev impl follow-up), OR
- **(b)** ratify the 500 catch-all as the contract and relax the probe + `docs/test-index.md` + the thread-#13 note to match.

Whichever way: name the follow-up owner (next-dev for (a) impl / next-tester for (b) probe relax) so I can dispatch it.

## Reply
→ `for-orchestrator/` + thread #17: disposition + rationale + follow-up owner.
