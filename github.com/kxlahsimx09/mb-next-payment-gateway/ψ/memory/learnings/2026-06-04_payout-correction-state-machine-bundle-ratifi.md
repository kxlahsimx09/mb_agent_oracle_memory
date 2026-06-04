---
title: ## Payout correction + state-machine bundle ratified — DEC-A..E (mb-next, campai
tags: [adr, payout, step-up, correction-toolkit, state-machine, residual-mdr, money-safety, telemetry-overturns-classification, campaign-payfix, next-architect]
created: 2026-06-04
source: docs/adr.md §Amendments 2026-06-04 (PR #323, branch arch/payfix-adr); user GO 2026-06-04 campaign payfix
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## Payout correction + state-machine bundle ratified — DEC-A..E (mb-next, campai

## Payout correction + state-machine bundle ratified — DEC-A..E (mb-next, campaign payfix, user GO 2026-06-04, PR #323)

Five RATIFIED payout decisions authored into docs/adr.md as §Amendments (branch arch/payfix-adr, NOT merged). Load-bearing pattern: **production telemetry overturned a stale "debug/legacy" ADR classification.**

- **DEC-A §ADR-2 §S2 carve-out:** payout carved OUT of step-up scope. Grounding: current `VerifyTOTPStepUp` is called for `deposit_refund`/`deposit_refund_resolve` ONLY — current production NEVER step-up-gated any payout action. The 2026-05-26 S2 draft had *added* a payout step-up gate current never had; next-system holds current-parity and drops it. Lesson: re-verify a "harden it" amendment against current source — a draft can invent a control that never existed. Resolves review findings H1/H2.
- **DEC-B §ADR-4a Decision #8:** the current `ConfirmPayoutCompleted` (1300×) / `OverridePayoutStatus` (239×) endpoints were tagged "debug/legacy via mobiz thread #12" in 2026-04-22 and dropped — that read had NO telemetry behind it. dpay telemetry (both used the day before GO) proved them the dominant live CS correction surface. PORTED as two gated admin corrections (reverse_settle success→failed; correction failed/review→success). Lesson: a no-telemetry "legacy" tag is a hypothesis, not a fact — check usage counts before dropping a production endpoint.
- **DEC-D state machine:** the user's late-report SPLIT is the money-safety crux — a late bot `success` from `review` is ACCEPTED (only risks settling money that did leave), but a late bot `failed` from `review` is REJECTED (releasing a freeze / clawing back on an unverified late "failed" from a bot that may have crashed AFTER the money moved = double-spend). Asymmetric on purpose: trust a late success, never a late failure. Drop `claimed`→`processing`; unify terminal `success` (not `completed`).
- **DEC-E §ADR-10:** residual-MDR rule (RM2/R1 — un-routable partner share → is_owner residual wallet) was written for the INFLOW fan-out only; extended symmetrically to the PAYOUT success fan-out. MDR-unwind on reverse-settle = BEST-EFFORT (user ruling): never force a negative partner balance; recover what's available + AUDIT-row the shortfall (a receivable), so the load-bearing client re-credit stays unblockable.
- **DEC-C §ADR-15:** false-FAILED detection P2.17 = the mirror of P2.16 on the FAILED population (a `failed` payout WITH a confirming debit = candidate double-spend). Both siblings self-suppress (change-gated dedup). Detection→remedy loop: P2.16→reverse_settle, P2.17→correction.

Editing discipline for this large ADR doc (6500+ lines): each amendment touches 3 places — (1) inline §Amendment clause body (authoritative), (2) the ADR section-header parenthetical amendment-list, (3) one consolidated dated entry at the top of the newest-first Revision log. Header parentheticals and Implementation closing lines both carry the amendment chain.

---
*Added via Oracle Learn*
