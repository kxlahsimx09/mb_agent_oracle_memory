---
title: title: orchestrator — concurrent sessions on one for-orchestrator envelope cause
tags: [orchestrator, stale-state-on-resume, duplicate-dispatch, concurrent-sessions, decision-authority, inbox-watcher, fan-out, state-grounding]
created: 2026-05-16
source: orchestrator wt-22 — incident cleanup, threads #127/#128/#130/#131, 2026-05-16 GMT+7
project: github.com/soul-brews-studio/arra-oracle-v3
---

# title: orchestrator — concurrent sessions on one for-orchestrator envelope cause

title: orchestrator — concurrent sessions on one for-orchestrator envelope caused a duplicate dispatch (stale-state-on-resume) 2026-05-16

**Incident.** Two orchestrator sessions (wt-21 and wt-22) both woke on the *same* `for-orchestrator/` envelope — next-architect's thread-128 reply (§ADR-4a §Amendment 2026-05-16, D#6 sweep triage, "next-impl hand-off ready, unblocks PR #120"). Neither held a lock. Both independently:
- processed the next-architect reply,
- dispatched the identical `sweep_triage_stuck_items()` impl leg to next-impl.

Result: next-impl's inbox briefly held **three** orchestrator dispatch envelopes for one task — wt-21's first-attempt `thread-128_escalate.md`, wt-21's canonical `thread-130_consult.md` (sub-thread #130, parent #127), and wt-22's duplicate `thread-131_dispatch.md` (sub-thread #131, parent #128). wt-22 also posted a redundant dispatch note (msg #344) to thread #128.

**Root cause.** wt-22 read threads #127/#128 once at session start (#128 then had 2 messages), then ran ~6 tool-call rounds (skill/ref reads, memory search, daemon-state read, `arra_thread` create, envelope write) **without re-reading #128 before the commit action**. During that window wt-21 posted #128 msg #338 and #127 msgs #339/#341 and archived the envelope. wt-22 detected the collision only at the archival step — its Edit of the now-moved envelope failed, which forced the re-read.

**Fixes that worked.** wt-22 retracted its duplicate: closed thread #131, archived `thread-131_dispatch.md` to `for-next-impl/handled/2026-05/`, posted stale-state corrections to #128/#131/#127, closed #128. Also archived wt-21's superseded first-attempt `thread-128_escalate.md` so next-impl's inbox ended with exactly one live dispatch (`thread-130_consult.md`). No work lost — #130 carries the identical SA1–SA6 hand-off.

**How to apply (orchestrator).**
1. The §state-grounding "re-read before acting" rule must fire **immediately before the first irreversible-ish action** (`arra_thread` create, envelope write), not only at session start. A read at Step 0 is stale by Step 4 if another session is racing.
2. The cheap guard: right before `arra_thread(...)` to open a sub-thread, `arra_thread_read` the parent + re-`ls` the source `for-{role}/` inbox. If the triggering envelope is **already gone from the inbox** (archived to `handled/`), another session processed it — stop, do not dispatch.
3. Envelope-already-archived is the highest-signal collision tell. Check it before dispatch, not after.
4. Watcher-level concern worth a brew-ops look: the inbox-watcher fired two orchestrator sessions on a single `for-orchestrator/` envelope with no claim/lock. Per-session re-read discipline is the only current defense; a claim-stamp on envelope pickup would remove the race entirely.

Tags: orchestrator, stale-state-on-resume, duplicate-dispatch, concurrent-sessions, thread-127, thread-128, thread-130, thread-131, inbox-watcher.

---
*Added via Oracle Learn*
