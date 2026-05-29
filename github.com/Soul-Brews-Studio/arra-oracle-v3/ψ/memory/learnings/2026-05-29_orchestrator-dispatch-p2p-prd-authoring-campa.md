---
title: **orchestrator dispatch — P2P PRD authoring (campaign #250) closed; PR #11 merge
tags: [orchestrator, decision-authority, 2a-single-agent-doc-authoring, accepted, p2p-hub, prd, campaign-250, propose-then-proceed, mb-next-style, ratified, user-style-confirm, writer-recommendations-followed, phase-2-deferred, needs-legal-G1, mermaid-gate-bare-node-limitation, 214-fix-verified, repo:p2p-hub, repo:cross, fleet]
created: 2026-05-29
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **orchestrator dispatch — P2P PRD authoring (campaign #250) closed; PR #11 merge

**orchestrator dispatch — P2P PRD authoring (campaign #250) closed; PR #11 merged (2026-05-27)**

Request (user, 2026-05-27 GMT+7, orchestrator wt-22): now that the p2p-hub design doc carries §F, translate Phases A–F into a product-requirement doc written the SAME way as `mb-next-payment-gateway/docs/requirements/` (epic format — requirement IDs, AC, ADR/design cross-refs, plain-English, MDX/sync, ≤250-line files).

Classification: 2a single-agent doc-authoring, propose-then-proceed. Confidence: HIGH (clear analogous precedent in mb-next). User reaction: **accepted** with style-confirm + 5 small decisions (b–e all per writer's recommendation, plus (e) un-rec'd → orchestrator default = extend sync-content.sh to render requirements, matching "same as mb-next" intent; user OK'd).

Cadence executed: writer's PROPOSE step (9-epic decomposition + un-prefixed ID scheme + provenance model + full sample `epic-provider-topup.md`) → user style-confirm + decisions (b)–(e) → FULL write → ONE docs PR → user merge.

Outcome: **p2p-hub PR #11 MERGED 2026-05-27T12:05Z** — 47 stories across 9 epics (PROTO/PROV/MATCH/VERIFY/WALLET/BILL/TOPUP/RECON/DISPUTE) + 4 scaffolding (README/INDEX/glossary/cross-repo) + 5 Deferred Surfaces (1:N / transfer-window / TOPUP-005 withdrawal / double_pay_handled / split_settled). `docs-site/sync-content.sh` extended (6 mermaid blocks pass parser gate); 2 state-machine diagrams use ASCII fences because the bare-node mermaid gate only parses `sequenceDiagram` cleanly (stateDiagram-v2/flowchart fail on DOMPurify env dep). `epic-protocol-foundations.md` = 269 lines (marginally over ≤250 target; kept as one cross-cutting epic; user accepted).

Provenance discipline applied uniformly across all epics — `[S2 ratified]` cites `new:design §X` (p2p-hub has no docs/adr.md — the phased design doc IS the decision source); `[RATIFICATION_PENDING:206]` per-story wherever a behavior leans on the un-ratified §E 1A slice; per-epic Build-status line distinguishes ratified-design / built (PR #7) / §E-pending / deferred-from-1A / Phase-2-deferred; ⚖️ NEEDS-LEGAL (Q7 regulatory + §F clawback) surfaced as open questions, never as settled requirements.

Routing-flag incident (resolved): a next-writer session woken for sibling campaign #249 saw my #250 envelope and correctly campaign-scoped-and-flagged (§214 discipline working). But the DEDICATED #250 session (wt-16-inbox-1779874068) had already picked it up and was delivering the propose step before the flag landed — flag was a stale racing observation, moot, archived.

Routing-bug fix verification: PR #108/#109 on kxlahsimx09/arra-oracle-v3 fork (merged earlier 2026-05-27) DID fix the §214 reply-routing → no circuit-breaker trips on any #250 reply (confirmed empirically; pre-fix #232 replies tripped it).

Decision-authority signals (P2P doc-authoring, this user):
- User confirms style on a SAMPLE before committing to a full write — propose-then-proceed is the right cadence for a large translation task.
- User defers to the writer's recommendations on structural choices (id scheme, fold-or-split) — trusts the agent's judgment on style/structure within the established mb-next pattern.
- When orchestrator picks a sensible default for an un-rec'd minor decision and labels it explicitly, the user accepts (the (e) doc-site sync extension).

Side-finding (filed): the docs-site bare-node mermaid gate (Vercel prebuild parity) only parses `sequenceDiagram` — `stateDiagram-v2`/`flowchart` fail on a DOMPurify env dependency. Worth fixing upstream if more state-machine diagrams are wanted; the current ASCII workaround is fine.

P2P project state post-#250: design doc Phases A–F + PRD `docs/requirements/` complete on p2p-hub main. Open menu unchanged: G1 legal · thunder-API · B8.7 vetting · ⟦S1⟧–⟦S6⟧ build · parked §E impl (PR #8 spec, migrations 006–009 unbuilt, #206 open) · Phase-2 reserved.

Closed at user request alongside fleet cleanup dispatch (#255 → brew-ops): retire agent worktrees + watcher session-id files under campaigns #231/#250/#251.

---
*Added via Oracle Learn*
