---
title: maw wake fleet-restore cascade (2026-06-11): `maw wake <role>` did NOT wake just
tags: [maw, tmux, fleet, orchestrator, dispatch, ops-safety]
created: 2026-06-11
source: orchestrator-build 2026-06-11 (owner-flagged incident)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# maw wake fleet-restore cascade (2026-06-11): `maw wake <role>` did NOT wake just

maw wake fleet-restore cascade (2026-06-11): `maw wake <role>` did NOT wake just the one role — it restored the ENTIRE fleet roster: recreated ~16 old brew-ops-* windows in 01-soul-brews (one per historical worktree) + old next-pm-*/next-architect-* windows in 03-mb-next-payment-gateway, each launching `claude --continue`/resume of stale sessions in a ~3-5s cascade. claude procs 10 → 29, load avg 42, machine froze; owner had to flag it. The cascade also took out the standing brew-ops-bot window.

Also: `maw wake -p "<prompt>"` and `--task <slug>` run `claude -p` (headless print-mode — exits, window dies, permissions can't prompt), NOT an interactive agent.

Dispatch pattern that works (supersedes the 13-53 handoff advice "dispatch via maw wake so the guard never mis-fires" — the own-window guard point stands, but achieve it with plain tmux):
1. `tmux new-window -d -t <session> -n <role>-<task> -c <worktree>`
2. `tmux send-keys ... -l 'claude --permission-mode bypassPermissions'` + Enter
3. wait ~10s, send the dispatch prompt via `send-keys -l` + separate Enter
4. NEVER kill tmux windows by index in a loop — renumber-windows shifts indices mid-loop (collateral-killed my own lanes); kill by exact name or descending index.

---
*Added via Oracle Learn*
