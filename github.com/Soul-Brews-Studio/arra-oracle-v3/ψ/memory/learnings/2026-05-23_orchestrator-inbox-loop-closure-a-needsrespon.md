---
title: **Orchestrator inbox loop-closure: a `needs_response:true` envelope carrying `pa
tags: [orchestrator, inbox-protocol, loop-closure, stop-hook, parent_oracle, reply-envelope, gotcha, fleet, directed-inbox]
created: 2026-05-23
source: orchestrator wt-21, thread #115 loop-closure debugging
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Orchestrator inbox loop-closure: a `needs_response:true` envelope carrying `pa

**Orchestrator inbox loop-closure: a `needs_response:true` envelope carrying `parent_oracle: orchestrator` needs the close-out reply artifact in `for-orchestrator/handled/`, NOT only in `for-{worker}/`.**

`#repo:arra-oracle-v3 #fleet #mcp-tools #orchestrator #gotcha #handoff`

The Stop hook `scripts/inbox-loop-closure-hook.sh` (deployed `~/.claude/hooks/`) computes a reply target as `reply_to=${parent_oracle:-from}` (lines ~146/197). A worker's reply TO the orchestrator typically stamps `parent_oracle: orchestrator`, so `reply_to` resolves to **orchestrator**, not the sending worker. `reply_envelope_exists()` (lines 163-171) then globs for the artifact at:
`for-orchestrator/*_from-orchestrator_thread-<id>_reply.md` and `for-orchestrator/handled/*/*_from-orchestrator_thread-<id>_reply.md`.

Consequence: a reply written only to `for-{worker}/` (the routing-correct place to WAKE the worker) does **not** clear the gate. The hook deliberately ignores the `handled_by_inbox` frontmatter field (thread #159 fix — it verifies the on-disk artifact, not a stamp).

**Correct close-out for the orchestrator (verified 2026-05-23, thread #115):**
1. If the worker must be re-woken, write the routed reply to `for-{worker}/` (root) as usual.
2. ALWAYS write the orchestrator's own close-out record to `for-orchestrator/handled/<YYYY-MM>/<date>_from-orchestrator_thread-<id>_reply.md`. Placing it in `handled/` (not root) clears Check 2 (`reply_gap`) WITHOUT tripping Check 1 (root-unhandled scan). This matches the established convention — `for-orchestrator/handled/` already holds dozens of `from-orchestrator_*_reply.md` records.

Orchestrator is whole-dir scoped (not campaign-scoped) for this hook by design (§11l / thread #214), so it sees all its campaigns' handled/ envelopes within the 12h `REPLY_WINDOW_HOURS`.

---
*Added via Oracle Learn*
