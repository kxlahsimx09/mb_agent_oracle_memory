---
title: Gotcha — inbox-watcher gc: shared-worktree retire gate deadlocks multi-envelope 
tags: [gotcha, inbox-watcher, gc, worktree, fleet, campaign-session, 11f, brew-ops, thread-172]
created: 2026-05-19
source: thread #172 — brew-ops session-close worktree hygiene audit; fix PR #82
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Gotcha — inbox-watcher gc: shared-worktree retire gate deadlocks multi-envelope 

Gotcha — inbox-watcher gc: shared-worktree retire gate deadlocks multi-envelope campaigns (fixed PR #82) 2026-05-19

The 4th distinct gc defect found this session (after #79 retire-path, #80 terminal-failure, #81 orphaned-`fired`). The `safe_to_retire` gate `other_state_references_wt` (logged as `wt-shared-by-other-envelope`) matched ANY sibling state file referencing the same `wt_path`, regardless of that sibling's status.

§11f/§11k campaign-session reuse deliberately parks every sub-thread envelope of one campaign on a single shared `wt_path` (one session per oracle per campaign). Once the campaign closes, every envelope on that shared wt is in a terminal state — and each one cites the others as `wt-shared-by-other-envelope`. Mutual-blocking deadlock: none can retire because each sees the others, so the shared worktree leaks forever. The function's own doc comment said "any other ACTIVE state file" — the implementation just never filtered by status.

Symptom: multi-envelope campaigns' worktrees leak after the campaign closes; single-envelope campaigns retire fine (one state file → gate trivially passes). Observed: 7 mb-next worktrees (wt-29..36, the multi-dispatch campaigns) stale-leaked; wt-38 (single-envelope) retired cleanly the same day.

Fix: fork PR kxlahsimx09/arra-oracle-v3 #82 (base feat/all-prs-rebased, pending merge) — `other_state_references_wt` now counts only NON-terminal siblings (`fired`/`verified`/`deferred`/`delivered_to_owner`); terminal siblings no longer block. The campaign's spawning (non-owner-routed) envelope retires the shared wt; the active-sibling guard is preserved. +2 regression tests. Post-merge: §3c deploy (ff primary + restart inbox-watcher).

Session note: the inbox-watcher accumulated FIVE latent defects discoverable only by auditing effects, not liveness — §11d loop-closure hook (#78), gc retire-path (#79), gc terminal-failure (#80), orphaned-`fired` (#81), gc shared-wt deadlock (#82). A daemon ticking on schedule with sound-looking gate logic can still have a 100%-silent-failure core action. Tags: #gotcha #inbox-watcher #gc #fleet #campaign-session #11f

---
*Added via Oracle Learn*
