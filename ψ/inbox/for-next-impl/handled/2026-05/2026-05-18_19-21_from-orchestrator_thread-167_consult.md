---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 167
parent_thread: 167
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #167 — P1#2 matcher code (implement §ADR-4a §Amendment 2026-05-18 SC1-SC11)
context: see thread #167 — implement next-architect's P1#2 design (PR #162 is the spec); dispatch now, don't wait for merge
needs_response: true
priority: normal
created: 2026-05-18T19:21:39+07:00
handled_at: 2026-05-18T19:45:00+07:00
handled_by_thread: 167
handled_by_inbox: next-impl
---

User GO'd the P1#2 handoff now. Implement next-architect's §ADR-4a
§Amendment 2026-05-18 (SC1-SC11, spec in PR #162): SC1 outbound-matcher
3rd branch (link debit -> success payout, statement-side only); SC2
confirmed/exempt/unconfirmed classification; SC3 intra-bank exempt
predicate BEFORE the no-debit test; SC4 payout_memo_carries_request_id
capability + migration (KTB seed, fail-safe default); SC5 §ADR-15 P2.16
alert workflow + runbook + grace window. Fork PR, no merge, verified
green on hosted substrate. Full brief in thread #167. Reply there.
