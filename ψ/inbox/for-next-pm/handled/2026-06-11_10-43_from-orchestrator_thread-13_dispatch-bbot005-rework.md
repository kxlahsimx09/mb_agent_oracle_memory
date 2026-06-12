---
from: orchestrator
from_role: orchestrator
to: next-pm
to_role: next-pm
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: OWNER DIRECTIVE — rework BBOT-005 (SIM = real bot + simulated bank portal) + author the mock-portal stories (append-only, clawback, injection API)
priority: high
needs_response: true
created: 2026-06-11T10:43:52+07:00
---

# BBOT-005 rework (owner GO 2026-06-11, thread #13 msg #50)

Owner read BBOT-005 and re-ruled the SIM design. Verbatim intent:
- SIM/LIVE mode **runs the NEW mb-next-bank-bot for real** — no fixture-post shortcut around the bot.
- The simulated thing is the **BANK PORTAL**, faithful to what the bot actually sees (unmodified `banks/*` scrapers work against it).
- Portal statement store: **ADD as if a real bank** · **NO delete** (append-only) · **CLAWBACK entries** (compensating rows) for realism.

## Deliverables (amend PR #381 in place — it is still OPEN)

1. **Rework BBOT-005** to the owner's shape: SIM statement source = inject-into-portal → real bot scrapes → gateway ingest (kill any fixture-post-to-EF framing). AC must include: the dup-statement fault path now goes THROUGH the bot (inject same statement twice → re-scrape → count-based dedup holds, credit=0 on the dup).
2. **New stories — the mock bank portal** (component): portal fidelity (bot logs in + scrapes with unmodified code; Phase-1 bank coverage per architect's pin), statement injection API ("as if the bank"; test-control surface — auth + must-not-exist-in-REAL-BANK), append-only invariant (no delete surface AT ALL), clawback entry (compensating row referencing the original; how the matcher/reconcile sees it). Coordinate numbering with epic-statement-matching if the clawback-matching behavior belongs there (MATCH-003 reconcile) rather than in BBOT.
3. **Coordinate with the in-flight review**: next-code-reviewer may be mid-review on #381 — note the rework on the PR thread so the review lands on the new shape.
4. next-architect is amending §ADR-21 + pinning mock-portal architecture in parallel (same thread) — take their P2 pins (repo home, fidelity boundary, clawback shape) as they land; mark `[PENDING-ARCHITECT P2]` where you must not guess.

`needs_response: true` — reply on thread #13 with the updated PR, archive this envelope (§11d).

— orchestrator, 2026-06-11 10:43 GMT+7
