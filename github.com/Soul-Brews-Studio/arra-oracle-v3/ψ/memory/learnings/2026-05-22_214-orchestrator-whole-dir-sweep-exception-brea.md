---
title: §214 orchestrator "whole-dir sweep" exception breaks down under a MULTI-SESSION 
tags: [orchestrator, directed-inbox, multi-session, campaign-scope, wake-key, owner-map, stop-hook, §214, §181, §151]
created: 2026-05-22
source: orchestrator wt-15 campaign-215 (next-writer W2-cleanup aggregation)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# §214 orchestrator "whole-dir sweep" exception breaks down under a MULTI-SESSION 

§214 orchestrator "whole-dir sweep" exception breaks down under a MULTI-SESSION orchestrator (§181) — handle owner-scoped, not whole-dir.

CONTEXT (2026-05-22, campaign #215): orchestrator wt-15 was woken for thread-215 (next-writer W2-cleanup reply). The for-orchestrator/ root also held a fresh `from-next-impl_thread-203_reply.md` (parent_thread:201, a different campaign). AGENTS.md §11e/§214 literally says "the orchestrator sweeps whole-dir, not campaign-scoped" — which would have me grab 203 too.

WHY THAT'S WRONG NOW: §214's whole-dir rule was written assuming ONE hub orchestrator session ("one hub session spans many wake keys"). Reality has diverged — the orchestrator now runs as MULTIPLE concurrent sessions (observed: chat-watchers for orchestrator/162613 + orchestrator/084335 + this wt-15 session; owner map shows thread-215.owner=wt-15 while 203/201 had their own owner+active session history all day). Grabbing 203 would pull an unrelated next-impl campaign into the campaign-215 session — exactly the cross-campaign contamination §214 was created to FIX for workers.

EVIDENCE THE ENFORCEMENT LAYER ALREADY AGREES: §214 shipped a wake_key-scoped §11l Stop hook (arra-oracle-v3 fork PR #88). A wake_key-scoped Stop hook does NOT block on sibling-campaign envelopes in the root — i.e. it EXPECTS the orchestrator to leave non-its-campaign envelopes. So the deployed hook contradicts the prose's "whole-dir" instruction. Confirmed empirically: I left 203; within ~minutes its own owner session archived it to handled/2026-05/. Nothing was stranded.

RULE (override per P-003): even the orchestrator should handle OWNER-SCOPED (by §151 thread-<wake_key>.owner), not blind whole-dir, once it runs multi-session. Check `~/.cache/inbox-watcher/sessions/orchestrator/thread-<wake_key>.owner` == your own worktree before claiming an envelope. Leave envelopes you don't own — the watcher routes them to their owner (or spawns fresh). The §214 charter text should be refined to say "owner-scoped (whole-dir only while a single hub session exists)".

FOLLOW-UP for brew-ops: reconcile AGENTS.md §11e/§214 prose with the wake_key-scoped Stop hook (PR #88) — they currently disagree on whether the orchestrator is whole-dir or campaign/owner-scoped.

#repo:arra-oracle-v3 #repo:cross #fleet #mcp-tools #decision #gotcha #handoff #brew-ops

---
*Added via Oracle Learn*
