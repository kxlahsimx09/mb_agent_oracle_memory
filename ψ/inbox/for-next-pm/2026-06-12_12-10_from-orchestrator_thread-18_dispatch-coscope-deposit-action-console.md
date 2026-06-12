---
from: orchestrator
from_role: orchestrator
to: next-pm
to_role: next-pm (window next-pm-depui)
type: dispatch
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: CO-SCOPE — Deposit Operator Action Console (WUI-104 first): pin the action/data contract with next-ui
priority: high
created: 2026-06-12T12:10:00+07:00
needs_response: true
---

# Co-scope the Deposit Operator Action Console (owner GO 2026-06-12, thread #18)

Owner approved the next admin-portal arc: turn the read-only `/deposit` screen into an operator action console. Build order WUI-104 approve/reject (M) → WUI-102 match-pick → WUI-114 slip-review → WUI-103 slip-upload+AU-1. next-ui builds; YOUR job is the contract.

## Task — pin the WUI-104 action/data contract with next-ui (both of you on thread #18)

1. **Story truth first**: `epic-deposit-ui.md` WUI-104 AC (+ next-product-writer's epic text) vs the ratified gateway behaviour — approve/reject semantics per DEPOSIT-004/005/010 (incl. the M4 200-idempotent-echo and 409 CANDIDATE_PAST_DEADLINE rulings) and the depmatch Option B admin-approve-only path.
2. **Write contract**: which EF(s)/RPCs the console calls (the portal currently has ZERO write wires — this is the portal's first write surface): names, payloads, error shapes the UI must render (409/422/expired/already-actioned), idempotency expectations, and the RBAC string each action requires (per the ratified §ADR-13 catalogue — `:view` reads vs EF-only writes posture must hold).
3. **Confirm with next-ui** the UI states that fall out (button-disable rules, optimistic vs refetch, audit feedback) — their build starts only after this contract is pinned on the thread.
4. **Scope discipline**: WUI-104 ONLY for this pass. Match-pick/slip stories follow the same pattern later. Anything requiring a gateway change (new EF/view/permission) is a FINDING routed back to me — do not commission gateway work yourself.
5. One open semantic from the coverage matrix while you're in the epic docs: **is `mdr_shared` the same aggregation as WUI-002's `mdr_skip`?** (next-ui flagged; one paragraph verdict is enough.)

## Reply
→ `for-orchestrator/` + thread #18: the pinned contract (or blockers/findings) + the mdr_skip verdict.
