---
from: orchestrator
from_role: orchestrator
to: next-ui
to_role: next-ui
type: dispatch
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: OWNER DECISIONS — GO on 3 arcs (sequenced) + mock-gating + browser pass approved; PR #14 APPROVED awaiting owner merge
priority: high
created: 2026-06-12T12:10:00+07:00
needs_response: true
---

# Owner decisions on your §Asks (2026-06-12) — all four answered

1. **PR #14 — reviewer APPROVE landed** (GitHub-verified). Portal PRs are outside the gateway §9a carve-out → **owner merges**; link handed to the owner. Hold your worktree/branch cleanup until it merges.
2. **Next arc: owner picked THREE (sequenced by me, one lane):**
   - **Phase 0 — NOW (small PRs): UX-debt sweep + mock-gating.** WUI-001 four login failure-states (S) + **gate/label all 15 MOCK screens as "preview / not live"** (owner picked the gate option — settlement/topup stay deferred and now must be visibly non-live) + the globals.css/detect advisories (S). Ship as 1–2 reviewer-gated PRs.
   - **Phase 1 — Deposit Operator Action Console**, starting **WUI-104 approve/reject (M)**. next-pm is being dispatched NOW to co-scope the action/data contract with you (thread #18) — engage them as soon as they ping; lift AC from next-product-writer's epic text. Build starts after the contract is pinned, not before.
   - **Phase 2 — QUEUED: Auth admin surfaces** (WUI-009 unlock/disable → WUI-006 roles-assign → WUI-008 create-user live-wire). Do NOT start until Phase 1's first slice (WUI-104) is merged — one lane, no thrash.
3. **Settlement/topup: stay DEFERRED** (no greenlight). Your mock-gating in Phase 0 is the honest treatment.
4. **Authenticated browser pass: APPROVED.** brew-ops is being tasked to provision an MFA-capable admin login slot on sinuw — you'll get the slot reference on this thread. Run the pass when it lands (can interleave with Phase 0/1).

## Reply
→ `for-orchestrator/` + thread #18: Phase-0 PR URL(s) when up; contract-pinned confirmation when you and next-pm settle WUI-104 scope.
