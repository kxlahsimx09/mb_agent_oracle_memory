---
title: Orchestrator: verify a relayed "index restored" claim from your OWN MCP session 
tags: [orchestrator, memory, indexer, vector, lancedb, drift, gotcha, repo:arra-oracle-v3, thread-253, thread-115, state-grounding, relay-not-verdict, decision-authority, escalate]
created: 2026-05-27
source: orchestrator @ arra-oracle-v3.wt-35-inbox (thread #253 handling)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Orchestrator: verify a relayed "index restored" claim from your OWN MCP session 

Orchestrator: verify a relayed "index restored" claim from your OWN MCP session before telling the user "fully restored" (state-grounding applied to relays).

Context (2026-05-27, thread #253): brew-ops rebuilt the bge-m3 LanceDB vector index after #115 recurrence #5 and reported it "RESTORED + verified — live MCP mode=vector returns 6 hits, no restart; adapter re-resolves table per query." Root cause was the mixed-mode advisory-lock gap: the durable #115 fix (Phase 2 write-lock + Phase 3 boot-check, deployed 6474fb6) held in code but the lock is advisory — only post-deploy processes honor it. 4 pre-deploy MCP writers (PIDs from May-17/17/18/22) ran lock-free old code; one raced the lock-holder and dropped a fragment the newest manifest referenced. FTS5 stayed healthy → hybrid degraded to FTS-only fleet-wide. Bit in 4 days.

Observation (orchestrator client side — relayed to brew-ops to confirm, NOT rendered as a verdict per Core principle 2a): from THIS orchestrator session's long-lived MCP process, arra_stats still returned vector_status: degraded with the SAME pre-rebuild fragment error (…00010110…cad84a.lance), even though last_indexed matched the rebuild timestamp and FTS was healthy. So the on-disk index was rebuilt, but pre-rebuild MCP processes (including the orchestrator's own session) keep serving degraded vectors until they cycle — the stale-live-process side of the very mixed-mode gap brew-ops flagged. "Restored fleet-wide" and "this live process still degraded" are both true simultaneously.

Orchestrator lesson: when relaying a restore/repair claim to the user, run arra_stats (+ a mode=vector probe) from your own session first; report what you observe with the caveat rather than echoing "fully restored." Frame any discrepancy as an observation for the owning agent to confirm, not as your own technical verdict.

Decision recorded: both human-gated calls — (1) reopen #115 + harden [options: a=deploy-time graceful bounce of all MCP writers (disruptive, kills active panes), b=single-writer broker (makes lock mandatory not advisory — architectural endgame), c=boot-integrity warns on stale sibling writers (cheap detection)]; (2) restart the down HTTP :47778 server — were ESCALATED to the user (Telegram msg 33 + #253 msg 1199 ESCALATE marker). Rationale: zero orchestrator decision-authority patterns for request-shape "fleet-hardening-dispatch + server-restart" → LOW-confidence gate → escalate, do not auto-dispatch. Did not bounce the 4 live pre-lock writers (live claude panes; charter + #994/#996 ratified no-force-bounce). Likely owner if approved: brew-ops.

---
*Added via Oracle Learn*
