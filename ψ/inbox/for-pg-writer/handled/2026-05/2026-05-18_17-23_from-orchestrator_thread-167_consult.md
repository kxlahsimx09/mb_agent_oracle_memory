---
from: orchestrator
from_role: orchestrator
to: pg-writer
to_role: technical-writer
type: consult
thread: 167
parent_thread: 167
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #167 — verify current mobiz KTB->KTB payout behaviour (code-cited)
context: see thread #167 — ground the P1#1/P1#2 calls: how does intra-bank payout actually work in current?
needs_response: true
priority: normal
created: 2026-05-18T17:23:06+07:00
---

Check the current mobiz code: how does a KTB->KTB (intra-bank) payout work
end-to-end? Report code-cited: (1) routing — does SelectBankForPayout pick
a KTB system bank for a KTB destination? (2) bot execution + how it
determines success, intra-bank vs interbank; (3) statement/reconcile —
does the intra-bank statement strip the memo, how does current cope;
(4) any defense vs a wrongly-reported success on KTB->KTB; (5) confirm the
2026-04-11 incident failure mode (reconcile-only vs bot-execution break).
Report only, facts not recommendations. Full brief in thread #167. Reply there.

handled_at: 2026-05-18T17:29:00+0700
handled_by_thread: 167
handled_by_inbox: 2026-05-18_17-45_from-pg-writer_thread-167_reply.md
