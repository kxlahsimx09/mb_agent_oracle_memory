---
title: Concurrent orchestrator sessions race on the §11e Step 0.5 directed-inbox sweep,
tags: [orchestrator, directed-inbox, fan-out, race-condition, concurrency, fleet, drift, gotcha, inbox-watcher, step-0.5]
created: 2026-05-16
source: Orchestrator wt-21 incident observation, thread #127, 2026-05-16
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Concurrent orchestrator sessions race on the §11e Step 0.5 directed-inbox sweep,

Concurrent orchestrator sessions race on the §11e Step 0.5 directed-inbox sweep, causing duplicate fan-out dispatch.

**Observed 2026-05-16 GMT+7 (#fleet #orchestrator #drift #gotcha).** The §ADR-4a §Amendment 2026-05-16 (Decision #6 sweep triage) impl leg was dispatched to next-impl THREE times within ~3 minutes by three different orchestrator worktree sessions (wt-21/22/23). Envelopes: `thread-128_escalate`, `thread-131_dispatch`, `thread-130_consult`. The inbox-watcher fired next-impl on all three → three live next-impl sessions (tmux windows 15/16/17, branches agents/29/30/31) each independently building the same money-safety-critical PR.

**Root cause.** §11e Step 0.5 ("for each unread envelope: read → respond → archive") has no mutual exclusion. When several `for-orchestrator/` envelopes arrive close together, the inbox-watcher fires several fresh orchestrator sessions. Each session's Step 0.5 sweep lists `for-orchestrator/*.md` and sees the SAME not-yet-archived envelope (here, the next-architect thread-128 hand-off). Each acts on it and dispatches before any one session wins the `git mv` archive. The archive is the only de-dup signal and it happens AFTER the dispatch, so it cannot prevent duplicate dispatch.

**Why it matters.** Duplicate fan-out = N near-identical PRs for one change, N agent-runs of identical work, wasted compute, and merge-time reconciliation burden. On a money-safety change the risk is worse: divergent implementations of the same ratified amendment.

**Mitigation directions (not yet implemented).** (a) Claim-before-act: an orchestrator session renames/moves the envelope into an `in-progress/` (or appends a `claimed_by` marker) as the FIRST step of processing, before any dispatch — losers of the rename race skip it. (b) Watcher-side single-flight: serialize orchestrator wakes so only one orchestrator session is active at a time. (c) Dispatch idempotency: before fanning out, the orchestrator greps `for-{target}/` + open threads for an existing dispatch of the same parent_thread/subject and no-ops if found.

**Workaround when detected.** Cannot self-resolve from one session — killing live duplicate worktrees mid-work is invasive/irreversible and races other cleanup sessions. Escalate to the human (§11h) with the specific tmux windows + branches so they can keep one run and kill the rest.

---
*Added via Oracle Learn*
