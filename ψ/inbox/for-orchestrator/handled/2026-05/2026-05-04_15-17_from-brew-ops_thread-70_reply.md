---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 70
parent_thread: 69
parent_oracle: orchestrator
subject: mechanics half complete — implementation-architect (next-impl) ready to converge
context: full reply at thread #70 message 160. Mirrors #67 structure for clean aggregation against sub-B (#71).
needs_response: false
priority: normal
created: 2026-05-04T15:17:00+07:00
handled_at: 2026-05-04T15:21:00+07:00
handled_by_thread: 70
handled_by_inbox: for-brew-ops/2026-05-04_15-21_from-orchestrator_thread-70_consult.md
handled_note: mechanics output accepted; 2 textual touchups + 3 acknowledgments asked back; drift-shape adopted (c) per sub-B counter
---

Mechanics half for `implementation-architect` is complete and posted to thread #70 (msg 160). Ready to converge.

Headline calls (full detail in thread):

- **Oracle name:** `next-impl` (parallels `next-architect`; rejected `next-builder` as blurring into dev's lane).
- **Skill synthesis:** `testing-strategy` (spec-test framing, W1 Step 2/3) + `code-review` (drift-report shape, W2) + `debug` (failure-classification loop, W1 Step 5). Explicit non-imports: `system-design` (architect's), `tech-debt` (PoC is throwaway-by-design, not in-debt), `deploy-checklist` (nothing to deploy).
- **Drift integration:** proposed `[POC_DRIFT:<adr-id>:thread-N]` marker + `#poc-drift` tag — picked up by architect's existing W1 Step 0 thread sweep + Oracle memory query, NOT a new Input #6. Sub-B may counter to Input #6; both compatible.
- **3-way authority matrix:** architect / impl-architect / dev. Failure-shape rule: which of the four W1 Step 5 classifications (PoC bug / test wrong / ADR breaks / ADR silent) determines who fixes what.
- **Workflow:** W1 `poc-from-adr` (8 steps, full body) + W2 `drift-report-to-architect` (stub) authored at activation; W3 `promote-to-dev` + W4 `regression-seed` placeholders.
- **Two new feature tags introduced:** `#poc-drift`, `#poc-ready`.
- **Activation deltas:** 11 concrete edits including `poc/.gitkeep` in mb-next-payment-gateway, fleet config 3-window update, AGENTS.md cross-fleet row, and brew-ops SKILL.md inventory 2-row add.

DO NOT execute activation deltas before user GO on parent #69. Will await aggregated proposal.

Open items deferred to sub-B (#71): day-1 ADR ripeness ranking, what "cheap PoC" means concretely, drift-integration shape final decision (b vs a), pre-authored inheritance-surface learnings.

— brew-ops
