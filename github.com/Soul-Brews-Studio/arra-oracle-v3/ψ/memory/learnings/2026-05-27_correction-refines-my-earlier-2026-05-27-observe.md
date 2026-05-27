---
title: CORRECTION (refines my earlier 2026-05-27 "OBSERVED P-002 recurrence …11l-loop" 
tags: [orchestrator, brew-ops, fleet, inbox-watcher, stop-hook, 11l, 11i, 151, 238, pr-108, whole-dir-gate, stale-owner-record, deferred-not-stuck, circuit-breaker, false-positive, correction, spurious-session, campaign-231, thread-232, repo:arra-oracle-v3]
created: 2026-05-27
source: orchestrator wt-29 — 2nd bootstrap wake on thread-232 notify, watcher-state verification, 2026-05-27
project: github.com/soul-brews-studio/arra-oracle-v3
---

# CORRECTION (refines my earlier 2026-05-27 "OBSERVED P-002 recurrence …11l-loop" 

CORRECTION (refines my earlier 2026-05-27 "OBSERVED P-002 recurrence …11l-loop" learning) — diagnosis sharpened with watcher-state evidence.

What I got WRONG earlier: I hypothesized a §11f WAKE-KEY SPAWN bug — that a parent_thread-carrying architect reply was mis-keyed onto `thread:` instead of `parent_thread:`, spawning a spurious wrong-keyed owner session. The watcher state disproves this: `2026-05-27_08-05_from-next-architect_thread-232_reply.md.state` shows `wake_key=231, status=deferred, defer_reason=owner-busy`. The watcher keys parent_thread replies CORRECTLY (231 → true owner wt-22) and DEFERS delivery while the owner is busy (§11i deferred is queued, not stuck). There is no reply-mis-keying / spurious-spawn-from-reply bug. Do not chase one.

The ACTUAL loop driver (two parts, both real):
  1. §11l gate is STILL WHOLE-DIR (fork PR #108 — orchestrator gate → §151-owner-scoped — is NOT yet merged/deployed). So ANY orchestrator session that tries to Stop while wt-22's ACTIVE #231/#232 campaign reply envelopes sit at for-orchestrator/ root gets false-blocked on sibling-owned envelopes, 3×, → circuit-breaker emits a `thread-232` notify.
  2. The breaker notify (thread:232, NO parent_thread) keys on a STALE `sessions/orchestrator/thread-232.owner=wt-29` record (left from an earlier spurious spawn), so it `owner_resume`s the spurious wt-29 session — which re-hits gate #1 → loop. Each wt-22↔next-architect round-trip (08-05, 08-13, …) leaves a fresh at-root envelope and re-triggers it.

Correct disposition for a woken spurious session (validated twice this session): VERIFY watcher state of the flagged inbound — if `status=deferred`/owner≠me, it is NOT stuck and NOT mine; LEAVE it untouched (touching it strips the live owner's pending doorbell — P-001 + sibling-owned); archive ONLY your own notify with a moot note; do NOT usurp/relay (user is in the owner session). Self-limiting: stops once the owner (wt-22) archives its own envelopes.

Brew-ops fix priority: (a) MERGE+deploy PR #108 (owner-scoped §11l gate) — removes driver #1 entirely; (b) garbage-collect stale `thread-<n>.owner` records that point at retired/spurious sessions, and/or the breaker should not fire while the flagged envelope is `deferred(owner-busy)` (driver #2 is a not-a-gap state). Human is already tracking this as "brew-ops fleet-bug ⏳ pending(non-blocking)" in the wt-22 status table; secondary nit: wt-22 is slow to archive its own #232 inbound envelopes. Supersedes the §11f-spawn hypothesis in [[2026-05-27_observed-p-002-recurrence-not-a-fix-11l-loop]]; see also [[2026-05-27_fix-prd-tests-green-orchestrator-11l-stop-ho]] (the PR #108 fix awaiting merge).

Tags: #repo:arra-oracle-v3 #fleet #inbox-watcher #orchestrator #brew-ops #stop-hook #11l #11i #151 #238 #pr-108 #whole-dir-gate #stale-owner-record #deferred-not-stuck #circuit-breaker #false-positive #correction #campaign-231 #thread-232

---
*Added via Oracle Learn*
