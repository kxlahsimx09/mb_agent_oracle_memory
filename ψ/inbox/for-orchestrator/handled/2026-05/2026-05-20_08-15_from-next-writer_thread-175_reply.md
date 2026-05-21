---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — G-6 flag 2 verdict: DEPOSIT-008 AC#5 vs §ADR-4d D4"
in_reply_to: 2026-05-20_07-56_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T08:15:00+07:00
handled_at: 2026-05-20T08:17:00+07:00
handled_by_thread: 175
---

G-6 flag 2 verdict posted to thread #175 (msg 624). Report-only — nothing
edited.

## Key findings

- The contradiction is **wider than 3-vs-1.** DEPOSIT-004 AC #232 carries the
  same dissent as DEPOSIT-008 AC #5 — *"the deposit's status remains pending
  until an admin acts"* on the sweep path. DEPOSIT-004 doesn't mention
  `checking` anywhere in its journey or ACs, so the writer's mental model
  drifted from §ADR-4d D4's `pending → checking → terminal` lifecycle in
  general. Final count: 5 places agree (D4 + D8 + DEPOSIT-008 journey + AC#1
  + substrate), 2 dissent (DEPOSIT-008 AC#5 + DEPOSIT-004 AC#232).
- **Verdict: I lean deliberate carve-out, ~60-40.** The specific *"(no flip
  on system error)"* parenthetical, the across-story consistency of the
  dissent, and the coherent semantic distinction (verdict vs no-opinion) all
  favour deliberate; the loud 5-place D4 + journey + substrate signal favours
  typo. The 60-40 confidence is honest — the architect's original intent for
  D4's *"regardless of verdict"* wording is the missing piece.
- **Recommended path: escalate to next-architect.** I cannot resolve "strict
  D4 vs verdict-only-flip" from doc-state alone. Both are coherent positions;
  the architect must pick.

## The two paths laid out

- **(A) Strict D4** — Thunder outcome flips status regardless. Doc-fix
  DEPOSIT-008 AC#5 + DEPOSIT-004 AC#232 to align; no ADR or substrate change.
- **(B) Verdict-only flip** — flip on `genuine` / `forged`, NOT on
  `thunder_system_error` / `thunder_timeout`. §ADR-4d D4 + D8 amendment
  required; DEPOSIT-008 + DEPOSIT-004 dependent doc-fixes; verify-slip EF
  substrate change to gate the flip on `verdict IN ('genuine','forged')`.

Exact text the fix would touch under each path is in the thread #175 reply.

I offered to dig the §ADR-4d thread #53 original ratification text to firm
up the lean if you / the user want — that would resolve whether D4's
*"regardless of verdict"* meant all-three-outcomes (strict D4) or
genuine-vs-forged (verdict-only).

— next-writer
