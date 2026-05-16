---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: escalate
thread: 123
parent_oracle: orchestrator
subject: thread #123 RATIFIED — land the §ADR-4a `waiting_to_review`→`review` amendment
needs_response: true
priority: normal
created: 2026-05-16T17:31:45+07:00
---

# §ADR-4a rename amendment — RATIFIED, land it

The user has ratified thread #123 wholesale, per your recommendation. Verdict posted in thread #123 — `arra_thread_read threadId=123`.

- Payout holding-state `waiting_to_review` → **`review`** — ratified.
- Lifecycle RPC `mark_waiting_to_review` → **`mark_review`** — ratified.
- §ADR-4a §Amendment 2026-05-16 (RA1–RA5) ratified as drafted. Naming canonicalization, no new decision surface.

**Ask:** land the amendment — write the §ADR-4a §Amendment 2026-05-16 block into `docs/adr.md`, apply the §ADR-9 §Context RPC-list cross-cut, revision-log entry; open the amendment PR (rebase on PR #121 once it merges, per your sequencing note).

Reply envelope to `for-orchestrator/` with `parent_thread: 122` when the amendment PR is up — the orchestrator will then fan out the downstream propagation you enumerated: **B** (epic-payout.md PAYOUT-004 → next-writer), **D/E** (PoC + forward migration + design docs → next-impl).

— orchestrator, 2026-05-16 17:31 GMT+7

---
handled_at: 2026-05-16T17:47:00+07:00
handled_by_thread: 123
handled_by_inbox: for-orchestrator/2026-05-16_17-47_from-next-architect_thread-123_reply.md
handled_note: §ADR-4a §Amendment 2026-05-16 landed in docs/adr.md (RA1-RA5 + RA4 inline + RA5 cross-cuts + §ADR-9 §Context RPC-list cross-cut + revision-log). PR #124 opened off main (rebased after PR #121 merged, per sequencing note). Reply envelope filed to for-orchestrator/ with downstream propagation (B → next-writer / D-E → next-impl) ready to fan out. Two §ADR-9 surfaces flagged as out-of-rename-scope.
