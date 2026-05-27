---
title: orchestrator — post-campaign worktree/session cleanup: delegate worktree adjudic
tags: [orchestrator, fleet-cleanup, worktree-retire, delegate-to-brew-ops, 151-ownership-spans-sessions, orphan-adjudication, multi-orchestrator-session, thread-237, repo:arra-oracle-v3, fleet]
created: 2026-05-26
source: parent thread #237 — post-campaign worktree cleanup (msgs 1099-1101), 2026-05-26; 6 retired, wt-4 left (active #231)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator — post-campaign worktree/session cleanup: delegate worktree adjudic

orchestrator — post-campaign worktree/session cleanup: delegate worktree adjudication to brew-ops; don't infer "orphan" from your own §151 owner records when multiple orchestrator sessions run.

Campaign #237: after closing #225/#228/#234, the user asked to clean up all spawned worker sessions/worktrees. My campaigns spawned exactly 6 (next-writer ×3 = #225/#228/#234 worktrees; next-architect ×2 = #228/#234; pg-writer ×1 = #225), mapped precisely via ~/.cache/inbox-watcher/sessions/<oracle>/thread-<parent-campaign>.owner. All 6 were git-clean + 0-unpushed + PRs merged → brew-ops retired them (git worktree remove, NO --force; tmux windows killed by NAME not index since tmux renumbers after kills; 18 cache files evicted: .owner/.session-id/.session-engine per thread). Net mb-next 9→5, mobiz 2→1.

KEY LESSON: I flagged mb-next wt-4-inbox-1779786440 as a "likely orphan from #228" because it had no feature commits (base SHA) and was absent from MY owner records. brew-ops verified it was NOT an orphan — it is the §151 owner worktree for thread #231 ("P2P hub Phase B"), an ACTIVE campaign owned by a DIFFERENT orchestrator session (wt-22). §151 ownership is per-(oracle, wake-key) and SPANS sessions, so absence from one orchestrator's owner records ≠ orphan, and base-SHA/no-commits is normal for a propose-then-discuss analysis campaign. Retiring it would have killed an in-flight campaign. => When cleaning up worktrees, NEVER infer orphan-status from your own session's records alone; the authoritative check is the watcher's per-(oracle,wake-key) owner cache + the target thread's status across ALL sessions. Delegate destructive worktree ops to brew-ops (fleet-ops owner) — it has the cross-session adjudication + the gated retire; the orchestrator should map+count (read-only) and route, not git-worktree-remove inline.

FLEET STATE NOTE: at least THREE concurrent orchestrator sessions were live (wt-20 = requirement-remediation #225/#228/#234; wt-21 = load-test #201/#216; wt-22 = p2p-hub #231). This is why the orchestrator Stop-hook whole-dir exception kept false-blocking wt-20 on the others' envelopes — reinforces the brew-ops fix: scope the Stop-hook by §151 owner, not whole-dir.

---
*Added via Oracle Learn*
