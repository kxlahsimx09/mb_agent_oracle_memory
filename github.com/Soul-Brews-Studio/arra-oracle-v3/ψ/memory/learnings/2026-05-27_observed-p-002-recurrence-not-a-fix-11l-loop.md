---
title: OBSERVED (P-002 recurrence, not a fix) — §11l loop-closure circuit-breaker fired
tags: [orchestrator, brew-ops, fleet, inbox-watcher, stop-hook, 11l, 11f, 214, 238, 151, wake-key, circuit-breaker, false-positive, two-orchestrator-session-hook-bug, spurious-session, race-condition, thread-232, thread-207, campaign-231, drift, repo:arra-oracle-v3]
created: 2026-05-27
source: orchestrator wt-29 — inbox bootstrap, thread-232 notify close-out, 2026-05-27
project: github.com/soul-brews-studio/arra-oracle-v3
---

# OBSERVED (P-002 recurrence, not a fix) — §11l loop-closure circuit-breaker fired

OBSERVED (P-002 recurrence, not a fix) — §11l loop-closure circuit-breaker fired a FALSE-POSITIVE again on 2026-05-27 14:33 GMT+7, despite the §238 gate-scoping fix already being PR'd that same day (fork PR #108, "§11l gate scoped by §151 OWNER", thread #238).

What happened: next-architect's reply on the p2p-hub Phase B campaign carried `thread: 232, parent_thread: 231` (campaign owner thread-231.owner = orchestrator wt-22). Per §11f a parent_thread-carrying envelope must key its wake on `parent_thread` (231) → route to the wt-22 owner. Instead a wrong-keyed orchestrator session was spawned at wt-29-inbox-1779867293 and recorded as `thread-232.owner` (keyed on `thread:232`, not `parent_thread:231`). wt-22 (the true owner) handled the reply correctly — read msg 1152, relayed B1.4 D-1..D-4 to the user, archived `2026-05-27_07-28_..._thread-232_reply.md` with a handled_note at 14:36. But the breaker's check at 14:33 ran in the race window (file still at root) on the spurious wt-29 session and gave up after 3 blocks, emitting `for-orchestrator/2026-05-27_14-33_..._thread-232_notify.md`. Work was UNAFFECTED; the campaign and user relay were never at risk.

This is the 2nd logged recurrence of the breaker false-positive (1st: 2026-05-22 thread-207 in ~/.cache/inbox-loop-closure/escalations.log). Two distinct sub-bugs are implicated, and PR #108 (the §11l *gate* scoping) does not obviously cover the first:
  1. WAKE-KEY / SPAWN (§11f): a `parent_thread`-carrying reply still spawned a wrong-keyed session (`thread:` not `parent_thread:`), creating a spurious owner. The gate-scoping fix doesn't prevent the spurious session from being spawned in the first place.
  2. RACE WINDOW (§11l): the breaker checks for archive/reply-gap while the owning session is mid-close-out (move + handled_note append not yet complete), producing a false "loop still open".

Resolution by a follow-up orchestrator session (the spurious wt-29 itself, woken by the notify): VERIFY the referenced inbound's *current* frontmatter before acting — if it already carries handled_by_inbox or handled_note, the loop is closed; archive the notify with a moot/false-positive note and do NOT re-relay (re-relaying = double-dispatch to the user). Already flagged to the user by wt-22 for a brew-ops fleet-mechanics fix.

For brew-ops: confirm whether PR #108 is merged+deployed to the running inbox-watcher checkout (the breaker fired after it was PR'd → likely not yet, or the wake-key spawn path is out of its scope). Candidate hardening: (a) §11f wake-key derivation must prefer `parent_thread` on the spawn/owner-record path, not just the gate; (b) breaker should re-stat the flagged envelope (incl. handled/) before declaring loop-open, to close the mid-close-out race. Related: [[2026-05-27_fix-prd-tests-green-orchestrator-11l-stop-ho]], [[2026-05-22_214-orchestrator-whole-dir-sweep-exception-brea]], [[2026-05-22_observed-p-002-not-a-fix-orchestrator-campaign]].

Tags: #repo:arra-oracle-v3 #fleet #inbox-watcher #orchestrator #brew-ops #stop-hook #11l #11f #214 #238 #151 #wake-key #circuit-breaker #false-positive #two-orchestrator-session-hook-bug #spurious-session #thread-232 #thread-207 #campaign-231 #drift

---
*Added via Oracle Learn*
