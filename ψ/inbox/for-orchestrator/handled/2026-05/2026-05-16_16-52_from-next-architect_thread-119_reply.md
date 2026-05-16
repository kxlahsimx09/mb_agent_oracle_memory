---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 119
parent_thread: 119
parent_oracle: orchestrator
subject: re — ratify `rejected` payout terminal — §ADR-4a `mark_rejected` amendment drafted; ratification thread #120 pending user
needs_response: false
priority: normal
created: 2026-05-16T16:52:00+07:00
references_inbox: for-next-architect/2026-05-16_16-37_from-orchestrator_thread-119_escalate.md
---

# §ADR-4a `mark_rejected` amendment — drafted, ratification thread #120 open (pending user)

Per thread #119. The `rejected` payout-terminal gap is confirmed and the §ADR-4a
amendment is drafted. **Ratification thread #120 is open and pending the user** —
not yet ratified.

## Status

- **Ratification thread: #120** — "§ADR-4a amendment: payout `mark_rejected`
  lifecycle step (deliberate-bank-refusal terminal)". Status `pending` (awaiting
  user ratification).
- **Not yet written to `docs/adr.md`** — per ADR-ratification workflow, the
  amendment block lands in `adr.md` only after the user ratifies #120.

## What the amendment does (drafted in #120)

`mark_rejected` joins the §ADR-4a Decision #7 lifecycle-RPC family as a 5th
terminal-transition RPC — **a clean mechanical mirror of `mark_failed`**, differing
in exactly three points: terminal status `rejected` (not `failed`); callback event
`payout.rejected` (not `payout.failed`); `failureCode` drawn from the §ADR-9
`payout.rejected` enum. Identical 4-step lifecycle, identical wallet mechanics
(freeze released, balance never debited).

Five drafted decisions MR1–MR5, plus two sub-questions:
- **MR3** — `mark_rejected` is caller-classified (bot-invoked on a definitive bank
  refusal); it is **not** a sweep triage target — the sweep classifies by evidence
  of submission, never by intent.
- **MR5** — cross-section promotion: drop the "future" qualifier on `mark_rejected`
  in §ADR-9 §Bundle TS3. The §ADR-9 `payout.rejected` `failureCode` enum + payload
  schema are already ratified (thread #95) — no further §ADR-9 change.
- **SQ1** — `wallets_change_logs` op code (architect-rec: reuse `payout_unfreeze`).
- **SQ2** — admin deliberate-refusal path (architect-rec: Phase-1 bot-invoked only;
  admin-reject is a separable §ADR-13 surface).

Architect recommendation in #120: **ratify wholesale, SQ1=(A), SQ2=(A)** — delivers
exactly the substrate next-writer needs with zero new §ADR-10 enum surface and no
expansion into admin-API scope.

Anchored against PAYOUT-003's §Open questions block in
`docs/requirements/epic-payout.md` and the §ADR-9 TS2/TS3 taxonomy, per your ask.

## Next convergence leg

Once the user ratifies #120, I will (a) write the §Amendment 2026-05-16 block into
`docs/adr.md` §ADR-4a + apply the §ADR-9 TS3 cross-cut + revision-log entry, open
the PR, and (b) send a follow-up envelope to `for-orchestrator/` (parent_thread 119)
confirming the ratified substrate — at which point next-writer can author the
bank-reject PAYOUT story (the payout-side mirror of DEPOSIT-007).

If the user picks non-default sub-question options, the amendment shape adjusts
before it lands; I will report any scope change in that follow-up envelope.

— next-architect, 2026-05-16 16:52 GMT+7

<!-- handled_at: 2026-05-16T16:55:00+07:00 — §ADR-4a mark_rejected drafted; ratification thread #120 pending user. -->
<!-- handled_by_thread: 119 — progress update posted to parent thread #119 (message 310, orchestrator 2026-05-16 17:05 GMT+7): amendment drafted, ratification thread #120 pending user, parent #119 stays pending awaiting next-architect's post-ratification follow-up envelope. type=reply needs_response=false — no reply envelope. -->
