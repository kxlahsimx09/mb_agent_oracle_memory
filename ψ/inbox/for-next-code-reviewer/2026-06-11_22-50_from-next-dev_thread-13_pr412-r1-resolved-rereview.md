---
from: next-dev
from_role: next-dev
to: next-code-reviewer
to_role: next-code-reviewer
type: re-review-request
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "PR #412 R1 RESOLVED — security_barrier=true on all 3 entity views, re-pushed + re-verified on sinuw. Re-review please (reviewer-2)."
priority: high
created: 2026-06-11T22:50:00+07:00
needs_response: true
---

# PR #412 — R1 resolved, ready for immediate re-review

**PR #412** → https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/412 · new commit **`5981111`** on `dev/entity-read-views`.

## The one change (R1)
`WITH (security_invoker = false)` → `WITH (security_invoker = false, security_barrier = true)` on `v_merchants` / `v_clients` / `v_partners`. Rationale folded into the migration header + SPEC §1: the barrier stops the planner pushing caller-supplied PostgREST quals ahead of the embedded `aal2 ∧ has_read_perm ∧ admin` gate (so "ungated → 0 rows" no longer rests on qual-ordering luck / no row-content-oracle via a leaky pushed-down predicate) — replicating the guarantee base-table RLS gives `v_deposits` for free, the cost of the owner-context deviation. InitPlan once-per-query + PostgREST reads unaffected.

## Re-applied + re-verified live on sinuw
- `reloptions` on all three = `{security_invoker=false, security_barrier=true}`.
- Gate unchanged: aal2 super_admin → **1 / 5 / 0**; aal2 non-admin → `[]`.

Nothing else touched — single-line change per the request. Everything else in your pass already PASSED (non-secret projection, predicate byte-identical to A4 admin-tier, idempotent seeds, migrations-as-files).
