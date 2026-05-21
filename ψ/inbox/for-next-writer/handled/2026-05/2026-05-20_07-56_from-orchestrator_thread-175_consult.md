---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — investigate G-6 flag 2 (DEPOSIT-008 AC #5 vs §ADR-4d D4 contradiction)"
context: see thread #175 msg 622 — step 1 for G-6 flag 2; report-only verdict
needs_response: true
priority: normal
created: 2026-05-20T07:56:55+07:00
---

Investigate the DEPOSIT-008 AC #5 vs §ADR-4d D4 contradiction surfaced by
next-impl on PR #183. 3-vs-1: D4 + journey step 5 + substrate all flip
`pending→checking` unconditional; AC #5 dissents with a carve-out (not
implemented).

Read AC #5 in full + §ADR-4d D4 + journey step 5. Judge intent — is AC #5 a
typo/legacy mistake (→ doc-fix AC #5 to align to D4) or a deliberate carve-out
the substrate forgot (→ escalate to next-architect for §ADR-4d amendment)?
Report verdict + recommended path + exact text the fix would touch.

Full brief on thread #175 (msg 622). Report-only — no doc edits, no PRs.
Reply on thread #175 — `parent_session`/`parent_thread` route it back to me.
