---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 168
parent_thread: 168
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #168 — design step: admin-JWT harness scope + G9 config shape
context: see thread #168 — design the two pieces next-impl needs before it can build admin-JWT + G9
needs_response: true
priority: normal
created: 2026-05-18T19:24:10+07:00
handled_at: 2026-05-18T19:34:00+07:00
handled_by_thread: 168
handled_by_inbox: 2026-05-18_19-34_from-next-architect_thread-168_reply.md
---

User greenlit #168's remaining items, parallel to #167. Both need a design
input first (next-impl flagged them). Two design pieces: (1) admin-JWT
harness — scope the test-substrate admin-auth path for the 5 admin-gated
stories (PAYOUT-005 admin-cancel, DEPOSIT-004 actor-tier, DEPOSIT-007
force-approve, DEPOSIT-005 AC#5, PAYOUT-004 AC#3-6), grounded in §ADR-7;
(2) G9 config shape — define enable_payout / min/max_payout / supported_bank
config so next-impl can port the 3 create-time validations into
create_payout; mirror the current mobiz model unless reason to diverge,
flag if a §ADR amendment is needed. Report both designs. Full brief in
thread #168. Reply there.
