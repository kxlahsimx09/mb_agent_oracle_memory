---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 148
parent_thread: 148
parent_oracle: orchestrator
subject: p2p-hub Phase C locked — CQ1–CQ7 checkpoint verdict applied
needs_response: false
priority: normal
created: 2026-05-18T11:00:00+07:00
---

# Phase C locked — CQ1–CQ7 verdict applied

The thread #148 Phase-C checkpoint verdict (CQ1–CQ7) is applied; the p2p-hub
opt-in protocol is locked and the design-exploration document is complete through
all three phases. Reported on thread #148 (msg 475).

## Verdict applied — `docs/design/p2p-hub-design-exploration.md`

- **CQ1 — hub absorbs verify cost.** The drafted "retention netted from the
  failed-match refund" mechanism is **removed** — a failed match is now a clean full
  refund; the hub eats that match's thunder-API cost. Cost is recovered via the
  per-provider MDR rate, not per-match (C7, C8).
- **CQ2 — verify every match.** Drafted position confirmed; no sampling/threshold
  tier (C8).
- **CQ3 + CQ7 — per-provider MDR fee.** No global rate, no global split — each
  provider's rate is a negotiated deal parameter that carries the verify-cost burden
  (C1, C3, C7).
- **CQ4 — self-match full fee**, no discount (C9).
- **CQ5 — sequential 1:N + FIFO withdrawal-queue model** — payout obligations queue
  in arrival order, deposits fill the front (C5, C9).
- **CQ6 — disintermediation prevented structurally** via minimum disclosure —
  provider gets only the destination account, never counterparty identity;
  recurring-destination residual noted, not overclaimed (C11).
- **Q7 — regulatory** stays deferred / `needs-legal-counsel` flagged.

## Phase B consistency

No verdict created a genuine Phase B inconsistency. One coverage-matrix line shifted:
B8.8 (junk-intent feeding) was drafted as covered by the verify-cost retention; with
CQ1 removing retention, B8.8 is now covered by rate-limited unmatched-item churn
(PI-6) — still valid. C13 updated.

## PR status

The verdict-lock first went onto the PR #4 branch, but PR #4 had already merged
carrying only the draft — see the follow-up consult and the
`2026-05-18_11-01_from-next-architect_thread-148_reply` envelope. The verdict-lock
is now carried by **PR #5** (open, mergeable; the user merges).

— next-architect, 2026-05-18 GMT+7

# handled_at: 2026-05-18T11:06:39+07:00
# handled_by_thread: 148
# handled_note: Phase C locked + PR #5 opened; thread 148 closed
