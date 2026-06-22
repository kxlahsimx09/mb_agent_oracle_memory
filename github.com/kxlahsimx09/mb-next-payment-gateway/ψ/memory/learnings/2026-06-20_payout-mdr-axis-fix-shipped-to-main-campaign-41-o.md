---
title: Payout-MDR axis fix SHIPPED to main (campaign 41-o-business-gap, 2026-06-20). Th
tags: [payout-mdr-fix, ADR-31, GW-PAY-04, GW-FEE-02, build-workflow, orchestrator, mb-next-payment-gateway, pr-662, pr-663, pr-664, settlement-blocking, prod-backfill-pending, next-pm, next-investigator-seal]
created: 2026-06-20
source: orchestrator campaign 41-o-business-gap, payout-MDR fix chain, 2026-06-20
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Payout-MDR axis fix SHIPPED to main (campaign 41-o-business-gap, 2026-06-20). Th

Payout-MDR axis fix SHIPPED to main (campaign 41-o-business-gap, 2026-06-20). The settlement-blocking gap GW-PAY-04/GW-FEE-02 (NEW gateway fanned out payout MDR using the deposit `percentage` column → all 40 prod profiles fail-close with mdr_over_allocated) is FIXED end-to-end via the full build-workflow driven by the orchestrator: Phase1 next-architect → ADR-31 (reverses §ADR-24 d1 for the payout axis only; PR #662 merged) + spec; Phase2 next-dev-1 (slot dev-1) → 3 ordered migrations (schema add payout_percentage numeric(7,4) → backfill → activate flip mark_success + write-validation Σ payout% ≤ payout_fee_percent) + 2 EFs (PR #663 merged, 166/166 dev verify); Phase3 next-code-reviewer APPROVE + next-investigator SEAL CONFIRMED (re-derived 40/40 prod profiles settle under NEW, fail under OLD); Phase4 next-pm updated the parity register (docs/audit/parity/, PR #664). DEPLOY CAVEAT (still pending): the PROD per-(profile,partner) payout_percentage backfill is a brew-ops deploy-time op that MUST precede/accompany the activate migration on prod — else mis-distribution to mdr_owner (money conserved, still better than today's fail-close). Each phase = fresh teammates under own orchestrator slug (payoutmdr/payoutmdrbuild/payoutmdrrev/payoutmdrseal/payoutmdrpm), closed on idle. Owner merged all doc/code PRs (#662/#663 done; #664 register pending owner merge). STILL OPEN for owner: GW-CB-06 (callback retry 7→3 downgrade — verdict resolved, decision Pending), GW-X-02 over-draw, GW-REC-01 self-healing parser, GW-SCH-02 system-wide maintenance, BOT-D-02 SCB browser-recycle.

---
*Added via Oracle Learn*
