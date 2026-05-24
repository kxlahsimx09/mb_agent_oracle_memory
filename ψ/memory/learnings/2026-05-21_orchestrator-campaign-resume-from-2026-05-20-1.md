---
title: **orchestrator campaign — resume from 2026-05-20 18:08 wrap retro CLOSED (parent
tags: []
created: 2026-05-21
source: parent thread #181 resume-from-retro campaign (2026-05-20 19:30 → 2026-05-21 22:30 GMT+7; 18 PRs + 2 direct commits + 5 durable learnings + 1 fleet infra bug class permanently closed)
---

# **orchestrator campaign — resume from 2026-05-20 18:08 wrap retro CLOSED (parent

**orchestrator campaign — resume from 2026-05-20 18:08 wrap retro CLOSED (parent #181, 2026-05-21)**

Request: user invoked "continue from the 18:08 wrap retro on 2026-05-20" at 2026-05-20 ~19:30 GMT+7. Retro had 3 explicit deferrals (Track A 5-mobiz-amendments / Track B V15-2 status enum / Track C mobiz issue filing). Campaign expanded mid-flight to include #189 P2P provider-wallet amendment + #199 fleet state-grounding investigation + 4-FIX infra hardening.

Classification: **2d-escalate-before-dispatch** (multiple equally valid decompositions; user ratified per-track sequence).
Confidence at dispatch: **MEDIUM** initially; grew to **HIGH** after Track A Cycle 1 successful pattern.

## Final outcome

**18 PRs merged + 2 direct commits across 5 repos in ~26 hours of campaign elapsed time** (2026-05-20 19:30 → 2026-05-21 22:30 GMT+7):

| Track | PRs |
|---|---|
| Track A Cycle 1 V13+V14 | #201 + #202 + #203 |
| Track A Cycle 2 V1+V2 audit-uniformity | #208 + #209 backfill + #210 + #211 |
| Track A Cycle 3 V3+§AU-1 | #214 + #215 (after rebase) + #216 + #217 substrate-correction |
| Track B canonical 'review' | #204 + #205 + #206 + #207 substrate-correction |
| Track C mobiz issue | user-handled (filed learning) |
| #189 P2P provider-wallet stake-before-match settlement | p2p-hub#6 + p2p-hub#7 + mb-next#212 + mb-next#213 backfill |
| #191 brew-ops cancel cleanup (anti-pattern cleared) | orchestrator-executed cleanup, no PR |
| **#199 4-FIX infra hardening** | maw-js#8 + arra-oracle-v3#85 + mb_agent_oracle_memory#7aa241a (direct §3a) + mb-next primary ff'd |

User reactions: **accepted** with substantive mid-stream redirects (e.g., single-wallet collapse on §D, mobiz-port topup, single-oracle-per-role rule).

## Cumulative business impact

7,749.30 THB confirmed mobiz fraud forensic axis (12 deposits, 9 fraudulent credits, Apr 27 – May 13 window) → CLOSED in next-system across:
- 6-member cascade (V2 → V13 → V14 → V3 → V1.5 → V1) at admin-approve, all with canonical §ADR-13 D2 `audit_log` rows + cross-link FK on completed-approve row
- §AU-1 admin-uploader explicit-override policy at ingress (closes silent-bypass class)
- §V1.5 transRef-check at admin-approve (slip-reuse layer)
- 7-FK forensic-recovery contract (6 cascade + 1 orthogonal admin-upload)

Plus: P2P provider-wallet stake-before-match settlement design ratified + substrate bootstrapped on p2p-hub side (next-system adapter ADR deferred until integration scheduled). Cross-lane canonical 'review' name uniformity (Track B). Fleet infra hardening (4 FIXes) eliminating stale-base-on-spawn bug class.

## 5 substantive durable learnings filed across the campaign

### Learning 1 — `_universal/...track-b-canonical-review-...` (Track B closure)
Documented Track B 4-PR closure + 3 same-day state-grounding incidents (Track B + Cycle 3 spec contradiction + PR #215 stale-base) before brew-ops investigation. Reframed parallel-sessions-same-role pattern.

### Learning 2 — `_universal/...parallel-sessions-of-same-role-no-new-role` (corrected mid-campaign)
Supersedes earlier conflated learning. Watcher already supports multi-session same-role via `parent_session` routing. Spawning new role (`next-architect-p2p-oracle`) = anti-pattern. brew-ops #191 dispatched then cancelled illustrates this. Single-oracle-per-role + multi-session-via-watcher is the model.

### Learning 3 — `feedback_amendment_check_enum_migration_chain.md` (architect-filed, Track B)
Drafting-side rule for architect: grep `<table>_<column>_check` across all migrations and reconcile against latest before specifying CHECK enum value-counts. Closes "stale schema view" drafting-bug class. Reused successfully on Cycle 2 + Cycle 3.

### Learning 4 — `feedback_spec_self_contradiction_impl_discretion.md` (architect-filed, Cycle 3)
Drafting-side rule for architect: cross-pass constraint-summary bullets vs handoff bullets at draft time. If handoff delegates "discretion on shape", soften the summary's hard-no — not the handoff. 2 same-day instances (Track B §CR2/§CR3 + Cycle 3 §V3+AU-1-9) reinforced.

### Learning 5 — `feedback_writer_stale_base_main_drift.md` (writer-filed, Cycle 3)
Writer-side rule: `git fetch origin && git log origin/main -1 <file>` BEFORE drafting. `git status "up to date"` ≠ real-time origin. Writer-side stale-base instance #1. Companion to architect learning #3.

## #199 brew-ops root-cause investigation outcome

3 incidents analyzed:
- **Incident #1 Track B §CR2/§CR3** — wrong-anchor (architect-side; already addressed by learning #3)
- **Incident #2 §V3+AU-1-9** — drafting-side (architect-side; already addressed by learning #4)
- **Incident #3 PR #215 stale-base** — **REAL fleet-infra bug** in maw-js createWorktree: fetches + branches off origin/HEAD correctly but never fast-forwards LOCAL `main` ref. Triggers when primary parked on non-main branch for extended period (8 days in this case).

4-FIX bundle landed in ~50 min:
- **FIX 1** — `maw-js createWorktree` adds `git update-ref refs/heads/main refs/remotes/origin/main` after fetch (PR #8)
- **FIX 2** — mb-next-payment-gateway primary fast-forwarded + AGENTS.md §3c-sibling note (direct + doc)
- **FIX 3** — architect/writer/impl/orchestrator SKILL.md branching boilerplate `git fetch origin && git switch -c new origin/main` (vault commit 7aa241a per §3a single-author)
- **FIX 4** — `inbox-watcher.sh fire_wake` Path 1 pre-resume fetch + local-default fast-forward (PR #85)

Defense-in-depth: all 4 fixes work together. Bug class closed in 4 ways simultaneously.

## Reusable orchestrator patterns observed this campaign

- **2b-fan-out cycle cadence** (architect draft → user ratify → architect marker-flip → user merge → impl + writer parallel) executed cleanly across 5 cycles + P2P
- **§H3-Fix bundled-inline-correction** at 3 pattern instances by end (Track B §CR2/§CR3 + Cycle 3 §V3+AU-1-9 + post-PR-#212 backfill)
- **Merge-as-draft → backfill marker-flip** at 2 instances (PR #208 → #209; PR #212 → #213)
- **Single-branch marker-flip** preferred for V13+V14/Track B/Cycle 3-architect when architect pushes flip BEFORE user merges (pattern instance #5 by end)
- **Cross-repo parallel campaigns** via different worktrees (P2P p2p-hub + Cycle 3 next-system in parallel sessions of same `next-architect` role)
- **brew-ops dispatch SLA observation**: fleet-ops topology changes consistently slower than fix dispatches (~1.5h for 4-FIX bundle was acceptable; #191 spawn anti-pattern was ~2h with no progress = cancelled correctly)

## Process gotchas + recovery patterns

1. **Worktree gc'd mid-session** — happened to me (orchestrator wt-3-20260520-191052 gc'd during 4-FIX deployment). Session continued operational via absolute paths. PR #83 `claude_present_at` gate apparently not catching all cases (or interaction with new FIX 4 + bot-restart timing). Worth surfacing post-campaign as follow-up.
2. **Hook-target mirror with `_notify.md` suffix didn't match hook glob** — hook requires `_reply.md` suffix specifically. Resolved by always using `_reply.md` for hook mirrors regardless of original outbound type.
3. **Watcher restart race** — `stop` reports stopped but doesn't truly kill before `start` complains "already running". Force-kill required. Could be infra hardening follow-up.

## Decision-authority pattern library tags

- 2d-escalate-before-dispatch (initial #181 dispatch) — accepted
- 2a-trivial-direct (Cycle 1 V13+V14, Cycle 2 V1+V2 audit-uniformity) — accepted
- 2b-fan-out (each cycle + P2P + Track B) — accepted with mid-stream redirects
- Track C user-handled close-out — accepted as user-preference for pre-delivered packs

## Closure

Parent #181 closed end-to-end. All declared scope shipped. 5 durable learnings + 18 PRs + 7,749 THB forensic axis + 1 fleet infra bug class permanently closed. ~26h elapsed (overnight + most of 2026-05-21).</pattern>
<parameter name="concepts">["orchestrator", "decision-authority", "campaign-181-closure", "resume-from-retro", "track-a-5-amendment-queue-complete", "track-b-canonical-review", "track-c-user-handled", "campaign-189-p2p-provider-wallet", "campaign-191-spawn-cancel-anti-pattern", "campaign-199-state-grounding-fix-bundle", "4-fix-fleet-infra-hardening", "stale-base-on-spawn-bug-closed", "h3-fix-3-instances", "merge-as-draft-backfill-2-instances", "single-branch-marker-flip-5-instances", "parallel-sessions-same-role", "no-new-role-anti-pattern", "cross-repo-parallel-campaigns", "brew-ops-sla-observation", "worktree-gc-mid-session-recovery"]</parameter>
<parameter name="project">github.com/Soul-Brews-Studio/arra-oracle-v3

---
*Added via Oracle Learn*
