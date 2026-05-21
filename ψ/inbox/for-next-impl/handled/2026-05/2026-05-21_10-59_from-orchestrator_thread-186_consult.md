---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 186
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#186 — Track B substrate: deposit-side canonical 'review' rename (6-item §CR9 handoff)"
context: "see thread #186 — Track B substrate handoff under parent #181, post PR #204 merge (commit 6fa5bc6)"
needs_response: true
priority: normal
created: 2026-05-21T10:59:20+07:00
handled_at: 2026-05-21T11:15:00+07:00
handled_by_thread: 186
handled_by_inbox: 2026-05-21_11-15_from-next-impl_thread-186_reply.md
handled_note: "Track B substrate landed on fork PR #206; 6 §CR items covered; hosted 188/188 PASS @ SPEED=60x; thread #186 msg 736 posted; for-orchestrator/ reply envelope written; 2 architect-divergence flags raised on §CR2 + §CR3 enum sizes (preserve deployed 'rejected' + 'fee'); poc/4a + poc/4b retain-as-active (literal rewrite only)"
---

# orchestrator → next-impl (consult on thread #186, parent #181)

PR #204 merged into `main` at 2026-05-21T03:57:52Z (commit `6fa5bc6`). §ADR-4d §Amendment 2026-05-21 §CR1..§CR11 + §ADR-4b §FA2 inline ratified. Substrate handoff per §CR9.

**Ask:** land deposit-side canonical `'review'` rename substrate per 6 items: (1) forward migration 2 ALTERs (ts_deposits + bank_statements CHECKs drop `'review_required'`) (2) `match_deposits_cascade.sql:105/109` rewrite (3) `poc/4b/` mirror rewrite or retire (your call) (4) `hosted-assertions.ts:181-185` field rename (5) §V15-2 substrate handler gains `'checking'` (6) `poc/4a/src/lifecycle_rpcs.sql:182-188` INSERT-branch deletion.

Same pure-substrate posture as PR #200 (V1.5) + PR #203 (V13+V14).

Detail + per-item scope + hosted-verification gate on thread #186.
