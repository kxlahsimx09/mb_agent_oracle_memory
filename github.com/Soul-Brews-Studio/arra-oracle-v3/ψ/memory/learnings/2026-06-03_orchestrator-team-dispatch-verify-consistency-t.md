---
title: orchestrator team-dispatch — "verify-consistency-then-fix recurring problems" ca
tags: []
created: 2026-06-03
source: orchestrator session 2026-06-03; campaigns depprobe/nextclean/nextverify/nextrev9/nextfixa/nextverify2; PRs #315-#318
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator team-dispatch — "verify-consistency-then-fix recurring problems" ca

orchestrator team-dispatch — "verify-consistency-then-fix recurring problems" campaign (nextteam continuation) ACCEPTED 2026-06-03.

USER REQUEST SHAPE: "continue campaign nextteam → clean up worktrees/panes first → then read last round's retros for recurring problems recommended to fix → fix them → but RUN the verify probes FIRST and confirm they're still consistent (50/50) before/after fixing (must be consistent since no logic changed)." A multi-phase orchestration spanning 6 sequential team-dispatch campaigns, all 2a/2b, user reaction = accepted at every gate.

WHAT WORKED (dispatch-first discipline held throughout, principle 2b): every worktree/pane cleanup, every PR, every probe run was DISPATCHED to the owning role (brew-ops for fleet/infra/stack, next-tester for tests/+probe runs, next-writer for docs/spec) — orchestrator only coordinated, verified premises against live HEAD (Step 2.5), captured findings, reported, and let the OWNER merge (§9, never self-merged). The §3c "verify before discarding" caught a real blocker: the sealed DEPOSIT probe suite (32 files + 23 evidence) was NEVER on main — cleaning the worktrees first would have destroyed the VERIFY evidence; PR'd it (#315) BEFORE cleanup.

PHASE MAP: (1) next-tester PR #315 preserves sealed probe suite→main; (2) owner squash-merge; (3) brew-ops removes 5 safe worktrees, keeps 2 (live next-ui wt-1-ui + unmerged wt-writer-naming), ff's primary main §3c; (4) next-writer investigates stale writer/nextteam-naming-reconcile branch (verdict: re-author not merge — merging would revert #314); (5) brew-ops PROACTIVELY readies tester stack yupsevcrubgprsbujbpu BEFORE the tester run (pre-empts the recurring "agent waits for stack" blocker the user remembered) → STACK READY; (6) next-tester rerun → 50/50 consistent baseline; (7) fan-out fix: next-tester Group-A robustness (A1 AC-5 deterministic stub dropping httpbin / A2 dup_egress→callback_queue ground-truth / A3 SPEED→ADR-20 frozen clock) PRs #317+#318 + next-writer rev-9 doc PR #316 (F-1 error-envelope + F-2 qr_type camelCase, closing a SPEC↔merged-test drift); (8) owner merges all 3; (9) final rerun on post-fix main fe3065c → 50/50 GREEN, assertion-set byte-identical to sealed baseline, 0 flips. AC-5 now greens deterministically (200/404 via own-stack mock-merchant) vs seal-time 204/503-httpbin-flake.

KEY ROUTING LESSON: when the user says "fix the recurring problems but the rerun must stay consistent," that bifurcates the fix backlog into (A) test/CI-robustness fixes = NO product-logic change = rerun stays 50/50 (dispatch now) vs (B) functional/feature fixes = behavior changes = rerun would NOT be consistent (defer, needs new baseline). Surfacing this A/B split to the user before dispatch is what made the scope decision clean.

tags: [orchestrator, team-dispatch, decision-authority, 2b-fan-out, accepted, verify-consistency, recurring-problem-fix, nextteam, mb-next-payment-gateway, deposit-slice, ac5-determinism, spec-test-drift, dispatch-first, verify-premise-head, preserve-before-cleanup, robustness-vs-functional-split, repo:arra-oracle-v3, fleet]

---
*Added via Oracle Learn*
