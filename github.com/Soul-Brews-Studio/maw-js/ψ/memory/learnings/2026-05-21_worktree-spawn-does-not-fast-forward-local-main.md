---
title: **Worktree spawn does NOT fast-forward local `main` ref — stale-base trap.**
tags: [fleet, worktree, git, maw-wake, state-grounding, drift, brew-ops, createWorktree, stale-base]
created: 2026-05-21
source: brew-ops investigation, thread #199 (parent #181)
project: github.com/soul-brews-studio/maw-js
---

# **Worktree spawn does NOT fast-forward local `main` ref — stale-base trap.**

**Worktree spawn does NOT fast-forward local `main` ref — stale-base trap.**

`maw-js` `createWorktree` (`src/commands/shared/wake-session.ts` line 145-148) does `git fetch origin --quiet` then `git worktree add ... -b <branch> <origin/HEAD>`. That updates `refs/remotes/origin/main` and creates the new `agents/<N>-…` branch off **current** `origin/main`. ✅

What it does NOT do: fast-forward `refs/heads/main` (the LOCAL main ref). The local `main` ref only moves when someone does `git checkout main && git pull` in the primary checkout (or any worktree). If the primary is parked on a feature branch and never pulls main, the local `main` ref freezes.

**Consequence:** an agent that types `git checkout main && git checkout -b new-work` inside a maw-spawned wt branches off the FROZEN local `main`, not current `origin/main`. PR opens against a base that's days behind reality. Caught only at downstream `git merge-base pr-head origin/main` mismatch.

**Reproduced 2026-05-21 (thread #199 / parent #181, incident #3 — writer PR #215):**
- wt-48 (next-writer for #197) local `main` = `a24175c` (Merge PR #188, stale)
- wt-48 `origin/main` = `52a4530` (Merge PR #217, current; 6+ commits ahead)
- primary `mb-next-payment-gateway` local `main` = `a24175c` (matches wt; primary parked on `poc-implement/admin-web-dark-theme-2026-05-13` since 2026-05-13, never pulls main)

**Defensive fixes (preferred order):**

1. **Infra fix in `createWorktree`** — after `git fetch origin --quiet`, also `git update-ref refs/heads/<default> refs/remotes/origin/<default>`. Safe because maw-spawned wts never check out the default branch (they always branch off it into `agents/<N>-…`). If the primary HAS the default branch checked out, `update-ref` fails loudly — correct signal that primary discipline regressed.

2. **§3c-sibling primary discipline** — `mb-next-payment-gateway` primary stays on `main` (matching `arra-oracle-v3` + `maw-js` primaries' §3c rule, which keeps them on `feat/all-prs-rebased`). Today's incident is fixable by the infra fix alone, but primaries-on-stale-feature-branch is a separate hygiene issue.

3. **Agent SKILL.md branching boilerplate** — use `git fetch origin && git switch -c new-branch origin/main` instead of `git checkout main && git checkout -b new-branch`. Defense-in-depth for offline (fetch silently swallowed) + Path 1 resume cases (`inbox-watcher.sh` `fire_wake` Path 1 lines 656-679 resumes prior wts with zero re-fetch — latent gap, separate from this incident's root cause).

**Tagging:** `#repo:maw-js` `#repo:cross` `#fleet` `#worktree` `#git` `#state-grounding` `#drift` `#gotcha` `#brew-ops`

**Related learnings:**
- [[state-grounding-cite-by-line]] — runtime complement (cite by line + commit hash when disagreeing on substrate)
- [[poc-load-bearing-realism]] — substrate facts vs spec text
- [[amendment-check-enum-migration-chain]] — drafting-side companion (wrong-source-anchor class, NOT this stale-main class — incident #1 of campaign #181 is in that class, not this one)
- [[spec-self-contradiction-impl-discretion]] — drafting-side spec internal contradiction (campaign #181 incident #2)
- Pending writer-side: `feedback_writer_stale_base_main_drift.md` (writer dispatched 2026-05-21 ~21:10 GMT+7, in flight at time of this learning)

**Why this matters (frequency-of-occurrence):** orchestrator at 2026-05-21 21:15 flagged 3 state-grounding incidents in same campaign #181 exceeds coincidence — asked brew-ops to diagnose at fleet/infra layer. Diagnosis: 3 incidents are NOT one pattern. Two are agent-side discipline (already addressed by filed feedback rules); ONE (incident #3, this one) is a real fleet-infra bug. Without the infra fix, every long-lived primary on a non-main branch + every agent that types `git checkout main` is at risk.

---
*Added via Oracle Learn*
