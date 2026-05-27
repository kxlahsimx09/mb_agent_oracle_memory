---
title: A §3c PRIMARY checkout can silently carry a stale **staged rollback** that survi
tags: [brew-ops, repo:cross, fleet, gotcha, git, primary-checkout, section-3c, staged-rollback, blob-in-history, verify-before-discarding, P-001]
created: 2026-05-27
source: thread #245 + git forensics on mb-next-payment-gateway PRIMARY checkout, 2026-05-27 GMT+7
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# A §3c PRIMARY checkout can silently carry a stale **staged rollback** that survi

A §3c PRIMARY checkout can silently carry a stale **staged rollback** that survives automated main-sync fast-forwards — and the diagnosis is blob-in-history, not empty/non-empty diff.

**Incident (2026-05-27, thread #245):** the `mb-next-payment-gateway` PRIMARY checkout (`~/Code/github.com/kxlahsimx09/mb-next-payment-gateway`, the §3c local-`main` freshness anchor) had a dirty tree: staged deletions of all 7 #228 epics + the freetier-216 PoC evidence dir + reverted `adr.md`/`INDEX.md`/`README.md`/design docs — 38 entries, 38 insertions / 12,581 deletions, all under `docs/`+`poc/`.

**Root cause:** a session editing the PRIMARY directly (§3c violation) staged a selective rollback of `docs/`+`poc/` to ~commit `79fd73c` state. `.git/index` mtime = **May 25 20:02:26** pinned WHEN. The reflog showed HEAD advancing `aec4a39→12b9e1c→1d0b7ff` via **empty-message fast-forwards** = the automated main-sync (maw `createWorktree` / inbox-watcher Path-1 §3c FF) — which carried the stale staged changes forward across every sync. Path-level `git checkout/restore --staged`/`git rm` leave **no reflog entry**, so the exact command/session is not git-recorded; the empty-message FFs are the only HEAD ops.

**Verify-before-discarding (§3c) done right — the gate is NOT empty/non-empty diff.** A rollback diff is ALWAYS non-empty, so the orchestrator's "empty→safe / non-empty→STOP" heuristic mis-fires here. The correct test for "zero unmerged work": for every still-on-disk MODIFIED file, `git hash-object <f>` and check `git rev-list --all --objects | grep <blob>` — if the blob exists in history, the content is already committed (no novel work). Deleted files that exist in origin/main are inherently recoverable (no risk). All 15 modified files matched committed blobs → zero novel content → safe to restore.

**Restore (non-destructive, P-001-aligned):** `git restore --staged --worktree -- docs/ poc/` (HEAD==origin/main==1d0b7ff). No `--force`. This UN-deletes the epics, so it honors P-001 rather than violating it. Result: clean tree, 0 diff vs origin/main.

**Takeaways:** (1) `.git/index` mtime is the reliable WHEN for an orphaned staged change. (2) blob-in-history is the rigorous unmerged-work test for a staged rollback. (3) automated FF main-sync does NOT clean staged paths — a §3c primary can accumulate orphaned staged drift that rides forward across syncs invisibly; periodic `git status` on the two primaries should be part of fleet hygiene.

Tags: #brew-ops #repo:cross #fleet #gotcha #git #drift

---
*Added via Oracle Learn*
