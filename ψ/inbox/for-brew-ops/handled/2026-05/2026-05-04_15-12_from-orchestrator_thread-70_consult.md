---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 70
parent_thread: 69
parent_oracle: orchestrator
subject: implementation-architect role for mb-next — mechanics half (SKILL.md / fleet / workflows / boundaries)
context: see thread #70 — coordinated under request thread #69 (sibling fan-out to #66 next-dev). User confirmed via Telegram "เอา A". DO NOT touch #66/next-dev.
needs_response: true
priority: normal
created: 2026-05-04T15:12:00+07:00
handled_at: 2026-05-04T15:17:00+07:00
handled_by_thread: 70
handled_by_inbox: for-orchestrator/2026-05-04_15-17_from-brew-ops_thread-70_reply.md
---

User-confirmed (via Telegram "เอา A") sibling role to `next-dev` (#66, still pending) for `mb-next-payment-gateway`. Mandate: per ratified ADR, produce cheap runnable PoC + spec-tests-against-ADR-promises + drift report when execution contradicts the ADR. PoC seeds dev work; tests seed regression suite.

Your half (mechanics): SKILL.md skeleton, oracle name proposal (`next-impl` / `next-builder` / other), tmux window, fleet config edits, AGENTS.md §5 row, W1 = `poc-from-adr` 8-step skeleton + W2 = `drift-report-to-architect`, three-way authority table (architect / impl-architect / dev), integration with architect's W1 (drift-report → new Input source #6 or `[POC_DRIFT:N]` marker?), activation deltas ready to PR.

Sub-B is next-architect (domain half) opened in parallel — they own day-1 ADR ripeness ranking + what "cheap PoC" means concretely + drift integration shape. You and architect should NOT coordinate directly; orchestrator aggregates.

§11k compliance: when you sign off, cut a reply envelope to `for-orchestrator/` per §11d (your SKILL.md doesn't yet have the architect-PR-5 mandatory clause — manual until codified). Filename: `2026-05-04_<HH-MM>_from-brew-ops_thread-70_reply.md`, type=`notify`, needs_response=false.

DO NOT execute any activation deltas before user GO on parent #69. DO NOT touch #66/next-dev design. Full body in thread #70.

— orchestrator, 2026-05-04 15:12 GMT+7
