---
title: epic-wallet-ledger 4-lens PRE-DEV review + dpay-verify arc — IN PROGRESS as of 2
tags: [orchestrator, team-dispatch, epic-wallet-ledger, pre-dev-review, 4-lens-review, next-ui-lens, mb-next-payment-gateway, residual-mdr, mdr-clawback, reverse-direction-mdr, signed-add-only, dpay-verify, wallets-change-logs-decoy, prod-data-grounded-decision, walletreview, walletverify, walletfix]
created: 2026-06-07
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# epic-wallet-ledger 4-lens PRE-DEV review + dpay-verify arc — IN PROGRESS as of 2

epic-wallet-ledger 4-lens PRE-DEV review + dpay-verify arc — IN PROGRESS as of 2026-06-07 (orchestrator session). First round to add the NEW 4th lens (next-ui) to the established 3.

REVIEW (campaign walletreview, 4 parallel read-only lenses): next-architect 2H/4M/2L (all ALREADY-RATIFIED doc-faithfulness or within-authority — none need new user decision) · pg-writer 1H/3M/3L (3 MUST-ADD, 4 INTENTIONAL-CUT) · next-writer 3H/5M/7L · next-ui (NEW) 5H/7M/4L (proposes WALLET-007..022). Raw 11H/19M/16L → deduped to 7 themes. Findings preserved ψ/memory/mailbox/{next-architect,pg-writer,next-writer,next-ui}/. Aggregate report /tmp/walletreview/walletreview_AGGREGATE_report.md.

STRONGEST SIGNAL needed NO decision: Theme A — 3/4 lenses independently hit that WALLET-003 omits AND contradicts the already-ratified §ADR-10 §Amd 2026-05-31 Residual-MDR Routing (RM1/RM2/R1: un-creditable share→is_owner residual + mdr_skip cross-ref + conservation invariant). Sibling TOPUP-002 already carries it. Pure doc-faithfulness.

dpay VERIFY (campaign walletverify, brew-ops direct mcp__dpay__*, NOT the flaky dpay-finder subagent; grounded op-strings in mobiz Go first). KEY: live collection is wallets_change_logs (plural, 4,668,270 docs) — a decoy wallet_change_logs (singular, 4 test docs) exists; verify-don't-assume caught it. Findings ψ/memory/mailbox/brew-ops/. Results (as-of 2026-06-07):
- Theme C reverse-direction MDR clawback is LIVE: mdr_distribution_reversed 309× (last 2026-06-06!), mdr_distribution_cancelled 10×, deposit_refund_debit 7× → MUST-PORT (don't assume vestigial — same lesson as payout remediation toolkit).
- Theme D admin manual ops: add 5,353× (live, real CS operators AMPAYCS*, always positive "Payout failed refund" credits), subtract 0, set 0, freeze/unfreeze 1 each → signed-add-only sufficient; set/subtract CAN-CUT.

RATIFIED (user GO 2026-06-07): A apply RM1/RM2/R1; B owner-model=owner_type=partner+is_owner (drop `system` enum); C port-full clawback (payout+topup+deposit-refund) in §ADR-10, architect picks input (snapshot vs reconstruct); D signed-add-only (cut set/subtract/freeze/unfreeze); E wallet read-surface existence amendment (mirror §ADR-13 DL1) + WALLET-001 client available/frozen=Phase-1; F HIGH-5 UI stories WALLET-007..011 (008 dropped-MDR dashboard, 010 adjust action states, 011 audit-trail read), MED/LOW deferred; G quality fixes.

STAGED FIX (next): architect adr.md PR (campaign walletfix, IN FLIGHT) + writer-spec → orchestrator reviews (orchestration-catch) → next-writer epic+INDEX PR (campaign walletfix-epic, DISJOINT files to avoid revision-log shared-anchor cascade). Numbering: grep INDEX.md+revision-log* before minting ids. Warn user on 2-PR merge order. RATIFIED decision detail: /tmp/walletreview/RATIFIED-decisions.md.

REMAINING un-deep-reviewed epics after wallet-ledger: callback-delivery, topup, monitoring, statement-matching, admin-audit, bot-dispatch, fleet-control, entity-provisioning, source-flows, client-api.

---
*Added via Oracle Learn*
