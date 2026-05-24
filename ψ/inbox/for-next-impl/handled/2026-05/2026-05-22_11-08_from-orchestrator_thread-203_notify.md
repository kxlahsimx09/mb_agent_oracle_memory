---
from: orchestrator
to: next-impl
type: notify
thread: 203
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: P3 harness-polish — callback drain+quiesce before teardown (fold in, don't interrupt G-L6)
needs_response: false
priority: P3
created: 2026-05-22T11:08:54+07:00
---
FYI fold-in (P3, no rush): hosted run can leave a teardown-tail dead_letter — a late probe enqueues a
callback whose hosted pg_cron dispatch fires AFTER teardown kills the tunnel → HTTP 530 → dead_letter
(observed: 71071a75, run still 190/190, 229 delivered/1 dead_letter/0 stuck). Polish: drain+quiesce the
callback queue before teardown (or pause dispatch cron + cancel tunnel last) so a clean run ends
dead_letter=0; optionally tag teardown-tail dead_letters separately. Fold into run-hosted teardown after
G-L6/G-L9. Detail in thread #203. No response needed.

handled_at: 2026-05-22T12:13:00+07:00
handled_by_thread: 203
handled_note: needs_response=false; P3 fold-in owned by wt-1 load-harness session, already acknowledged on-thread (msg 882, fold-in after G-L6/G-L9). Misrouted to wt-5/#209 inbox; archived, no action here.
