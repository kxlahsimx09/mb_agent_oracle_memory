---
title: **orchestrator pattern — parallel sessions of SAME role, never spawn new role (2
tags: []
created: 2026-05-21
source: parent campaign thread #189 P2P + sub-thread #191 brew-ops cancel — user clarification 2026-05-21 ~16:35 GMT+7 supersedes earlier same-day learning
---

# **orchestrator pattern — parallel sessions of SAME role, never spawn new role (2

**orchestrator pattern — parallel sessions of SAME role, never spawn new role (2026-05-21, corrected)**

Supersedes `learning_2026-05-21_orchestrator-pattern-user-prefers-single-oracl` — that learning conflated "single oracle" with "no parallel sessions". User clarified: parallel sessions are fine; what's NOT fine is creating a new role.

User explicit guidance (2026-05-21 ~16:35 GMT+7 Telegram chat 2002026175):
> "ไม่นะ ผมยังอยากให้มี parallel session แต่ไม่ต้องเพิ่ม oracle ได้ไหม"

## Corrected model

The inbox-watcher already supports **multiple sessions of the same role** running in parallel, in different worktrees. Routing is via `parent_session` field on dispatch envelopes (§151 sticky thread→session ownership):
- Dispatch with `parent_session=wt-A` → routes to next-architect's wt-A session
- Dispatch with `parent_session=wt-B` → routes to next-architect's wt-B session (auto-spawned by watcher if no existing match)
- Both sessions are role `next-architect`, both read from `for-next-architect/` inbox

Evidence from this fleet's tmux state earlier:
- `next-architect-oracle` (the canonical/static window)
- `next-architect-inbox-1778997052` (auto-spawned worker session)
- `next-architect-inbox-1779089397` (another auto-spawned worker)
- Multiple `wt-XX-inbox-XXXXX` worktrees per role

The architect's prior "no parallel architect work" constraint was about **merge-conflict avoidance on shared files** (e.g., docs/adr.md root), NOT about infra capacity. For campaigns touching DIFFERENT files/repos (e.g., P2P in p2p-hub repo vs Cycle 3 in next-system adr.md), parallel sessions are safe.

## Durable rule

**Default decision tree when "campaign X needs role-R, role-R session-1 is busy on Y":**

1. **Check actual merge-conflict surface**: do X and Y touch same files in same repo?
   - **No conflict** (different repos / different files): dispatch X to role-R in parallel. Watcher auto-spawns session-2 for X based on dispatch envelope's `parent_session`. No brew-ops topology change needed.
   - **Yes conflict**: queue serial (or get architect to confirm parallel-safe with explicit coordination)

2. **NEVER spawn new role for parallel work.** "Parallel" = more sessions of SAME role, not a separate role. New role = new inbox dir + new fleet config entry + new watcher state + cleanup overhead. Anti-pattern.

3. **If a new role is genuinely needed** (e.g., different domain expertise like `next-payments-architect` vs `next-security-architect`), surface to user explicitly + rationale. Don't reach for it as parallelism solution.

## How to apply to current pipeline

Right now:
- **#190 P2P §D revise** in flight on next-architect (working in p2p-hub repo)
- **Cycle 2 fan-out** (PRs #210 + #211 next-system) awaiting user merge
- **Cycle 3** (Track A #4+#5 in next-system docs/adr.md) queued

When Cycle 2 PRs merge → Cycle 3 dispatch can fire IN PARALLEL with #190 P2P (different repos, no merge-conflict surface). Watcher auto-spawns separate next-architect session for Cycle 3. Both Cycle 3 + P2P proceed concurrently without any new role / topology change.

## What about brew-ops #191?

Cleanup proceeds correctly — `next-architect-p2p-oracle` was a NEW role attempt, which is the anti-pattern. Removing it returns fleet to baseline 8 roles. This learning reinforces that decision.

## Anti-pattern confirmed

DON'T: dispatch brew-ops to spawn a new role-named oracle for parallelism.
DO: dispatch the new campaign to the existing role; watcher handles session multiplication via `parent_session`.

## Companion lesson

Earlier this session I both (a) over-applied architect-serial constraint (treating it as infra-imposed when it was actually architect-chosen for merge-conflict) AND (b) over-corrected with brew-ops spawn for a new role. Both errors. Correct read: trust the existing multi-session infrastructure; let architect surface merge-conflict concerns per-campaign rather than presuming serial-by-default.</pattern>
<parameter name="concepts">["orchestrator", "decision-authority", "fleet-topology", "parallel-sessions-same-role", "no-new-role-for-parallelism", "watcher-auto-spawn", "parent-session-routing", "merge-conflict-avoidance", "supersedes-prior-learning", "campaign-189", "thread-191"]</parameter>
<parameter name="project">github.com/Soul-Brews-Studio/arra-oracle-v3

---
*Added via Oracle Learn*
