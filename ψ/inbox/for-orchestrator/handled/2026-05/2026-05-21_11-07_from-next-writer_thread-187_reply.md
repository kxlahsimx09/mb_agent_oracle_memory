---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 187
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#187 reply — Track B doc residual sweep complete; PR #205 opened (DEPOSIT-005 only; DEPOSIT-007/008 zero residuals)"
needs_response: false
priority: normal
created: 2026-05-21T11:07:39+07:00
handled_at: 2026-05-21T11:17:57+07:00
handled_by_thread: 187
handled_note: "Track B doc residual sweep complete: PR #205 OPEN (DEPOSIT-005 only — 3 edits: substrate-catchup citation + Sources + Live revision-log; DEPOSIT-007/008 zero residuals). 5 grep hits classified intentional historical (KEEP); 1 KEEP+extend on DEPOSIT-005 edge at line 316. needs_response=false so no reply envelope required per §11c. Surfaced to user via parent #181 msg 739 alongside PR #206 (clean for merge)."
---

# next-writer → orchestrator (reply on thread #187, Track B of parent #181, doc-only)

Track B doc residual sweep per §CR9 next-writer scope complete. Hand-off back to orchestrator for parent #181 mid-stream + user merge.

## PR

- **PR #205** — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/205
- Branch: `next-writer/thread187-deposit-residual-review-sweep` from `main@6fa5bc6` (post PR #204 merge)
- Commit: `8a9afd2` — 2 files changed, 3 insertions(+), 1 deletion(-)

## Grep-bounded sweep summary

Grep `'review_required'` against `docs/requirements/` returned **5 hits across 3 files** — classified into intentional historical references (KEEP) vs regressions to sweep (none found):

| File | Line | Classification | Action |
|---|---|---|---|
| `epic-deposit.md` | 316 | DEPOSIT-005 edge case "Status-name canonicalized to `review` (ratified)" — historical §FA2/§FA4 corrective narrative ("the ghost name was corrected inline") | KEEP + **extend** with substrate-catchup landing sentence citing §CR3 + §CR4 |
| `epic-deposit.md` | 329 | DEPOSIT-005 Sources `new:adr` cite of §ADR-4b amendment 2026-05-13 §FA1–§FA4 — historical corrective evidence | KEEP |
| `epic-deposit.md` | 333 | DEPOSIT-005 Sources `old:data` production-distribution row `review_required (0 — ADR D3 ghost name; never used in production; corrected via §FA4)` — corrective evidence chain | KEEP |
| `epic-deposit-revision-log.md` | 20 | 2026-05-13 §FA2 revision-log entry — historical narrative | KEEP |
| `epic-deposit-revision-log-archive-2026-05.md` | 38 | Archive narrative | KEEP |

Per live-vs-narrative discipline (cf. `feedback_orphan_marker_grep_false_positive.md`) — all 5 hits are intentional historical corrective references, not regressions from V13+V14 / V15 doc-fix passes. DEPOSIT-005 already canonicalized per the 2026-05-13 §FA2 + thread #100 ratification; this dispatch confirmed no regression.

## DEPOSIT-007 + DEPOSIT-008 — clean

Zero `'review_required'` residuals in ACs / journey steps / edge cases / Sources for either story. No `match_status` semantics prose needing §CR3/§CR4 cite in either:

- DEPOSIT-007's V1.5 predicate at line 355 (`status IN ('paid','pending','review')`) keys on `ts_deposits.status`, not `match_status` — separate §CR5 surface the next-impl substrate handoff owns per §CR9 item (v)
- DEPOSIT-008 doesn't discuss multi-candidate parking

## Applied (3 edits)

1. **DEPOSIT-005 edge case at line 316** — appended substrate-catchup landing sentence citing §ADR-4d §Amendment 2026-05-21 §CR3 + §CR4 (PR #204 merged commit `85d7490`); notes §ADR-4b §FA2 inline annotation at adr.md:603-605 (per §H3-Fix bundled-inline-correction precedent); pattern-instance-#2 note (after withdrawal-lane §RA1–§RA5 instance #1, thread #123).
2. **DEPOSIT-005 Sources block** — new `new:adr` line citing §ADR-4d §Amendment 2026-05-21 §CR1–§CR11 + the deposit-side substrate-catchup scope (§CR2/§CR3/§CR4/§CR6) + the §ADR-4b §FA2 inline annotation + user-ratify GOs from thread #183 msg 712/727.
3. **Revision-log Live entry (2026-05-21)** — full post-ratification handoff entry matching the prior 2026-05-20 V13+V14 + V15 entry shape; covers amendment lock summary (§CR2–§CR7), §CR11 durable rule on cross-lane canonical-naming convergence, applied surface enumeration, sweep verification result, parallel next-impl scope on sub-thread #186, state-grounding cite per `feedback_state_grounding_cite_by_line.md`.

No DEPOSIT-005 AC semantics changed. No DEPOSIT-007/008 changes (zero residuals).

## Thread post

Posted reply to thread #187 (msg 735) with the same content shape. Thread closure (status: answered/closed) is orchestrator's call after the merge.
