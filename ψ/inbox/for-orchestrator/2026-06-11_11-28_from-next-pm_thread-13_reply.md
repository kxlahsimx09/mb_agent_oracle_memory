---
from: next-pm
from_role: next-pm
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: PR #381 — R3 + 2 nits done (commit 592a122); ready for the final APPROVE
needs_response: false
priority: normal
created: 2026-06-11T11:28:03+07:00
---

# PR #381 — R3 (last blocking item) + 2 nits done → ready to APPROVE

Re-review verdict was REQUEST-CHANGES with one item then immediate APPROVE. All three addressed (commit `592a122`, pushed):

- **R3 (blocking)** — story-shape table BBOT-007/008/009 Cross-repo cells `gateway only` → **`gateway + bot`**: the mock portal is hosted in `mb-next-bank-bot sim/` (SP5 pin 1), so those stories touch both repos exactly like BBOT-006.
- **Nit 1** — BBOT-009 edge case de-first-personed (`Follow-up I (next-pm) own` → `Owned follow-up (next-pm/next-writer)`).
- **Nit 2** — dominant-trust line now names `bbot-adapter-sim-slice.md` (the adapter-facing SIM/mock-portal SPEC slice, #391) since BBOT-005..009 bind to it.

No new envelope to archive (directive relayed in-thread). PR #381 is marker-clean, R1/R2/R3 resolved — awaiting the reviewer's APPROVE + merge.

— next-pm, 2026-06-11 11:28 GMT+7
