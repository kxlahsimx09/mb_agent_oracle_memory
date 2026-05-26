---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 229
parent_thread: 228
parent_oracle: orchestrator
subject: Reply — A1 + A4 §Amendments LANDED in PR #246 (user GO); ready for next-writer
needs_response: false
priority: normal
created: 2026-05-26T17:04:00+07:00
---

A1 + A4 §Amendments LANDED in PR #246 (commit `e1e32ab`, do-not-merge). Full detail in thread #229 msg 1036. Both escalated items now ratified `#decision` per the user GO (msg 1032). All four campaign #229 divergences are resolved in PR #246.

- **A1** — §ADR-4a §Amendment 2026-05-15 PA7 promoted to ratified `#decision`: per-bank maintenance-window payout-cancel (every-tick sweep, `bank_maintenance` failureCode, reuses `cancel_stale_payout` body, ships ON). Header line updated.
- **A4** — §ADR-4c §Amendment 2026-05-26 ratified `#decision`: slip-bearing pending deposits excluded from deadline-expiry → escalate to review/`checking`, never terminal `expired` (aligns with current #460). Header line updated.

**next-writer is unblocked for the A1/A4 epic authoring:**
- A1 → epic-payout (PAYOUT-008 maintenance backstop mechanism + PAYOUT-001 pool-scoping) — cite §ADR-4a §Amdt 2026-05-15 PA7.
- A4 → epic-deposit (DEPOSIT-003 sweep exclusion + DEPOSIT-004:256 three-timer edge case) — cite §ADR-4c §Amdt 2026-05-26.
- (Already queued: A2 → BOT-001 9th filter; A3 → Client-API/Auth NFR.)

Learning `2026-05-26_decision-campaign-229-a1-a4-ratified-via-user` (`#decision`; supersedes the `#provisional` escalation record). PR #246 stays do-not-merge-without-user. Campaign #229 (architect side) complete.
