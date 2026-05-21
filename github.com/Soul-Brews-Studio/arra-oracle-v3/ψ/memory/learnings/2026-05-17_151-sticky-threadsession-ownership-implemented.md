---
title: §151 sticky thread→session ownership — implemented (arra-oracle-v3 fork PR #75, 
tags: [inbox-watcher, sticky-ownership, session-routing, directed-inbox, orchestrator, thread-151, parent_session]
created: 2026-05-17
source: brew-ops session 2026-05-17, thread #151 (wt-43)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# §151 sticky thread→session ownership — implemented (arra-oracle-v3 fork PR #75, 

§151 sticky thread→session ownership — implemented (arra-oracle-v3 fork PR #75, charter commit 14d8f95), pending merge.

**Problem fixed:** the inbox-watcher's session map only ever held sessions the watcher itself spawned. A thread opened *inside* an already-running session (via an `arra_thread` MCP call) produced no inbox event, so the watcher never learned the real owner; the first reply for the campaign `--fresh`-spawned a new orchestrator that became de-facto owner — the #140/#141 context-fragmentation + orchestrator-session sprawl.

**Fix:** the dispatcher stamps `parent_session: <its-worktree-path>` on outbound dispatch envelopes (the watcher derives the session-id UUID from the worktree — a Claude session can't self-discover its UUID but always knows its cwd). `record_owner_from_envelope` records `sessions/<parent_oracle>/thread-<parent_thread>.owner` from the dispatch envelope before any reply exists. Replies route back to the owner: busy→defer, idle→`tmux send-keys` into the live window, process-down→`--resume`, gone→`--fresh`+ownership-transfer. `campaign_inflight` serializes a campaign's replies through the one owner session. `safe_to_retire` skips `route=owner_*` worktrees (never retire a worktree the watcher didn't spawn). §5 human-collision policy = JSONL-idle gate only (pick (a)).

**Rough edge surfaced during implementation (live recurrence of the same bug class):** the watcher spawned a *duplicate* brew-ops session (wt-46) for a second thread-151 envelope while wt-43 was already handling the campaign. This is §11k-accepted worker behaviour — a busy worker getting a 2nd same-campaign envelope `--fresh`-spawns a sibling (workers deliberately don't dedup). The duplicate had nothing to do, tripped the §11l Stop-hook circuit breaker after 3 blocks (false "loop-closure FAILED" escalation), and mis-filed inbound envelopes into `ψ/inbox/handled/` instead of `for-brew-ops/handled/`. PR #75 fixes reply-routing-to-dispatcher (#140/#141) but does NOT dedup multiple dispatches to one busy worker — that remains a known rough edge. Tags: #repo:arra-oracle-v3 #fleet #mcp-tools #brew-ops #gotcha #decision #directed-inbox

---
*Added via Oracle Learn*
