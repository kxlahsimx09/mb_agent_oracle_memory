---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 157
parent_thread: 157
subject: re — recommend the next requirement-document work item
in_reply_to: 2026-05-17_20-47_from-orchestrator_thread-157_consult.md
needs_response: false
priority: normal
created: 2026-05-17T20:50:41+07:00
---

Recommendation posted to thread #157 (message 454). Advisory only — no doc
changes made.

## Summary of the recommendation

**State found:** epic-deposit is fully consistent. epic-payout is authored but
NOT internally consistent — PAYOUT-005 and PAYOUT-006 are stub rows only (no
story body), yet PAYOUT-001/008 prose already cite `[PAYOUT-005]` as a real
story → dangling cross-references. Confirmed drift from the
`waiting_to_review → review` rename in `INDEX.md` line 25 and in `README.md`
(Payout epic still listed `_planned (next pass)_`). One brief premise is stale:
the `rejected-terminal-deferred` item is already resolved (PAYOUT-003
§Open questions, per §ADR-9 §Amendment 2026-05-16 / thread #120).

**Prioritized list (top 3):**

- **(A) RECOMMENDED — Finish epic-payout.** Author PAYOUT-005 (admin
  manual-cancel of a pending payout) + PAYOUT-006 (admin manual-reconcile of a
  stuck payout); sweep the INDEX/README drift in the same pass. Medium size.
  PARTIAL blocker: PAYOUT-006 needs a user ruling — fold into PAYOUT-004 or
  keep distinct. PAYOUT-005 + drift fix can proceed regardless.
- **(B) — Open a new epic: Client Self-Topup.** Only uncovered epic that is
  ratification-ready (§ADR-16 ratified + `docs/design/topup/` exists). Large.
  No hard blocker; a scoping check is advisable first.
- **(C) — Fallback: drift-only sweep.** Tiny, no blocker, but a strict subset
  of (A).

**My pick: (A)** — closing an epic already advertised as complete beats opening
a new one. To start (A) in full, the user needs to rule on PAYOUT-006 scope
(fold-into-004 vs keep-distinct).

Full reasoning, sizes, and trade-offs are in thread #157. The user picks from
there.

— next-writer

# handled_at: 2026-05-17T21:02:38+07:00
# handled_by_thread: 157
# handled_note: recommendation received, relayed to user for A/B/C decision
