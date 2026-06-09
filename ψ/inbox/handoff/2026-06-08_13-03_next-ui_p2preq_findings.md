---
to: orchestrator / next session
from: next-ui (campaign p2preq)
priority: P1
topic: epic-p2p-matching-ui.md authored + committed (P2P UI requirement, P2P-UI-001..007) — S3 provisional, owner-GO pending
project: github.com/kxlahsimx09/mb-next-payment-gateway
tags: [next-ui, p2preq, p2p-matching, ui, adr-17, s3-provisional, ratification-pending, epic]
---

# next-ui — campaign p2preq — P2P UI requirement epic COMPLETE

**Deliverable:** `docs/requirements/epic-p2p-matching-ui.md` (238 lines, ≤250). The UI **product-requirement** epic for §ADR-17 P2P matching — depositor, withdrawer, operator surfaces.

**Branch:** `campaign/p2preq` · **Commit:** `20b14ad` (AFTER next-writer's backend epic `f3bda26`/`9cd3cf5`, per writer→ui serialization) · **PR #354** (writer's PR, same branch; commented to flag the UI addition) — base `main`, OPEN, **NOT merged** (owner ratifies §ADR-17 + merges).

## Status: S3 `#provisional` `[RATIFICATION_PENDING:p2preq]` — flips to S2 on owner GO. NOT self-ratified.

## Layer boundary
- THIS = the requirement (what the user sees + why), P2P-UI-00x stories. House style of epic-deposit/epic-payout.
- NOT the design contract — `docs/design/p2p-matching/ui/` (PR #351, branch campaign/p2pdesign, unmerged). Cross-ref only.
- NOT the backend epic — next-writer's `epic-p2p-matching.md` (P2P-001..010). Each UI story anchors to its backend P2P-00x story.

## Stories (7 + 3 deferred)
- P2P-UI-001 p2p-wallet view (P2P-010; PM2/PM3) · P2P-UI-002 opt into P2P route + grid-50 deposit (P2P-001/003; PM5/DP9) · P2P-UI-003 direct-transfer instruction NO QR + proof (P2P-001/004; PM1/PM8/PM10) · P2P-UI-004 lifecycle + countdown + Thunder verdict (P2P-005/009; DP4/DP3) · P2P-UI-005 withdrawal request + freeze + large→payout (P2P-002/007; PM8/DP10a/PM12) · P2P-UI-006 progressive-fill + SLA → settle/expire-unfreeze (P2P-003/006; DP0/DP5/DP6) · P2P-UI-007 operator matching dashboard incl 50-baht health metric (P2P-003/005/006/007; DP1/DP2/DP9/DP10/DP4).
- Deferred: D1 truncate-resubmit (pure-P2P, DP11b), D2 dispute (DP4 notify-only), D3 partial/N:1·M:N (PM7/PM12).

## Also committed (in the same commit)
- INDEX.md — "P2P Matching — UI" section appended AFTER the writer's "P2P Matching" section.
- glossary.md — `p2p depositor` + `p2p withdrawer` role terms (writer added the structural p2p terms; I added the two UI roles my epic links to).

## impeccable
Applied its principles (not the code-gen flow — docs-only repo, no PRODUCT.md): WCAG-1.4.1 status-never-colour-only, verb+object buttons, no em dashes in microcopy, designed empty states, honest over/underpay + LOCK-reversible copy, admin dashboard avoids hero-metric/card-grid clichés.

## Out-of-scope (bounced to team-lead): the ADR (#333), the design pass (PR #351), the backend epic, ratifying.
Findings file: `next-ui_p2preq_findings.md` (repo root).
