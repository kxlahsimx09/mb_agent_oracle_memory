---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 232
parent_thread: 231
parent_oracle: orchestrator
subject: Reply — B7.5 liability matrix draft (fault_class → liable-party, CLEAR/NEEDS-USER/NEEDS-LEGAL)
needs_response: true
priority: normal
created: 2026-05-27T10:07:00+07:00
handled_at: 2026-05-27T10:12:00+07:00
handled_by_thread: 232
handled_note: B7.5 liability matrix draft (13 rows, msg 1114) read + relayed to user in live orchestrator wt-22 CLI session. Campaign #231 OPEN — user now ratifying row-by-row (7 CLEAR + 5 contested 🟠/⚖️ + pg-writer fan-out offer). Architect dispatch with the ratified calls = new consult envelope once user decides. Reply = doorbell, handled.
---

B7.5 liability matrix proposed draft delivered in-thread #232 (msg 1114). Design
pass, NO build. Grounded §C11 + §D7 + §B7.5 + mobiz precedent; re-verified
`p2p-hub origin/main @6f7517e` (unchanged).

Spine = "who vouched for what" (DSP: depositor transfers + source-legit + slip +
amount; PSP: destination it supplied; hub: matching/delivery/verify gate).

13-row matrix with a stable `fault_class` enum that feeds ⟦S6⟧ `liability_terms`
(versioned, countersigned at C3 registration; version pinned per-match at PROPOSED)
and ⟦S5⟧ `disputes.fault_class`→derived `liable_provider_id`→⟦S2⟧ penalty.

✅ CLEAR (ratify as-is): depositor_wrong_account→DSP · payout_bad_destination→PSP ·
fake_slip→DSP (mobiz slip-fraud precedent) · customer_non_receipt→no-inter-liability ·
destination_harvest_abuse→suspend · no_fault_timing→hub-clock · hub_internal_error→hub.

⚖️ NEEDS-LEGAL: source_funds_clawback (B1.7) → deposit-side-in-principle, but
enforceability + balance-cap shortfall + AML tie (B8.3/G1, sharpened by §D1) route
to legal.

🟠 NEEDS-USER (4): verification_oracle_error (hub-absorbs?) · wrong_amount
partial-at-destination (who recovers?) · late_deposit_double_pay (unrecoverable
absorber; recommend PSP) · recon_divergence (which truth authoritative).

Honest-teeth caveat stated: every liable-row is enforceable only via ⟦S1⟧+⟦S2⟧ and
capped by the at-fault provider's hub-balance; loss>balance + walk-away → degrades to
suspension+reputation, no make-whole (ratified B7.4/Q5 ceiling).

mobiz precedent is intra-gateway only (slipFraudCheck.go #360, slipMatchHash #362) —
**inter-provider allocation is novel, no direct precedent.** Offered a pg-writer
fan-out for the mobiz clawback anchor (B1.7) if wanted.

needs_response: true — awaiting row-by-row ratify + the 6 contested calls + the
pg-writer fan-out decision.
