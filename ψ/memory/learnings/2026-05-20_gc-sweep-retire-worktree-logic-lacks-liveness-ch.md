---
title: **gc-sweep retire-worktree logic lacks liveness check — can delete a worktree wh
tags: [gc-sweep, inbox-watcher, fleet-mechanics, owner-transfer, sibling-session, liveness-check, race-condition]
created: 2026-05-20
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **gc-sweep retire-worktree logic lacks liveness check — can delete a worktree wh

**gc-sweep retire-worktree logic lacks liveness check — can delete a worktree while a claude process is still alive in it, triggering spurious "owner gone" ownership transfer + sibling-session sprawl.**

Observed 2026-05-20: orchestrator session in `arra-oracle-v3.wt-1-20260519-105119` (pid 51108, alive 24h+, processing an active campaign). gc-sweep at 09:28:36 logged `RETIRED worktree .../arra-oracle-v3.wt-1-20260519-105119` based on an old archived inbox envelope (`2026-05-19_12-08_from-next-impl_thread-174_reply.md`, dated previous day) — without checking whether a live claude process still occupied that worktree. The watcher's "owner gone" detection at line 386 (`[ ! -d "$wt" ]`) correctly fired at 10:50:10 → `--fresh respawn + ownership transfer`; orchestrator ownership of thread-175 transferred to a fresh sibling session in `arra-oracle-v3.wt-3-inbox-1779245509`. Original session (this one) kept running but became spectator-of-record for subsequent #175 replies (10-02, 10-25, 10-49 all routed to sibling).

**The watcher's gone-detection is correctly tight** — its design intent is "worktree dir missing" not "JSONL idle." That part is fine. **gc-sweep is the actual culprit** — it retires worktrees based on envelope age/handled-state without consulting `claude_alive_at($wt)` first.

**Fix shape (proposed, not yet built):** before any `RETIRED worktree` action in gc-sweep, call the existing `claude_alive_at()` helper (already in inbox-watcher.sh, used in `owner_state()`) and SKIP retire if the result is `idle`, `busy`, or `STUCK (resume OK)` — only retire when no live claude process holds the worktree.

**Downstream effects of the bug:** sibling-session sprawl, owner-map churn, user confusion ("ทำไม reply ไม่ถึง"), wasted compute on sibling sessions doing the same campaign coordination. Not a money-safety bug, but a fleet-mechanics defect that creates the appearance of fragmentation.

Companion to: §151 sticky-ownership-with-transfer learning (the transfer mechanism itself is fine and works as designed when the owner-gone signal is correct). The lesson is upstream: only signal "owner gone" when the owner is *actually* gone — and a live claude process inside a worktree means it isn't gone, regardless of envelope age.

---
*Added via Oracle Learn*
