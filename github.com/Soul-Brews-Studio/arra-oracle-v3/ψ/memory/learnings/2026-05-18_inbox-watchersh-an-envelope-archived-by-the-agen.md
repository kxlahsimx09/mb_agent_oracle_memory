---
title: inbox-watcher.sh: an envelope archived by the agent INSIDE one poll interval (re
tags: [inbox-watcher, campaign-inflight, fired-state, directed-inbox, thread-170, resume-semantics, brew-ops]
created: 2026-05-18
source: brew-ops thread #170 — 2026-05-18
project: github.com/soul-brews-studio/arra-oracle-v3
---

# inbox-watcher.sh: an envelope archived by the agent INSIDE one poll interval (re

inbox-watcher.sh: an envelope archived by the agent INSIDE one poll interval (resumed → processed → §11d-archived in <60s) freezes its state file at `fired`. Pass 1 only iterates `.md` files still in `for-{oracle}/`, so verify_delivery (T1 probe) never runs once the file is gone; Pass 2 (the archived-envelope reconciliation sweep) originally handled only `verified`/`delivered_to_owner`/`deferred` — not `fired`. The orphaned `fired` state then makes campaign_inflight()/parent_session_busy() see a perpetual in-flight sibling, dead-locking every later envelope of that campaign (next-writer #167 sat DEFERRED ~2h, ALERTing "campaign sibling still in flight past T2" forever — thread #170).

Diagnosis tell: an envelope DEFERRED past T2 with no live session for the oracle. Check ~/.cache/inbox-watcher/state/<oracle>/*.state for a sibling sharing the same wake_key stuck at status=fired whose .md is already in handled/. The owning session is not stuck — it exited cleanly long ago; the watcher just holds a stale `fired` record nothing clears.

Live unstick (no code change, no restart): append `status=completed` to the orphaned .state file (~/.cache is operational state, eviction-allowed — not vault, not a P-001 concern). Next scan un-defers the blocked envelope.

Fix: Pass 2 gained a `fired)` case mirroring `verified`/`delivered_to_owner` — a `fired` envelope whose backing .md is gone → `completed` (file-gone proves §11d archival). Fork PR #81 (kxlahsimx09/arra-oracle-v3, base feat/all-prs-rebased) + regression test tests/cli/inbox-watcher-orphaned-fired-state.test.ts.

Also: `claude --resume <sid>` of a dead/exited session is correct and intended — it resumes the *conversation* (re-spawns a process attached to the saved JSONL), not a live process. "Don't --resume a dead session" is a misconception; resume is exactly the mechanism for an exited process. §11f routes a follow-up campaign envelope to owner_resume by design.

#repo:arra-oracle-v3 #fleet #handoff #brew-ops #gotcha #drift

---
*Added via Oracle Learn*
