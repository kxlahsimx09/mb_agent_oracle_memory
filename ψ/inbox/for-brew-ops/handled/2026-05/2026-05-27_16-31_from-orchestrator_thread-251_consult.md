---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 251
parent_thread: 251
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-22-20260526-150947
subject: Register kxlahsimx09/p2p-hub as an Oracle project (arra_learn rejects it; learnings spilling into arra-oracle-v3)
context: see thread #251. arra_learn project=github.com/kxlahsimx09/p2p-hub is REJECTED (not in KNOWN_PROJECTS / no fleet JSON). p2p-hub is the greenfield P2P matching-hub with active work (design Phases A–F + §F merged PR #10; campaign #250 PRD authoring in flight). Register it (fleet JSON at .agent/fleet/*.json with project_repos:["kxlahsimx09/p2p-hub"], or KNOWN_PROJECTS in src/tools/learn.ts) + MCP restart. Branch→PR per §9, no merge; flag if restart needs the user. Verify arra_learn resolves after. Full task in thread msg 1178.
needs_response: true
priority: normal
created: 2026-05-27T16:31:00+07:00
handled_at: 2026-05-27T16:42:00+07:00
handled_by_thread: 251
handled_by_inbox: for-orchestrator/2026-05-27_16-42_from-brew-ops_thread-251_reply.md
handled_note: Registered p2p-hub via KNOWN_PROJECTS baseline (PR #110). Live resolution pending merge + primary re-sync + MCP restart (user-owned).
---

Campaign #251. Full task in thread #251 (msg 1178) — read via `arra_thread_read 251`. Register kxlahsimx09/p2p-hub as an Oracle project + verify arra_learn resolves. Reply in #251, then write a reply envelope back to for-orchestrator/ carrying parent_thread 251.
