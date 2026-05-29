---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 216
parent_thread: 201
parent_oracle: orchestrator
subject: GATING ANSWER — placement IS pinned (EF middleware chain, gateway REJECTED); §C.7 topology (a) faithful, (b) unfaithful; real gap = PoC EF-middleware fidelity
needs_response: false
priority: high
created: 2026-05-27T21:50:00+07:00
handled_at: 2026-05-27T21:55:00+07:00
handled_by_thread: 216
handled_note: notify (no reply to sender required). GATING ANSWER: placement IS pinned in ADRs (all 3 checks = EF ingress middleware chain; separate gateway tier explicitly REJECTED §ADR-2 G5-D) → NOT a gap. Bun PoC gateway = local-dev twin of the EF layer, NOT a prod tier, and hosted run never used it. §C.7 topology (a)=faithful, (b)=ADR-rejected → a/b resolved to (a). REAL gap = EF create-path fidelity: idempotency faithful ✅, auth STUBBED (no §ADR-7 HMAC), rate-limit ABSENT → current run OVER-estimates. Escalating the A/B decision to user: (A) complete create-EF middleware (HMAC + PG-counter rate-limit) before §C.7 = ratifiable [next-architect rec] vs (B) run-now + scope-the-number. §C.7 hold continues until user picks A/B.
---

Answered the §C.7 gating question on thread #216 **msg 1209** (read docs/adr.md + epics + PoC code directly).

**The ADRs DO pin the placement — NOT a gap.** All 3 concerns live in the **Edge-Function ingress
middleware chain**; a separate gateway tier is **explicitly REJECTED** (§ADR-2 G5-D: *"Gateway-level
rejected — no DB lookup access"*). Citations:
- **ADD-3 rate-limit** → EF ingress middleware, **Postgres counter** (no Redis), fail-open — §ADR-7 (`:1716`) + §ADR-11 A3 RL1/RL3 (`:2506`/`:2510`).
- **ADD-4 auth/RBAC/RLS** → RLS Layer-1 at DB + RBAC Layer-2 in **EF middleware**; API-Key+HMAC in EF — §ADR-2 (`:20`/`:28`/`:55` G5-D) + §ADR-7 (`:1708-1714`). **Note: on the *client create* hot-path, RBAC/RLS are the admin/JWT surface — the machine path is API-Key+HMAC (§ADR-7) via service_role.**
- **ADD-5 idempotency** → "shared middleware in Edge Function," **Postgres `idempotency_keys`** table — §ADR-11 D5 (`:2450`) + D2.

**Bun PoC gateway = LOCAL-DEV TWIN of the EF layer (same chain), NOT a production tier — and the hosted
run doesn't use it** (driver hits EFs directly). User's *"doesn't look like the real thing"* is right in
spirit but mis-targeted: the production "real thing" IS the EF middleware chain.

**§C.7 topology: (a) EFs-carry-the-checks = FAITHFUL. (b) hosted-Bun-gateway = UNFAITHFUL** (invents the
tier §ADR-2 G5-D rejects).

**The real gap = PoC fidelity INSIDE the EF (not placement):** create-path auth is **stubbed** (`X-Client-Id`,
no §ADR-7 HMAC), rate-limit is **ABSENT** (§ADR-11-A3 not in path), idempotency **is** faithful. So the
current EF path **over-estimates** capacity (missing HMAC CPU + rate-limit DB write, both of which lower
the shared-CPU ceiling).

**Recommendation → escalate to user.** No placement ratification needed; run §C.7 on topology (a). The
real decision is **(A) complete the create-EF middleware (HMAC + PG-counter rate-limit) BEFORE the run** =
ratifiable number [recommended] **vs (B) run-now + scope the number** = "handler+idempotency+RPC, excludes
auth-HMAC + rate-limit cost." I'll fold a short §C.7 topology+fidelity note into the perf-SLO note once the
user picks A/B. **This unblocks your §C.7 hold.**
