---
title: **inbox-watcher: `delivered_to_owner` ≠ delivered to the agent.** The watcher's 
tags: [orchestrator, inbox-watcher, stale-state-on-resume, silent-fail, delivered-to-owner, owner-liveness, send-keys, jsonl-gate, T1-verify, campaign-254, process-gap, repo:arra-oracle-v3, fleet]
created: 2026-05-29
source: orchestrator wt-21 campaign #254 — 2026-05-28T22:30 silent-fail of msg-1252 dispatch, recovered 2026-05-29T05:03 by manual kill+state-file-drop
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **inbox-watcher: `delivered_to_owner` ≠ delivered to the agent.** The watcher's 

**inbox-watcher: `delivered_to_owner` ≠ delivered to the agent.** The watcher's send-keys to a tmux window can "succeed at the tmux level" while the running claude process is STUCK (alive but JSONL idle for many minutes/hours), keystrokes queue but are never processed. The watcher's T1 verify gate (JSONL has user message containing the inbox filename) IS what proves delivery — but in this campaign it stayed at `delivered_to_owner` indefinitely for a stuck owner session.

OBSERVED (2026-05-28→29, campaign #254): orchestrator wt-21 dispatched msg 1252 (§D re-run) → state file `status=delivered_to_owner`, `route=owner_send_keys`, `wt_path=…wt-17-inbox-1779885958`. The wt-17 claude process (pid 80744) was alive 8 hours but JSONL idle ~7.8 hours (had been stuck on an earlier envelope's bootstrap). watcher logged `claude_alive_at(...) → pid=… alive but JSONL idle 28072s > 600s; STUCK (resume OK)` — meaning it DETECTED the stuck state but STILL send-keys'd. 12+ hours passed before the orchestrator noticed (relied on inbox-clean as "running" rather than verifying state-file status). MULTIPLE subsequent dispatches (msg 1245/1249/1252) all silently absorbed into the stuck session via the same route.

RECOVERY (manual, ~3 min once diagnosed): `kill <pid>`; `rm <state file>`; `rm <§151 owner record>`; watcher's next scan saw envelope NEW + owner-gone → `--fresh respawn + ownership transfer` → wt-19 spawned → VERIFIED.

LESSONS:
1. **`inbox-clean` is NOT proof that a dispatch is running** — check the state file in `~/.cache/inbox-watcher/state/<oracle>/<envelope>.state`. The `status=` field is the truth: `fired` (awaiting T1), `verified` (delivered to JSONL), `delivered_to_owner` (send-keys went out but JSONL didn't confirm), `failed_no_prompt` (T1 expired).
2. **Orchestrator discipline:** every time the user asks "what's the status?" while a dispatch is awaiting reply, re-read the state file. Don't extrapolate from inbox alone.
3. **Watcher improvement opportunity (carry-forward):** before send-keys, the watcher should verify the JSONL is being actively processed (not idle > N seconds). If stuck, drop the §151 owner record and trigger `--fresh` instead of repeated futile send-keys. The watcher's `claude_alive_at` log line shows it KNOWS the session is STUCK — but the action (`resume OK`) doesn't reflect that knowledge.
4. **For zsh poll scripts** in this codebase: `status` is a read-only builtin; do NOT assign to it (use `st_val` or similar). Two scripts crashed during this incident because of the name collision.

This is logged with `tags: [stale-state-on-resume]` per orchestrator SKILL §state-grounding pattern-library.

---
*Added via Oracle Learn*
