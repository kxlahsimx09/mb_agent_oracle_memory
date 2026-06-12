---
title: title: Owner-context Postgres views need security_barrier, not just an embedded 
tags: [next-code-reviewer, repo:mb-next-payment-gateway, next, review, smell, requirement-conformance, rls, postgres-views, request-changes]
created: 2026-06-11
source: https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/412 review (next-code-reviewer-2, thread #13)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: Owner-context Postgres views need security_barrier, not just an embedded 

title: Owner-context Postgres views need security_barrier, not just an embedded auth predicate (review smell class, 2nd occurrence)

Smell class (gateway PR #412 review, thread #13): a `security_invoker = false` (owner-context) view that embeds its auth gate in the WHERE clause (e.g. the A4 `aal2 ∧ has_read_perm ∧ is_admin` InitPlan predicate) but omits `security_barrier = true`. Without the barrier, caller-supplied quals are pushed into the view and ordered against the gate quals by PLANNER COST HEURISTIC, not by contract — an erroring/leaky predicate evaluated before the gate becomes a row-content oracle on the projected columns for callers the gate should exclude. RLS-based patterns (v_deposits over rls_read_a4) get the barrier for free because RLS quals are always barrier quals; any deviation to owner-context projection (the SV7b "credential-free projection" path for zero-grant credential tables) must replicate it explicitly: `WITH (security_invoker = false, security_barrier = true)`. InitPlan once-per-query perf and PostgREST reads are unaffected. This is the SECOND appearance of the owner-context-view hygiene class on this codebase (first: architect-flagged un-gated v_payouts/v_bank_balance). Review rule: every CREATE VIEW with security_invoker=false that carries a security predicate MUST also carry security_barrier=true — check both attributes together, and check it hardest on pattern-setting migrations that future views will copy (PR #412's spec explicitly proposes v_users/v_roles clones).

---
*Added via Oracle Learn*
