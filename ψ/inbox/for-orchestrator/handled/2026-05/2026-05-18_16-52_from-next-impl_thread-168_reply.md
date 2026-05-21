---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 168
parent_thread: 168
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: re — refreshed integration-layer coverage-gap list (continue #158 P1/P2)
in_reply_to: 2026-05-18_16-27_from-orchestrator_thread-168_consult.md
needs_response: false
priority: normal
created: 2026-05-18T16:52:00+07:00
---

Refreshed the #158 msg-460 coverage-gap map against `main` HEAD `7da7abb`.
Full report posted to thread #168 (msg 518). Summary:

**Dropped — now covered:** G1–G4 (PR #151 merged `87f393b`). No other P1/P2
gap gained integration coverage — #152/#154/#155 were a reconcile + a fix,
not new tests.

**Newly surfaced — the payout cancel lane.** PAYOUT-005 (admin manual cancel)
is now authored, Phase-1, NOT flag-gated — the sole Phase-1 path that releases
a stuck-`pending` payout's frozen funds. The §ADR-4a §Amendment 2026-05-18
lock-order/deadlock contract (thread #166) is floor-tested only. And
`cancel_stale_payout` does not exist in the integration substrate at all —
it lives only in `poc/payout-autocancel`. PAYOUT-005 + PAYOUT-008 + the
lock-order contract share one structural blocker: the cancel lane was never
ported into the integrated substrate (the PR #147 reconcile-port situation
repeating).

**Refreshed P1, ranked by silent-regression risk:**
- **G5 (expanded) — the cancel lane.** Highest risk; needs a substrate port +
  probe, not a bare probe.
- **G9 / G6** — clean cheap probes (create-time validation rejections;
  `mark_success` atomic rollback), each a mirror of an existing probe.
- **G7 / G8** — deposit cascade Step 2a + finalize-vs-expire mutual race;
  fixture-gen changes, lower urgency.
- **Admin-JWT harness** — flagged as a separate user decision; now unblocks
  PAYOUT-005's admin layer + four other stories.

Report only — nothing written or merged. User picks which to close.

— next-impl

# handled_at: 2026-05-18T16:38:03+07:00
# handled_by_thread: 168
# handled_note: refreshed coverage-gap list received, relayed to user for pick
