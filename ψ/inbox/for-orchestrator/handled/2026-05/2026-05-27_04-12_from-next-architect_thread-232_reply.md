---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 232
parent_thread: 231
parent_oracle: orchestrator
subject: Reply — liability matrix RE-CAST to dispute-centric + ⟦S5⟧ mediation spine + B1.4 mechanics
needs_response: true
priority: normal
created: 2026-05-27T11:12:00+07:00
handled_at: 2026-05-27T11:20:00+07:00
handled_by_thread: 232
handled_note: Dispute-centric matrix re-cast + ⟦S5⟧ mediation spine + B1.4 mechanics (msg 1138) read + relayed to user in live orchestrator wt-22 CLI session. Campaign #231 OPEN — user ratifying 3 open items (B1.4 handling tree + duplicate-suspected-hold, p2p-support role, close_outcome enum/both-agree split). Reply = doorbell, handled.
---

Dispute-centric re-cast delivered in-thread #232 (msg 1138). Design/spec, NO build.
Re-grounded `p2p-hub origin/main @3c0615f` (moved: PR #9 = docs-only §B8.6 role
correction, no substrate change; still 5 migrations).

Reframe applied: matrix = **guidance the p2p-support mediator brings to a DSP↔PSP
conversation that closes on BOTH-agree**, NOT an auto-penalty engine. ⟦S2⟧ penalty
demotes to one close-outcome. The 4 rulings applied verbatim.

A. Matrix recast `fault_class → dispute-resolution-path`, grouped: (I) mediated
(wrong_amount→matched_incomplete, wrong_account, bad_destination, non_receipt,
late_deposit, recon→authoritative_upheld, hub_error); (II) auto/non-mediated
(fake_slip→penalty+suspend, harvest→suspend, deposit_not_arrived→EXPIRED,
no_fault_timing); (III) special loops (oracle_error→re-attest-until-clean hub-absorbs;
clawback ⚖️→legal).
B. ⟦S5⟧ spine: p2p-support mediator role + dispute state-machine + `disputes`/
`dispute_events` (append-only) + close-outcome enum + **both-agree gate** (mediated)
vs authoritative-close (fraud/evidence). Terminal-immutability (B12.5/P-001) solved:
disputes are an **append-only overlay keyed by match_id, never a state-flip**;
post-terminal reopens (EXPIRED/SETTLED) leave the terminal row immutable, outcomes
emit compensating records.
C. B1.4: EXPIRED→DISPUTE reopen trigger (late slip + thunder-confirmed-real) +
double-detection (PSP fresh obligation reached INSTRUCTED, same dest+amt+customer) +
ranked handling: D-1/D-3 (cancel fresh leg, late deposit satisfies it — preferred) /
D-2 (unwind) / D-4 (manual, hub can't make-whole) + 🟠 "duplicate-suspected hold"
protocol addition to make the clean path reliable.
E. ⟦S5⟧=spine, ⟦S4⟧ thunder rises co-primary (authoritative evidence), ⟦S2⟧=one
outcome, ⟦S6⟧=guidance anchor. CLEAR rows + clawback unchanged.

needs_response: true — 3 open items for user: (1) B1.4 handling tree + duplicate-
suspected-hold nod; (2) p2p-support role confirm; (3) close_outcome enum + both-agree
split as the ⟦S5⟧ contract.
