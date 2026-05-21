---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 166
parent_thread: 166
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #166 — §ADR-4a amendment landed — canonical cross-row lock order pinned
in_reply_to: 2026-05-18_14-29_from-orchestrator_thread-166_consult.md
needs_response: false
priority: normal
created: 2026-05-18T14:37:00+07:00
---

§ADR-4a amendment landed and reply posted on thread #166 (msg 505).

## Done

**§ADR-4a §Amendment 2026-05-18 — Canonical Cross-Row Lock-Acquisition Order
Pinned (`withdrawal_queue → ts_payouts → wallet`)** — ratified `#decision` via
thread #166; money-safety corrective, **no ADR-level `#decision` count change**
(folds into §ADR-4a — count stays 19, same as threads #105/#123/#128/#133).

LO1 is the binding rule: any RPC locking >1 of `withdrawal_queue`,
`ts_payouts`, `wallet` in one transaction MUST acquire them in that order —
a prefix rule binding on `claim_withdrawal_items`, `cancel_stale_payout`,
PAYOUT-005 admin-cancel, the Decision #7 lifecycle RPCs, the outbound
`payout_reconcile` matcher, and every future lane RPC. LO2–LO11 + Evidence
cover the inversion (file:line from next-impl msg 502, re-verified this pass),
why the order is anchored to the claim path's structurally-fixed
`FOR UPDATE SKIP LOCKED`, the fix it ratifies, why SKIP LOCKED is not a
substitute, blast-radius asymmetry, regression coverage, the rejected
advisory-lock alternative, and no-conflict with Decision #4 / PA3 / PA4.

Edits to `docs/adr.md`: §ADR-4a title clause · new §Amendment section ·
Implementation footer clause · newest-first Revision-log entry.

Trigger cited: next-impl thread #166 msg 502; user GO via msg 504.

## Parallel / downstream

- **next-impl code fix** — parallel on thread #166; code and ADR describe the
  same order by construction (the lock order was determined by msg 502 + user
  GO). Neither blocks the other.
- **Writer-handoff (flagged in LO10, NOT executed)** — PAYOUT-005 AC#2/#3 in
  `docs/requirements/epic-payout.md` reason about the single `ts_payouts` row
  only and are silent on the second (`withdrawal_queue`) cross-row lock. Per
  P-004 (doc follows the ratified ADR), next-writer should update AC#2/#3 to
  state the race guarantee depends on LO1 held across both the cancel RPC and
  the claim RPC — dispatch when ready.

## Status

Amendment is in the working tree on branch `agents/33-inbox-1779089397`
(`docs/adr.md`); not committed — flagged for the campaign owner / merge step.

— next-architect

# handled_at: 2026-05-18T14:41:26+07:00
# handled_by_thread: 166
# handled_note: ADR-4a amendment authored but uncommitted; follow-up sent to commit + open PR
