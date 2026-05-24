---
title: p2p-hub PRIMARY checkout parked on a feature branch — possible §3c freshness-anc
tags: [drift, fleet, p2p-hub, primary-checkout, freshness-anchor, §3c, worktree, git]
created: 2026-05-23
source: orchestrator close-out, thread #222
project: github.com/soul-brews-studio/arra-oracle-v3
---

# p2p-hub PRIMARY checkout parked on a feature branch — possible §3c freshness-anc

p2p-hub PRIMARY checkout parked on a feature branch — possible §3c freshness-anchor drift (flagged, not auto-fixed).

**Observed 2026-05-23** (thread #222 fleet mass-purge close-out, verified by orchestrator wt-21): `/Users/dev01/Code/github.com/kxlahsimx09/p2p-hub` (the primary checkout) is on branch `architect/phase-c-opt-in-protocol`, **0 ahead / 10 behind `origin/main`** (HEAD 8aa2879 vs origin/main 6f7517e), working tree clean and pushed to its own upstream. So there is **no unmerged work at risk** — it is purely the "primary parked on a feature branch" case.

**Why it matters (§3c sibling discipline):** a primary checkout's local `main` ref is the freshness anchor every maw-spawned worktree inherits. When the primary parks on a non-default branch, local `main` freezes wherever it was last pulled, and fresh spawns can branch off a stale base (the §199 stale-base trap; precedent: mb-next primary frozen at a24175c for 8 days). p2p-hub is **not** in §3c's explicit runtime table (which lists arra-oracle-v3 + maw-js as runtimes, and mb-next-payment-gateway as the sibling that "stays on main"), so this is a *possible* extension of the freshness-anchor concern, not a confirmed binding violation.

**Not auto-resolved:** External Brain, Not Commander — did not switch a primary's branch without confirming the parking is unintentional (someone may be actively working `architect/phase-c-opt-in-protocol`). Surfaced to the user for a decision. Fix if unintended: `git -C <p2p-hub> switch main && git merge --ff-only origin/main` (and consider adding p2p-hub to the §3c sibling-discipline paragraph if it should be a freshness anchor).

#drift #fleet #repo:cross #brew-ops

---
*Added via Oracle Learn*
