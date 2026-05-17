---
title: title: §11d loop-closure is enforced by a Stop hook, not a workflow step (2026-0
tags: [directed-inbox, loop-closure, stop-hook, enforcement, brew-ops, fleet, handoff, decision]
created: 2026-05-17
source: thread #140 + PR #72
project: github.com/soul-brews-studio/arra-oracle-v3
---

# title: §11d loop-closure is enforced by a Stop hook, not a workflow step (2026-0

title: §11d loop-closure is enforced by a Stop hook, not a workflow step (2026-05-17)

#repo:arra-oracle-v3 #fleet #brew-ops #decision #gotcha #directed-inbox #handoff

## Problem
Dispatched oracle agents (next-impl PR #135, next-writer PR #139, thread #132) did the work but exited without (a) writing the reply envelope for a `needs_response:true` envelope or (b) archiving the inbound envelope per §11d. The §11e Step 0.5 close-out is a *workflow step* — advice — and for a dispatch the close-out happens after a long task, so agents forget it. The inbox-watcher T2 `failed_stuck` gate only *detects* an unarchived envelope after 30 min; the reply gap (archived but no reply) it never catches because an archived envelope reads `completed`.

## Fix
`scripts/inbox-loop-closure-hook.sh` — a Claude Code `Stop` hook (installed via `scripts/install-inbox-loop-closure-hook.sh` into `~/.claude/settings.json`). A dispatched oracle session cannot end while its loop is open:
- Archive gap: any `*.md` in `for-{oracle}/` root → block (exit 2).
- Reply gap: a recent `handled/` envelope with `needs_response:true` but missing BOTH `handled_by_inbox` and `handled_note` → block. (Correct close-out has `handled_by_inbox`; §11g moot has `handled_note`.)
- Self-gating: oracle identified by reverse-looking-up the Stop-hook session id against the inbox-watcher `state/<oracle>/*.state` + `sessions/<oracle>/*.session-id` maps. Non-watcher sessions = silent no-op → a node-global install is safe.
- Circuit breaker: after 3 blocks, stop blocking but write a `priority:high` notify to `for-orchestrator/` + log to `~/.cache/inbox-loop-closure/escalations.log` — never a silent give-up.
- Fail-open: any hook error allows the stop; watcher T2 stays as backstop.

## How to apply
- The hook is the enforcement layer; AGENTS.md §11c–§11g remain the source of truth for *what* correct close-out is. §11l documents the hook.
- Re-run the installer after editing the hook — the repo copy (`scripts/`) is canonical; `~/.claude/hooks/` holds the deployed copy.
- A `Stop` hook fires when an agent finishes responding. For a maw-spawned `claude -p` agent that is effectively session-end (one wake prompt = one response).
- Block via exit code 2 + stderr — Claude Code feeds stderr back to the agent as the reason to continue. No JSON construction needed.
- Follow-up: move hook injection into `maw wake` (set `ARRA_ORACLE` + fleet `--settings`) so the gate is fleet-runtime-owned and survives multi-node.

Source: PR kxlahsimx09/arra-oracle-v3#72, thread #140, vault commit 9e9a2cc.

---
*Added via Oracle Learn*
