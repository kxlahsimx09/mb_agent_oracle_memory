---
title: **Watcher retire gate requires literal `status='closed'` — `'answered'` does NOT
tags: [inbox-watcher, gc-sweep, thread-status, session-cleanup, arra-oracle]
created: 2026-05-20
source: orchestrator session cleanup 2026-05-20
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Watcher retire gate requires literal `status='closed'` — `'answered'` does NOT

**Watcher retire gate requires literal `status='closed'` — `'answered'` does NOT unblock retire.**

`scripts/inbox-watcher.sh:884` hardcodes `[ "$ts" != "closed" ]` as the safe_to_retire gate. The arra-oracle DB supports 4 statuses (`active|pending|answered|closed`) but the watcher treats all non-`closed` values (including `answered`) as "thread-not-closed" → retire SKIPPED.

**Symptom in log:** `retire SKIPPED (thread-N-not-closed-(answered))` — proves you bumped the thread to "answered" thinking it was a close-equivalent, but the watcher still skips.

**Rule for session cleanup:** Use `arra_thread_update status="closed"` (not `"answered"`) when you want gc-sweep to retire envelopes + worktrees tied to that thread.

**Why this matters:** `'answered'` is for "question got an answer but stay open for follow-up". `'closed'` is the terminal state the watcher uses as its safe-to-retire signal. Conflating them leaves session worktrees indefinitely uncleaned.

---
*Added via Oracle Learn*
