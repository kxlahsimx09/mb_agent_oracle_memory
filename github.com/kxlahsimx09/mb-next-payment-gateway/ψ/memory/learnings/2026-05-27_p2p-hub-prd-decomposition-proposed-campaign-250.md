---
title: p2p-hub PRD decomposition proposed (campaign #250, propose-then-proceed PROPOSE 
tags: [next-product-writer, repo:cross, repo:p2p-hub, next, requirement, epic, provisional, p2p-hub, campaign-250, propose-then-proceed]
created: 2026-05-27
source: thread #250 msg 1181; docs/design/p2p-hub-design-exploration.md @origin/main 52ab1d2
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# p2p-hub PRD decomposition proposed (campaign #250, propose-then-proceed PROPOSE 

p2p-hub PRD decomposition proposed (campaign #250, propose-then-proceed PROPOSE step) — awaiting user style-confirm before full write.

Task: translate kxlahsimx09/p2p-hub docs/design/p2p-hub-design-exploration.md (Phases A–F, §F merged PR #10) into a product-requirement doc mirroring mb-next-payment-gateway docs/requirements/ conventions. Single-agent campaign → next-writer. Replied in thread #250 (msg 1181) + envelope to for-orchestrator (2026-05-27_16-46_..._propose-reply.md).

PROPOSED (NOT yet ratified):
- 9 epics + 4 scaffolding files, one file each, ≤250 lines: epic-protocol-foundations (§C2 PI-1..7 + §C12), epic-provider-lifecycle (§C3/§C4/§E2 + KYC/AML), epic-matching (§A8/§C5/§C6/§C9 + §E3/E5), epic-verification (§C8, ⟦S4⟧), epic-provider-wallet (§D1–D4/D6/D7/D8 settle+L2+penalty), epic-billing-fees (§A5/§C1/§C7 + §E6/E8), epic-provider-topup (§D5 mobiz-port + §D10 Q-D5), epic-reconciliation (§C10), epic-dispute-liability (§F + retained §C11 grounding). Scaffolding: README/INDEX/glossary/cross-repo.
- ID scheme = mb-next EPIC-NNN: PROTO-/PROV-/MATCH-/VERIFY-/WALLET-/BILL-/TOPUP-/RECON-/DISPUTE-.
- Provenance model: S2 = §A–D+§F ratified #decision; S3 [RATIFICATION_PENDING:206] = §E-only behaviors (1A match-formation/reserve-release substrate, not built, no migrations 006–009); per-epic Build-status line (ratified-design / built-substrate PR#7 / §E-pending / deferred-from-1A / Phase-2-deferred); Phase-2 items in "Deferred Surfaces" sub-sections; NEEDS-LEGAL (Q7 regulatory, §F source_funds_clawback G1) flagged not settled.
- KEY: p2p-hub has NO docs/adr.md — the phased design-exploration doc IS the ratified-decision source; Sources blocks cite `new:design §X — docs/design/p2p-hub-design-exploration.md` where mb-next cites `new:adr §ADR-N`.
- Sample epic authored full inline: epic-provider-topup (tightest analog to mb-next epic-topup; ports mobiz controllers/TopupController.go @55abbea; S2; TOPUP-005 withdrawal deferred Phase-2).
- docs-site gotcha: p2p-hub docs-site/scripts/sync-content.sh mirrors ONLY docs/design/ — rendering the PRD needs a 1-line sync extension (surfaced as a user decision, not done).

5 open decisions for user (thread #250 §5): style-confirm; un-prefixed ids vs HUB- namespace (rec un-prefixed); billing separate vs folded-into-wallet (rec separate); reconciliation separate vs folded-into-protocol-foundations (rec separate); doc-site render-requirements vs design-only.

Routing: prior #249-dispatched next-writer session flagged-and-deferred #250 (routing-flag envelope 16:36); orchestrator routed to a dedicated session (this one). No collision.

NEXT: on user style-confirm + orchestrator GO → author all 9 epics + 4 scaffolding files → ONE docs PR off fresh origin/main p2p-hub (NO merge). Ground on origin/main not local (clone was 3 behind @52ab1d2). p2p-hub is NOT a registered Oracle project — file p2p-hub learnings under mb-next home base + #repo:cross #repo:p2p-hub.

---
*Added via Oracle Learn*
