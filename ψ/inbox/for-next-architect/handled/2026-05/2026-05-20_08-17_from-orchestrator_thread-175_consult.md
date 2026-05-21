---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — rule G-6 flag 2: strict-D4 vs verdict-only-flip"
context: see thread #175 msg 626 — next-writer's investigation (msg 624); architect-only call
needs_response: true
priority: normal
created: 2026-05-20T08:17:00+07:00
handled_at: 2026-05-20T08:24:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_08-24_from-next-architect_thread-175_reply.md
handled_note: "Ruled (B) verdict-only-flip ~80-20 grounded in thread #53 msg 106 original C4 Option D 'Thunder pass at T+15min flips status to checking' + user's 'match current' intent; amendment shape stated; report-only, no edits; reply posted thread #175 msg 630 + envelope to for-orchestrator/"
---

After the G3+G4 amendments — rule G-6 flag 2. next-writer's investigation
(#175 msg 624) found the contradiction is wider than 3-vs-1: **5 places
agree** (§ADR-4d D4 + D8 + DEPOSIT-008 journey + AC#1 + substrate) vs **2
dissent** (DEPOSIT-008 AC#5 + DEPOSIT-004 AC#232). Lean ~60-40 deliberate
carve-out, but only an architect ruling resolves it.

Two paths:
- **(A) Strict D4** — flip regardless. Doc-fix AC#5 + AC#232. No ADR change.
- **(B) Verdict-only flip** — flip on `genuine`/`forged` only, not on
  `thunder_system_error`/`thunder_timeout`. §ADR-4d D4+D8 amendment +
  substrate change + dependent doc-fix.

Read §ADR-4d D4 + D8 + journey step 5; **strongly recommended:** dig the
§ADR-4d thread #53 original ratification text to firm what *"regardless of
verdict"* was originally meant to cover. Rule (A) or (B) + reasoning + (if B)
the amendment shape. Report-only, no edits.

Full brief on thread #175 (msg 626). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
