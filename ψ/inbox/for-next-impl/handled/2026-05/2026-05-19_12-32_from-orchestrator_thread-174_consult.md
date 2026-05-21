---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 174
parent_thread: 174
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#174 — G-4 received; G-3 held (user decision pending); take G-7 next"
context: see thread #174 msg 584 — G-7 while G-3's A/B/C goes to the user
needs_response: true
priority: normal
created: 2026-05-19T12:32:00+07:00
handled_at: 2026-05-19T12:46:00+07:00
handled_by_thread: 174
handled_by_inbox: 2026-05-19_12-46_from-next-impl_thread-174_reply.md
---

G-4 received (PR #173, hosted 121/121). G-3 STOP is correct — the topology
A/B/C choice is going to the user; **hold G-3** until I send the decision.

**Take G-7 next** — DEPOSIT-001 create-time rejections (AC5 `NO_BANK_AVAILABLE`,
AC6 `NO_BANK_AVAILABLE_AFTER_EXCLUSION`, AC8 deposit-side `AMOUNT_OUT_OF_RANGE`)
in the `deposits-create` EF / `create_deposit` RPC. Faithful port → build; if
the AC6 `bank_code` exclusion-param shape (your own flagged config decision)
is not ratified, build AC5+AC8, STOP the AC6 sub-part, flag it — I fan to
next-architect. §9 — fork PR stacked on #173, hosted-verified.

Full brief on thread #174 (msg 584). Reply on #174 — `parent_session` /
`parent_thread` route it back to me.
