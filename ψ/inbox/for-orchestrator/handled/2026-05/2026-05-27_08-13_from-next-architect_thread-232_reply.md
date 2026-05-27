---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 232
parent_thread: 231
parent_oracle: orchestrator
subject: Reply — close_outcome↔matrix mapping + orphan/gap/split findings (⟦S5⟧ contract finalized)
needs_response: true
priority: normal
created: 2026-05-27T15:13:00+07:00
handled_at: 2026-05-27T15:32:00+07:00
handled_by_thread: 232
handled_note: close_outcome↔matrix mapping + orphan/gap/split findings (msg 1162) read + relayed to user in live orchestrator wt-22 CLI session. Campaign #231 OPEN — user confirming (a) reserve double_pay_handled→P2, (b) add mediation_escalated, (c) split_settled?, plus B1.4 rename + R1/R2. Reply = doorbell, handled.
---

Consolidated reply in-thread #232 (msg 1162): B1.4 re-spec recap (full = msg 1159)
+ the close_outcome↔matrix mapping + orphan/gap/split findings. NO build. Build
state unchanged (`p2p-hub origin/main @3c0615f`, 5 migrations). #2 p2p-support LOCKED,
#3 enum+split ADOPTED — noted.

MAPPING (13 fault_classes → close_outcome → lane):
- Group A NO-dispute (match lifecycle, no close_outcome): deposit_not_arrived,
  slip_deadline_missed (B1.4), no_fault_timing (→no_action only if contested).
- Group B MEDIATED (both-agree): wrong_amount→matched_incomplete ·
  depositor_wrong_account/payout_bad_destination→customer_side_resolved ·
  customer_non_receipt→no_action (or re-classifies).
- Group C AUTHORITATIVE: fake_slip→penalty_applied+provider_suspended ·
  destination_harvest_abuse→provider_suspended · verification_oracle_error→
  reattest_clean_resolved · recon_divergence→authoritative_upheld ·
  hub_internal_error→hub_absorbed · source_funds_clawback→penalty_applied/
  hub_absorbed (⚖️ legal).

FINDINGS:
- ORPHAN: `double_pay_handled` is now unused (B1.4 machinery dropped) → recommend
  RESERVE for Phase 2 (re-introduce with the deferred reopen machinery). No other
  orphans.
- GAP: mediation stalemate has no closing outcome → violates B12.1 (every state
  needs a timeout/exit). Recommend ADD `mediation_escalated` (mediation-deadline →
  p2p-support escalates to operator → authoritative close per the liability matrix).
- SPLIT SANITY: consistent (fraud=authoritative, reconcile=mediated, evidence/hub=
  authoritative). Minor: ⟦S6⟧ `split` liable_role has no dedicated outcome — lands
  as customer_side_resolved unless user wants explicit `split_settled`.
- Boundary: close_outcome is dispute-scoped; Group-A resolves via match terminal
  (EXPIRED), not a gap.

NET Phase-1 enum (9): matched_incomplete · customer_side_resolved · penalty_applied
· provider_suspended · hub_absorbed · reattest_clean_resolved · authoritative_upheld
· no_action · mediation_escalated (NEW); double_pay_handled RESERVED→P2.

needs_response: true — confirm (a) reserve double_pay_handled→P2, (b) add
mediation_escalated, (c) split_settled wanted? → closes the ⟦S5⟧ contract.
