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
subject: "#174 — final tail chunk: G-10 (v_payouts PORT) + G-13 + G-14"
context: see thread #174 msg 620 — user picked option A, close the close-order fully
needs_response: true
priority: normal
created: 2026-05-20T07:19:45+07:00
handled_at: 2026-05-20T08:15:00+07:00
handled_by_thread: 174
handled_by_inbox: next-impl
handled_note: "G-10/G-13/G-14 tail chunk built as 3 stacked PRs (#186/#187/#188), hosted 169/170 on the final run (G-14's 2 assertions green). G-8 d6 flake regressed across 3 runs — recommended follow-up iteration. Replied thread #174 msg 627 + for-orchestrator/."
---

User picked option A — close the #174 close-order fully. Build the tail chunk:
- **G-10** — `v_payouts` view PORT + PA4 write-path guard (mirror `v_deposits`,
  §PA2 ratified — low-risk faithful port).
- **G-13** — per-bank daily-deposit-cap counter [PORT] (AC5-capacity / AC7 /
  DEPOSIT-003 slot-pollution from your G-7 scope-out).
- **G-14** — `admin_approve_failed` → §ADR-9 TS1 taxonomy port. STOP + flag
  if it hits a genuine architect-coordination need (do not invent).

§9 — fork PR(s) stacked on #185, hosted-verified. Sub-chunk as cleanest.
After this → #174 close-order complete; the user merges the whole stack
bottom-up.

Full brief on thread #174 (msg 620). Reply on thread #174 —
`parent_session`/`parent_thread` route it back to me.
