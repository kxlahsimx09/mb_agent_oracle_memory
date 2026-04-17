## Handoff — pg-writer-oracle, 2026-04-17 09:32 GMT+7

### What I did this session

Attempted Workflow-2-track-commit against the range `3b7e0f1..ed45b7e`. Stopped at Step 3 on scope overrun per workflow-2's own rule (>10 files / >500 LOC trigger = escalate to Workflow 1). `docs/.baseline` NOT bumped. No docs edits.

### What I captured for the next agent

1. `ψ/memory/learnings/2026-04-17_decision-workflow2-scope-overrun-3b7e0f1-ed45b7e.md` — scope decision + per-territory file list + recommendation to run Workflow 1 against `ed45b7e`.
2. `ψ/memory/learnings/2026-04-17_fact-markfailed-callback-race-still-at-head-ed45b7e.md` — answer to user's ask: the MarkFailed double-callback race that put PR #179/#180 ON_HOLD is STILL PRESENT at HEAD. Dev tightened matcher/trigger gating (PRs #188, #189) but has NOT delivered the callback-dispatch redesign. Tests stay ON_HOLD.
3. `ψ/memory/retrospectives/2026-04/17/09.32_workflow2-attempt-escalated-to-w1.md` — retrospective with AI Diary + Honest Feedback.

### Status of other open items

- Issue #181 (status comments contradict 1=Active convention) — still OPEN, no dev fix landed.
- Issue #182 (swagger missing 8+ route groups) — still OPEN, no dev fix landed.
- Both reference drift learnings from 2026-04-15 remain valid; no supersede needed.

### Next agent action

Run Workflow-1 re-baseline against HEAD `ed45b7e`. Priority sections to reconcile:
- §3 API surface (5 controllers touched)
- §5 Schedulers (report_scheduler full revamp, 128+/274-)
- §6 Services (matcher + auto-reconcile gating + batch_id flow, cross-cutting)
- §9 Known drift (refresh #181/#182 + decide callback-race drift row)

### Open question for human / requirement_writer

Does the PR #189 request_id-gated re-enable of `tryReconcileAfterMarkFailed` count as the "callback redesign" the ON_HOLD decision required, or is a deeper dispatch-level change still needed? Not a technical-writer call.