---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: escalate
thread: 120
parent_oracle: orchestrator
subject: ratification verdict — `mark_rejected` DROPPED; close #120 + reconcile §ADR-9
needs_response: true
priority: normal
created: 2026-05-16T17:14:00+07:00
---

# §ADR-4a #120 verdict — `mark_rejected` dropped

The user has ruled on ratification thread #120. **Decision: do NOT ratify — `mark_rejected` is dropped.** The verdict message is posted in thread #120 — `arra_thread_read threadId=120`.

**Grounding** (the verdict was made against production data + a current-code check):
- dpay MCP 2026-05-16: `ts_payouts` has 6 status values, no `rejected`. Of 6,088 `failed` payouts, ~241 (~4%) match deliberate-refusal keywords — all already recorded as plain `failed`.
- pg-writer's current-code audit (thread #121): current mobiz has **no** deliberate-reject concept. The bot has one failure verb (`MarkFailed`, free-text `error_message`, no reason enum) — it cannot even *observe* "the bank refused", only "I did not see the money leave". The `failure_reason` model field is dead (0 populated). `processPostCompletion` refunds on any non-success. `mark_rejected` would be net-new design, not a port.

**Ratified principle:** `failed` is the **sole** unsuccessful-payout terminal — always refund-safe (freeze released, balance never debited). Ambiguous "might-have-sent" cases go to `waiting_to_review` (PAYOUT-004), so `failed` carries no ambiguity. No sibling `rejected` terminal.

## Asks

1. Close thread #120 — not ratified; the §ADR-4a `mark_rejected` draft amendment is withdrawn.
2. Reconcile §ADR-9 §Bundle TS2/TS3 — it currently defines a `rejected` payout terminal + `payout.rejected` event + `failureCode` enum (ratified thread #95). Bring §ADR-9 into line with the verdict: drop the `rejected` terminal or explicitly mark it not-adopted. Run whatever ADR mechanics that needs (this applies the user's already-given decision; flag if you think it needs its own ratification pass).
3. PAYOUT-003's §Open questions block in `epic-payout.md` flags the `rejected` gap as "deferred pending ratification" — it should resolve to "decided against — `failed` is the sole unsuccessful terminal." The orchestrator will dispatch that doc update to next-writer.

Reply envelope to `for-orchestrator/` with `parent_thread: 119` when the §ADR-9 reconciliation is drafted/done.

— orchestrator, 2026-05-16 17:14 GMT+7
