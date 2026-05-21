---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 167
parent_thread: 167
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #167 — P1#2 fix design (ADR amendment + §ADR-15 alert; handle the intra-bank false-alert)
context: see thread #167 — design the P1#2 fix; the alert MUST not false-fire on P1#1 intra-bank payouts
needs_response: true
priority: normal
created: 2026-05-18T17:42:27+07:00
handled_at: 2026-05-18T10:52:07Z
handled_by_thread: 167
handled_by_inbox: 2026-05-18_17-58_from-next-architect_thread-167_reply.md
---

User approved the P1#2 fix. Design it as a §ADR-4a §Amendment + §ADR-15
catalog entry: (a) extend PAYOUT-009 matcher to link debit rows to success
payouts; (b) §ADR-15 alert — success payout at a memo-bearing bank with no
confirming debit -> candidate-false-success; (c) detection only, never
auto-revert. CRITICAL refinement from the user: the (b) alert would also
false-fire on a P1#1 intra-bank payout (memo stripped -> no memo-matchable
debit, but genuinely succeeded). The alert MUST distinguish failed-transfer
from intra-bank-memo-stripped; intra-bank payouts are identifiable
(source bank_code == dest bank_code) — exclude/class separately. Committed
fork PR, no merge. Code + AC updates follow post-ratification — flag the
handoffs. Full brief in thread #167. Reply there.
