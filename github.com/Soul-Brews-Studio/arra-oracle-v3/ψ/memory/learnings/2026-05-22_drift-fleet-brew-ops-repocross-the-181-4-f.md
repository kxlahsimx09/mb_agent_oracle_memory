---
title: #drift #fleet #brew-ops #repo:cross — The #181 4-FIX bundle was merged to the fo
tags: [drift, fleet, brew-ops, repo:cross, runtime-checkout, merge-then-pull, deploy-gap]
created: 2026-05-22
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# #drift #fleet #brew-ops #repo:cross — The #181 4-FIX bundle was merged to the fo

#drift #fleet #brew-ops #repo:cross — The #181 4-FIX bundle was merged to the fork but never deployed to the runtime primaries (thread #204, 2026-05-22).

ROOT CAUSE: §3c.2 prescribes "new code lands by merge-then-pull" — merge to fork/feat/all-prs-rebased, THEN ff the primary checkout (git fetch + git merge --ff-only) + restart any bash daemon (§3c.4). On 2026-05-21 both 4-FIX fork PRs merged (maw-js#8 commit 2c36d3a1 "ff local default on createWorktree"; arra-oracle-v3#85 commit 19a3900 "inbox-watcher Path-1 pre-resume fetch"), but the merge-then-pull step never ran. Result on 2026-05-22:
- arra-oracle-v3 primary @ 9a1aae6 was 2 commits behind fork/feat/all-prs-rebased — the live inbox-watcher daemon had NO FIX-4 pre-resume fetch.
- maw-js primary @ 5a209f22 was 2 commits behind — had b8fa9ca5 (branch new wt off origin/HEAD) but NOT 2c36d3a1 (the update-ref ff of local default).
So the drift-prevention the 4-FIX bundle was meant to provide was itself sitting un-deployed — a meta-instance of the exact "integration branch ≠ running checkout" class §3c exists to catch. Both primaries were clean + strictly-behind (ff-only safe).

MECHANISM CORRECTION (for the §3c/§3d doctrine): FIX-1 and FIX-4 both move only refs/heads/<default> (via git update-ref refs/heads/<default> refs/remotes/origin/<default>); FIX-1 additionally branches fresh wts off origin/HEAD. NEITHER ever runs `git switch` on a primary's working-tree HEAD. So a primary parked on a stale feature branch is never auto-corrected by spawn/resume — confirming thread #204's residual-gap framing (the mb-next 9-day dark-theme park).

PATTERN: after merging any fork PR that changes runtime code (inbox-watcher.sh, maw-js src), the merge-then-pull is NOT optional cleanup — it is the deploy. Verify with: git -C <primary> rev-list --count HEAD..fork/feat/all-prs-rebased (must be 0). A nonzero count means the runtime is executing pre-fix code regardless of what the integration branch says. Recommended recurrence-prevention: alert-only fleet-health check (P-003: surface, don't auto-command), not auto-switch.

---
*Added via Oracle Learn*
