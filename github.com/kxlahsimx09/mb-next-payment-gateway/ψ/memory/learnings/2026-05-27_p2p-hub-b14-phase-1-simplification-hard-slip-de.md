---
title: p2p-hub B1.4 Phase-1 SIMPLIFICATION — hard slip-deadline cliff (user ruling 2026
tags: [system-architect, repo:cross, next, p2p-hub, b1.4, slip-deadline-missed, hard-cliff, phase-1-simplification, expired-terminal, double-pay-removed, dsp-fault, no-inter-provider-settle, fault-class-rename, terminal-immutability, deferred-phase-2, dsp-late-abuse, psp-obligation-state, reputation-signal, dispute-centric, thread-232, campaign-231, decision, scope-narrowing]
created: 2026-05-27
source: docs/design/p2p-hub-design-exploration.md §B1.4/§C5/§C6 @ origin/main 3c0615f (kxlahsimx09/p2p-hub); thread #232 msg 1158 (user ruling) + msg 1159 (reply); supersedes B1.4 portion of 2026-05-27_p2p-hub-dispute-centric-re-cast-user-directive-2
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# p2p-hub B1.4 Phase-1 SIMPLIFICATION — hard slip-deadline cliff (user ruling 2026

p2p-hub B1.4 Phase-1 SIMPLIFICATION — hard slip-deadline cliff (user ruling 2026-05-27, thread #232 msg 1159, campaign #231). Design/spec, NO build. origin/main @3c0615f (5 migrations, unchanged). **Supersedes the B1.4 portion of the dispute-centric recast** (learning 2026-05-27_p2p-hub-dispute-centric-re-cast-user-directive-2) — the rest of that recast (mediation spine, other rulings) STANDS; only B1.4 simplifies.

THE RULE (verbatim, Phase 1): the deposit-side **slip-upload deadline on the hub clock** (PI-1; e.g. 1h) is the single authority.
- Settle gate = (slip uploaded BEFORE the hub-clock deadline) AND (thunder verifies REAL + correct amount). Within the window, re-verify as many times as needed (the verification_oracle_error re-attest-until-clean loop lives here, bounded by the deadline).
- Miss the deadline (no slip in time) → match EXPIRED, FULL STOP — regardless of whether money actually moved. Late slip simply refused ("past deadline = didn't happen").
- Late-but-real transfer disposition: funds at destination = PSP-customer benefit (withdrawer keeps them); DSP-fault (DSP↔its own depositor; not hub's, not PSP's); NO inter-provider settlement.
- WHY CLEAN: EXPIRED never settles → no reopen → a late deposit can NEVER trigger a second settlement. The double-pay problem is STRUCTURALLY REMOVED in Phase 1 by never looking back past the deadline.

DEFERRED TO PHASE 2 (analysis preserved in thread msg 1138/1152 + prior learning, NOT deleted; revisit only if late-transfer RECOVERY is ever wanted): EXPIRED→DISPUTE reopen · double-detection (PSP fresh-obligation-at-INSTRUCTED) · D-1..D-4 (CANCEL-FRESH/UNWIND-REFUND/REBIND-LATE/MANUAL-MEDIATE) · duplicate-suspected-hold. Phase-1 explicitly ACCEPTS the hard cliff (late DSP eats it; PSP-customer keeps the windfall).

MATRIX ROW: rename `late_deposit_double_pay` → **`slip_deadline_missed`** ("double_pay" no longer describes Phase 1). Collapses to the `deposit_not_arrived` shape; moves from the MEDIATED group to the AUTO/NO-DISPUTE group (with deposit_not_arrived, no_fault_timing): no dispute, EXPIRED, DSP-fault (DSP↔own customer), no inter-provider debit, DSP reputation signal (⟦S3⟧) on chronic lateness; hub-clock deadline dispositive (thunder consulted only within the window).

RESIDUALS (conscious Phase-1 acceptances):
- R1 PSP obligation post-EXPIRED: released back to PSP → re-pool into FIFO or PSP's own system-bank rail (hub does NOT auto-pay on expiry; PSP chooses). Subtle: if DSP transferred late, withdrawer's destination gets late funds AND the PSP re-pays → withdrawer double-credited, BUT neither is a hub-settled match → hub ledger stays clean, no inter-provider imbalance; double-credit lives on the providers' own customer books (PSP reconciliation flag, not hub-mediated in P1).
- R2 DSP-late abuse: self-harming (DSP's depositor funds reach destination but match EXPIRED → no credit/fee → no economic incentive). Monitor non-economic angles: (a) griefing/liquidity-denial (lock a PSP obligation then let it expire to degrade a competitor's match rate); (b) off-books money movement (pay-late to push funds without a settled-match record → AML/layering, folds into B8.3). Mitigate: ⟦S3⟧ reputation + §C5 poison/quarantine cap + ⟦S1⟧ suspension.
- R3 terminal-immutability (B12.5) now TRIVIALLY satisfied for B1.4 (zero post-terminal transitions; no reopen). The append-only-overlay reopen modeling now relevant ONLY to source_funds_clawback (B1.7 SETTLED→dispute window, still ⚖️ legal).

STILL OPEN (untouched by this ruling): #2 p2p-support role confirm · #3 close_outcome enum + both-agree-vs-authoritative split · D-label rename nod.

---
*Added via Oracle Learn*
