---
title: p2p-hub PRD authored + PR #11 OPEN (campaign #250 full write complete) — awaitin
tags: [next-product-writer, repo:cross, repo:p2p-hub, next, requirement, epic, mermaid, docs-site, p2p-hub, campaign-250, handoff]
created: 2026-05-27
source: https://github.com/kxlahsimx09/p2p-hub/pull/11 ; commit 373f36d ; thread #250 msg 1187
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# p2p-hub PRD authored + PR #11 OPEN (campaign #250 full write complete) — awaitin

p2p-hub PRD authored + PR #11 OPEN (campaign #250 full write complete) — awaiting user review/merge.

https://github.com/kxlahsimx09/p2p-hub/pull/11 — branch next-writer/p2p-hub-prd-250 → main, off fresh origin/main @52ab1d2. Design/docs-only, no merge (user merges per §9), no AI attribution. Commit 373f36d.

DELIVERED: 9 epics + 4 scaffolding in p2p-hub docs/requirements/ = 47 stories + 5 Deferred Surfaces. Epics: protocol-foundations (PROTO-001..008), provider-lifecycle (PROV-001..006), matching (MATCH-001..006), verification (VERIFY-001..004), provider-wallet (WALLET-001..005), billing-fees (BILL-001..005), provider-topup (TOPUP-001..004 +005 deferred), reconciliation (RECON-001..004), dispute-liability (DISPUTE-001..005). Scaffolding: README/INDEX/glossary/cross-repo. All [S2 ratified] (§A–D+§F), Sources cite `new:design §X` (p2p-hub has NO docs/adr.md). §E-only behaviors carry [RATIFICATION_PENDING:206]; per-epic Build-status line; Deferred Surfaces (1:N, transfer-window, TOPUP-005 withdrawal, double_pay_handled, split_settled); ⚖️ NEEDS-LEGAL (Q7 regulatory + §F source_funds_clawback G1). decision (e): docs-site/scripts/sync-content.sh extended to render docs/requirements/ as nested "Requirements" section; check-mermaid.sh extended to cover it.

DURABLE FINDING — p2p-hub (and any fleet) docs-site check-mermaid.mjs gate: it runs `mermaid.parse()` in BARE NODE (no jsdom/DOM). In mermaid 11.15 that env only parses `sequenceDiagram` (and trivial label-less `graph`) cleanly; `stateDiagram-v2` AND `flowchart` (and `graph` WITH edge labels) FAIL with "DOMPurify.addHook is not a function" — an environment artifact, NOT a syntax error, but it fails the gate and would fail the Vercel `prebuild` (which runs the same node gate). RULE for docs authored against this gate: use `sequenceDiagram` for flows, and plain ``` ASCII fences (NOT ```mermaid) for state machines — exactly the design doc's own convention. Verified: 6 mermaid blocks (all sequenceDiagram) PASS after converting 2 stateDiagram-v2 → ASCII. node_modules is NOT pre-installed in the worktree docs-site; `npm install mermaid --no-save` (~mermaid 11.15) is enough to run the gate locally. Companion to [[feedback_mermaid_bare_arrow]] (validate by parsing, not char-grep) — this adds: the parser env itself constrains which diagram TYPES are usable.

ROUTING: prior #249-session flagged-and-deferred #250; orchestrator routed to dedicated session (this one); style-confirmed (sample epic-provider-topup) + decisions b–e locked, then GO. Supersedes the provisional proposal learning learning_2026-05-27_p2p-hub-prd-decomposition-proposed-campaign-250.

---
*Added via Oracle Learn*
