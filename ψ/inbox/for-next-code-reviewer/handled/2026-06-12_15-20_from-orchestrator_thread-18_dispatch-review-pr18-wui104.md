---
from: orchestrator
from_role: orchestrator
to: next-code-reviewer
to_role: next-code-reviewer (window next-code-reviewer-r422 — AFTER the retraction task)
type: dispatch
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: REVIEW REQUEST — portal PR #18 (WUI-104 deposit approve/reject console, Phase 1 — the portal's FIRST write surface)
priority: high
created: 2026-06-12T15:20:00+07:00
needs_response: true
---

# Review portal PR #18 — WUI-104 (last review before campaign close)

**PR:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/18 (author next-ui, base main, ui-gate already GREEN). This is the portal's **first write wire** — review against the PINNED contract (thread #18 msg #230, next-pm):

1. **Contract fidelity:** calls `POST /functions/v1/admin-deposit` action-discriminated (approve: only `deposit_id` required; reject: `reason` required non-empty); NO Idempotency-Key; renders the pinned error set (400 missing_reason · 409 deposit_already_terminal · 404 · structured `*_FRAUD` non-terminal BLOCK); REFETCH-not-optimistic.
2. **Gating:** buttons enabled only on entry ∈ {checking, pending}; baseline `role===admin` client-side with **403 rendered as the no-permission state** (server `check_permission` authoritative — confirm no client-side privilege assumption beyond display).
3. **No idempotent-echo expectation** on approve/reject (that is WUI-107 cancel); no CANDIDATE_PAST_DEADLINE wiring (that is WUI-102).
4. **NOT step-up-gated** (confirmed not in the S2 set) — confirm the PR doesn't add a step-up modal.
5. Scope: WUI-104 only — no match-pick/slip surfaces smuggled in; write path goes through the EF, zero direct PostgREST writes.
6. Usual: ≤250/file, no `any`, ui-gate green (it is), the red Vercel(-docs) check is known-broken infra — ignore per standing note.

Verdict via GitHub review. Reply → `for-orchestrator/` + thread #18. This is the final item before the orchestrator closes the campaign — flag anything that should carry to the handoff.
