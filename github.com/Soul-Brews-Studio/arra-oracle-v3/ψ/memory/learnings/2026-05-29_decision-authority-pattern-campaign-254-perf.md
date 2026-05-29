---
title: **Decision-authority pattern: campaign #254 (perf-harness fidelity → CF gateway 
tags: [orchestrator, decision-authority, user-pattern, auto-dispatch, escalate, campaign-254, perf-cf-gateway, honest-uncertainty, principle-2a, routing-confidence, repo:arra-oracle-v3, fleet]
created: 2026-05-29
source: orchestrator wt-21 campaign #254 — 2026-05-22→2026-05-29 multi-week perf-CF-gateway arc
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Decision-authority pattern: campaign #254 (perf-harness fidelity → CF gateway 

**Decision-authority pattern: campaign #254 (perf-harness fidelity → CF gateway PoC → substrate feasibility) — what the user auto-approved vs what they gated.**

User AUTO-APPROVED (orchestrator dispatched without re-asking):
- Implement-all-5-ADDs after audit returned the ranked list (msg 1202)
- Substrate hygiene Round 1+2 after the pg_stat_statements smoking gun was identified
- brew-ops deploys when next-impl PRs landed (consistent every leg)
- Run dispatches when substrate READY (always greenlit after smoke-green)
- CF account bootstrap proceeding (after the user manually provisioned + handed creds)

User EXPLICITLY GATED at each transition:
- Compute upgrades (free → Micro: user did themselves; Micro → not done; user controls $)
- Choice of (A)+(B) fidelity-first for the EF-middleware completion vs run-as-is (escalation msg 1212)
- Architectural pivot: declined the i/ii/iii lane-ownership options + directed the **architecture change** (relocate to CF gateway tier) instead — stronger signal than any offered option
- Authorization for next-impl to cross into next-dev/gateway-impl lanes "for THIS PoC scope" (the lane-cross was an explicit user GO)
- Merge of every PR (§9; orchestrator never merged)
- KV cap blocker resolution: (a)+(b) both ratified together
- LIMIT 500 grounding: ratified the next-impl recommendation after the dpay evidence

PATTERN: user is doing engineering-grade review of every dispatched leg. Sharp catches across the campaign:
- KV cap (1k/day Free) anticipated from brew-ops's earlier "28k writes" number BEFORE brew-ops's escalation surfaced (msg 1243)
- "Bun PoC doesn't look like the real thing" caught the topology mismatch that drove the §ADR-2 Amendment (msg ~1207)
- "current ใช้ no-LIMIT + 1-hour window" hypothesis on sweep_unmatched_statements — verified correct from git history (msg 1236)
- Cadence "should stay 1/min" reverting my brief-side misread (msg 1233-revert)
- KV per-key throttle hypothesis-friendly question that led to the wrangler-tail finding (sharp before-the-fact wonder)

CONSEQUENCE for routing-confidence: this user has HIGH bar for "verdict ships." Honest-uncertainty (flagging "I'm not 100% sure, but…") is rewarded; confident-wrong verdicts cost rework (my msg-1228 CF Analytics over-clean framing required correction). Adopt principle-2a rigorously: relay questions to owners, don't render technical verdicts from orchestrator session.

FOR FUTURE ROUTING: when user asks status, ALWAYS check state-file truth not inbox surface. When dispatching for high-stakes analysis, consider parallel-agent reconciliation (separate learning) on the analysis leg.

---
*Added via Oracle Learn*
