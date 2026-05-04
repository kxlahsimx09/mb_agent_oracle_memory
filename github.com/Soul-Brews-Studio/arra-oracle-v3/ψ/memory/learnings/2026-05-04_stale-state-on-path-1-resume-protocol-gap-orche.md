---
title: # Stale-state-on-Path-1-resume protocol gap (orchestrator)
tags: [protocol-gap, stale-state, Path-1-resume, state-refresh, redirect-handle, orchestrator-discipline, thread-correction, user-go-targeting]
created: 2026-05-04
source: orchestrator thread #69 msg 177 (correction posted 2026-05-04 16:42)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# # Stale-state-on-Path-1-resume protocol gap (orchestrator)

# Stale-state-on-Path-1-resume protocol gap (orchestrator)

**When**: 2026-05-04 (surfaced in #69 msg 176 → corrected in msg 177; activation in sub #74 proceeded on the corrected target)
**Where**: orchestrator parent-thread sweep; specifically the seam between an agent's state-refresh envelope and a user GO that has already landed.

## The gap

When a Path-1 (long-running parent thread) is being resumed, an agent (here: brew-ops at 16:37) may post a **state-refresh envelope** that lags the actual user-GO target. Concretely:

- User GO landed at #69 msg 175 (16:01) — the "refined unified proposal."
- Agent's 16:37 state-refresh envelope was framed as a redirect handle to **msg 176** — but msg 176 was a stale framing that did not reflect the user's 16:29 GO on msg 175.
- Without a correction, dispatch (sub #74) would have executed against msg 176's misframed scope.

## Why it happens

- State-refresh envelopes are written from the agent's last cached read of the parent thread; if a forward message landed between cache and send, the redirect handle points at the wrong msg.
- Path-1 resumes are exactly when caches are stalest — the parent thread has accumulated messages while the agent was elsewhere.

## The protocol fix (orchestrator discipline)

**Before dispatching** to a sub-thread on a Path-1 resume, the orchestrator MUST:

1. Read the parent thread's most recent user message (the GO target).
2. Compare the GO target's msg number against the framing of any state-refresh envelope posted by the receiving agent.
3. If they diverge: post a correction message to the parent thread (e.g. "msg N is the forward-go; disregard msg M redirect framing") BEFORE cutting the dispatch envelope.
4. The dispatch envelope's `context:` field then references both the corrected target AND the correction message itself, so the receiving agent can verify on read.

This is what #69 msg 177 did — corrected msg 176's misframing and named msg 175 as the canonical forward-go target. Sub #74 was dispatched cleanly off the correction.

## Why it matters

Skipping the comparison step risks the entire sub-thread executing against stale scope. The cost of the comparison is one read of the parent thread; the cost of dispatching against a stale redirect is a full sub-thread of wrong work + retroactive correction.

## Tag the rule

**"Compare-then-dispatch on Path-1 resume."** Embed in orchestrator skill discipline alongside the §11k pull-protocol (which handles convergence; this rule handles divergence at dispatch time).

## Refs

- Origin: orchestrator thread #69 msg 175 (forward-go) → msg 176 (stale framing) → msg 177 (correction).
- Sub-thread that ran cleanly off the correction: #74 (closed 2026-05-04 17:11 GMT+7).
- Protocol siblings: AGENTS.md §11k (pull-protocol convergence); AGENTS.md §11h (escalate after 3 rounds).

---
*Added via Oracle Learn*
