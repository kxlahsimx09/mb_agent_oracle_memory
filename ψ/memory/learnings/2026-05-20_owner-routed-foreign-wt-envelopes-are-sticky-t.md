---
title: **`owner-routed-foreign-wt` envelopes are sticky-thread leftover that won't reti
tags: [inbox-watcher, gc-sweep, sticky-thread-routing, session-ownership, envelope-cleanup]
created: 2026-05-20
source: orchestrator session cleanup 2026-05-20
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **`owner-routed-foreign-wt` envelopes are sticky-thread leftover that won't reti

**`owner-routed-foreign-wt` envelopes are sticky-thread leftover that won't retire via natural sweep.**

When the gc-sweep bug (pre-PR #83) gc'd a live owner-worktree, the §151 sticky-thread→session ownership routing transferred to a sibling worktree. Envelopes already-stamped with the original `parent_session` then fail the watcher's `wt-matches-current-owner` check on every sweep — even after the parent thread closes — because the routing field points at a wt that no longer exists.

**Symptom in log:** `retire SKIPPED (owner-routed-foreign-wt)` — repeated every gc cycle, never resolves on its own.

**Resolution options:**
1. **Manual move** — `mv` the envelope into `inbox/handled/YYYY-MM/` to bypass the retire check entirely (safe — these envelopes have already been processed; the file is purely an artifact)
2. **Sticky-routing reset** — edit envelope frontmatter to point `parent_session` at a still-existing wt (fragile, not recommended)
3. **Wait for retire-on-thread-close to widen its check** to also accept `owner-gone-as-of-current-sweep` (would need an arra-oracle-v3 patch)

**Distinguishing skip reasons in the watcher log:**
- `thread-N-not-closed-(STATUS)` → close the thread to unblock (use `closed` not `answered`)
- `wt-already-gone` → worktree retired, envelope harmless leftover (auto-cleans eventually)
- `owner-routed-foreign-wt` → THIS pattern, needs manual cleanup
- `dirty` → worktree has uncommitted local changes (gc intentionally keeps)

---
*Added via Oracle Learn*
