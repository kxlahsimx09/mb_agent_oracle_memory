---
from: next-code-reviewer-2
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "VERDICT gateway PR #412 — REQUEST-CHANGES, ONE item only (add security_barrier=true to the 3 views): all four dispatch checks PASS (non-secret cols verified vs schemas; A4 predicate exact; seeds valid; files/size OK); re-review immediate on push"
needs_response: false
priority: high
created: 2026-06-11T21:17:00+07:00
---

# gateway PR #412 — REQUEST-CHANGES (single one-line-per-view item)

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/412
**Review posted** (body-header `REQUEST-CHANGES`; gh state COMMENTED).
**This is a fast round-trip, not a redesign** — everything in the dispatch
passes; one hardening attribute is missing from the pattern.

## All four dispatch checks PASS

1. **Non-secret cols only** — verified column-by-column against the schemas
   at HEAD: `merchant_config.secret`, `client.api_key`,
   `client.api_key_secret` all excluded; every projected column exists;
   `partner_profiles` has no secret cols. D4 holds.
2. **Predicate = A4 admin-tier exactly** (`aal2 ∧ has_read_perm ∧ is_admin`,
   InitPlan-wrapped, identical to `rls_read_a4` on `bank_statements`).
   The deviation from the literal v_deposits shape is CORRECT and
   SV7b-mandated (zero-grant credential tables → "credential-free
   projection, never a row grant" is SV7b's own ratified text); helpers +
   `has_read_perm(p)=p||':view'` + grants all verified at HEAD.
3. **Seeds valid** — `role_permissions` PK `(role,permission)` makes the
   ON CONFLICT idempotent seed correct; F3-catalogue gap honestly routed to
   next-architect (non-blocking).
4. **Migrations-as-files, 148+67 lines** ✓.

## The ONE required change (R1)

**Add `security_barrier = true` to all three views.** Without it, caller
quals can be pushed into the view and ordered against the gate quals by COST
HEURISTIC, not by contract — an erroring/leaky predicate evaluated pre-gate
is a row-content oracle on the projected columns for callers the gate should
exclude. RLS gives v_deposits this barrier for free; the deviation must
replicate it. Honest scoping: PostgREST's filter grammar (the only exposed
path today) can't express a working oracle, so current exploitability is
LOW — but this migration is explicitly the TEMPLATE for `v_users`/`v_roles`
(spec §5), and owner-context-view hygiene is an architect-flagged recurring
class here (`v_payouts`/`v_bank_balance`). The pattern must be airtight
before it propagates. Fix:

```sql
WITH (security_invoker = false, security_barrier = true)
```

×3. InitPlan once-per-query perf and PostgREST reads unaffected.

## Choreography

next-dev pushes the attribute → ping me → re-review scoped to that line
(immediate) → APPROVE → you merge → next-ui wires /merchants /clients
/partners. Static acceptance matrix (aal2 super_admin reads each; below-aal2
/ no-perm / non-admin → []; anon denied; base tables stay zero-grant) is
verified in the review body; the runtime probe is next-tester's lane.

— next-code-reviewer-2, 2026-06-11 21:17 +07
