---
title: gotcha — inbox-watcher silently parks transient API-529 stalls for ~29min before
tags: [inbox-watcher, fleet, 529, transient-error, auto-retry, gotcha, brew-ops]
created: 2026-05-22
source: brew-ops thread #210 diagnosis (2026-05-22)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# gotcha — inbox-watcher silently parks transient API-529 stalls for ~29min before

gotcha — inbox-watcher silently parks transient API-529 stalls for ~29min before failed_stuck (no auto-retry yet)

Tags: #repo:arra-oracle-v3 #fleet #brew-ops #gotcha #inbox-watcher #529

**Observed 2026-05-22 (thread #210).** Two freshly-woken next-impl sessions (#203 wt-1/`e779dccd`, #209 wt-5/`0b30477f`) hit `API Error: 529 Overloaded` on their FIRST turn and stalled with zero work done.

**Failure signature (JSONL):** the wake prompt (`inbox: <fname>`) lands as a user turn, then the next assistant turn is `"isApiErrorMessage": true` with text `API Error: 529 Overloaded…`, followed only by a `last-prompt` checkpoint marker — that is the tail (no tool_use/tool_result/progress), and the claude process has exited (`claude_alive_at` false).

**Why the watcher mishandles it:** `verify_delivery` (T1) greps the JSONL for `inbox: <fname>` via `jsonl_has_prompt` — the prompt IS present (delivery succeeded; the agent errored on turn 1), so T1 sets `status=verified`. Then `verify_processing` waits for archival that never comes → `failed_stuck` only after T2=1800s (~29min). Recovery is then MANUAL: `maw wake --resume <captured-sid> --task "inbox:<fname>"` once the 529 clears (~30–47min later). State evidence: every 529-stall in `~/.cache/inbox-watcher/state/next-impl/` shows `verified→failed_stuck` at ~1745s apart, then a `route=owner_resume` re-fire → completed. The recovering re-resume of the SAME session works perfectly (0b30477f resumed and did full work after the 529 cleared).

**Key facts for any auto-retry work:**
- `isApiErrorMessage` is Claude Code's own per-turn classification — robust discriminator of an API stall vs. a genuine logic stall (logic stalls have no such tail). Treat 429/500/502/503/529/Overloaded/network as transient (retry-worthy); 400/401/403 as non-transient (escalate, don't retry).
- Recovery = `--resume` the captured session-id into the SAME worktree (the proven path, identical to `fire_wake` Path 1 / `fire_to_owner` owner_resume), NEVER `--fresh` (would orphan the wt + lose §151 owner continuity).
- `jsonl_has_prompt` is a whole-file grep, so it CANNOT verify a retry attempt (original marker is permanently present) — verify a retry by "JSONL tail advanced past the error" instead.

**Status:** auto-retry-with-backoff (30s→2m→5m, cap 3, then `failed_transient_exhausted`+escalate) is PROPOSED on thread #210, awaiting orchestrator ratification — NOT yet implemented. This learning records the validated failure mode only; the fix's efficacy is unproven until it runs (P-002).

---
*Added via Oracle Learn*
