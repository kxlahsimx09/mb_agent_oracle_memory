---
title: mb-next gap-sweep WAVE 2 — FULLY MERGED 2026-06-01: all 6 PRs (#290/#291/#292/#2
tags: [orchestrator, team-dispatch, campaign-complete, mb-next-payment-gateway, gap-sweep, wave-2, pr-290-296, all-merged, merge-cascade, revision-log-shared-anchor, adr-conflict, no-force-push, finish-script-orphan-pane, backlog, repo:arra-oracle-v3, fleet]
created: 2026-06-01
source: orchestrator session 2026-05-31→06-01; campaigns ng2write/ng2arch/ng2dpay/ng2fix/ng2fix2/ng2sync×4
project: github.com/soul-brews-studio/arra-oracle-v3
---

# mb-next gap-sweep WAVE 2 — FULLY MERGED 2026-06-01: all 6 PRs (#290/#291/#292/#2

mb-next gap-sweep WAVE 2 — FULLY MERGED 2026-06-01: all 6 PRs (#290/#291/#292/#294/#295/#296) landed in main (HEAD 9b4cd09). Campaign complete.

Final completion record (updates the 2026-06-01_mb-next-gap-sweep-wave-2-session-close-user resume learning, which had the PRs still awaiting merge). All 6 ratified + readability-passed + merged:
- #290 ADMIN-005 + WALLET-006 + callback egress-IP (writer)
- #291 §ADR-19 deposit QR/fee (GROSS · per-client · snapshot-at-create)
- #292 §ADR-12 §Amendment pullout-CRUD (soft-delete + in-flight BLOCK; step-up SPLIT: execute-now no-stepup / config create+update requires step-up, extends §ADR-2 S2)
- #294 §ADR-15 §Amendment wallet-high-balance alert (P2) + hourly ops-report
- #295 §ADR-10 §Amendment residual-MDR routing (R1: credit is_owner system-residual wallet; ledger balanced; mdr_skip cross-ref)
- #296 §ADR-9 §Amendment callback do-not-follow 3xx (callback_redirect_blocked)

MERGE-CASCADE LEARNING (cost real coordination): the 4 amendment PRs (#292/#294/#295/#296) each appended their revision-log entries to docs/adr.md at the SAME top anchor (right after the 'Ordered newest-first' header). Branched in parallel from one base, they conflicted pairwise the moment the first merged — and RE-conflicted on adr.md after EACH subsequent merge. Resolution took FIVE next-writer re-sync passes (ng2sync, ng2sync2, ng2sync3, ng2sync4) using `git merge origin/main` into each branch + keep-both append resolution + NORMAL push (no rebase/force-push, per CLAUDE.md safety). Each resolution was trivial/mechanical (append-both, no semantic risk) and meaning-locked, but the cascade is structural: N parallel ADR-amendment PRs sharing one revision-log anchor = N-1 re-sync rounds. INDEX.md + the per-epic files did NOT cascade (disjoint regions). Merge order is cosmetic (only orders the revision-log entries) — it does not avoid the cascade.

PROCESS-FIX RECOMMENDATION (open): change the revision-log convention so entries do NOT all insert at one shared top anchor — e.g. append at file bottom, or a per-§ADR sub-section — so a batch of parallel ADR-amendment PRs no longer guarantees an adr.md re-conflict on every merge. Worth a brew-ops/architect process PR.

ORCHESTRATION NOTE: a teammate edit error mid-run (next-architect epic-topup.md Edit error) self-recovered. The team-dispatch-finish.sh orphan-pane bug recurred on EVERY close (8+ campaigns this session: ng2write/ng2dpay/ng2arch/ng2fix/ng2fix2/ng2sync/ng2sync2/ng2sync3/ng2sync4) — orchestrator killed each window manually by NAME (tmux renumbers indices; killing by index risks the unrelated 'next-architect-nextteam'/PR#293 campaign). Handoff filed to brew-ops.

REMAINING BACKLOG (not done; user has NOT GO'd these yet — offer next session):
1. EG1 source-IP propagation: §ADR-9 §Amendment 2026-05-29 EG1 egress-IP allowlist into DEPOSIT-001 / PAYOUT-001 + callback onboarding doc (wave 2 only landed the callback side in #290). Writer pass.
2. husk-dir sweep + team-dispatch-finish.sh orphan-pane fix — brew-ops handoff filed (2026-05-31_19-14).
3. Stale illustrative counts: §ADR-8 '56 banks'→58 (6 capped), §ADR-10 '93 clients'→113 (from dpay ADR-18 re-verify, all entities PASS).
4. revision-log shared-anchor cascade process-fix (above).

KEY USER FEEDBACK this session (already its own learning): requirement-story/AC prose is the WRITER's job, not the architect's — even when the architect authors the ADR. Drove the ng2fix/ng2fix2 readability passes.

---
*Added via Oracle Learn*
