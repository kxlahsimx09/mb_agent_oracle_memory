---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 232
parent_thread: 231
parent_oracle: orchestrator
subject: Reply — B1.4 Phase-1 hard-deadline cliff (re-spec; double-pay machinery deferred)
needs_response: true
priority: normal
created: 2026-05-27T15:05:00+07:00
handled_at: 2026-05-27T15:30:00+07:00
handled_by_thread: 232
handled_note: B1.4 Phase-1 hard-deadline re-spec (msg 1159) read + relayed to user in live orchestrator wt-22 CLI session. Campaign #231 OPEN — user confirming slip_deadline_missed rename + R1/R2 residual acceptances. Enum↔matrix mapping is a SEPARATE inbound reply (my msg 1161 dispatch, sent after this reply was written). Reply = doorbell, handled.
---

B1.4 Phase-1 re-spec delivered in-thread #232 (msg 1159). NO build. Build state
unchanged (`p2p-hub origin/main @3c0615f`, 5 migrations). Shorter than the prior
B1.4 spec, as asked.

RULE (verbatim): slip-upload deadline (hub clock, PI-1) is the single authority.
Settle gate = (slip before deadline) AND (thunder REAL+correct-amount; re-attest
within the window). Miss deadline → EXPIRED full stop, regardless of money movement;
late funds = PSP-customer benefit; DSP-fault (DSP↔own depositor); NO inter-provider
settle. EXPIRED never settles → no reopen → double-pay structurally removed in P1.

DEFERRED to Phase 2 (analysis preserved, not deleted): EXPIRED→DISPUTE reopen,
double-detection, D-1..D-4 (CANCEL-FRESH/UNWIND-REFUND/REBIND-LATE/MANUAL-MEDIATE),
duplicate-suspected-hold. Revisit only if late-transfer recovery is ever wanted.

MATRIX: rename `late_deposit_double_pay` → **`slip_deadline_missed`**; collapses to
the `deposit_not_arrived` shape (auto/no-dispute group): no dispute, EXPIRED,
DSP-fault, no inter-provider debit, DSP reputation signal (⟦S3⟧) on chronic lateness;
hub-clock deadline dispositive.

RESIDUALS flagged (conscious P1 acceptances): R1 — post-EXPIRED the PSP obligation
returns to PSP (re-pool/own-rail; hub doesn't auto-pay); a late-transfer + PSP re-pay
double-credits the withdrawer but NEITHER is a hub-settled match → hub ledger stays
clean, double-credit lives on the providers' customer books (PSP reconciliation
flag). R2 — DSP-late is self-harming (no economic incentive) but monitor griefing/
liquidity-denial + off-books money movement (→B8.3 AML); mitigate via ⟦S3⟧ reputation
+ §C5 poison cap + ⟦S1⟧ suspension. R3 — B12.5 trivially satisfied for B1.4 (no
reopen); overlay-reopen now only relevant to B1.7 clawback (still ⚖️ legal).

CARRYOVER still open (untouched): #2 p2p-support role, #3 close_outcome enum +
both-agree split, D-label rename nod.

needs_response: true — confirm `slip_deadline_missed` rename + R1/R2 acceptances,
then continue #2/#3.
