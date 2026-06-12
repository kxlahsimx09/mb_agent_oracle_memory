---
title: CORRECTION to the SV7b entity read-view pattern (PR #412 R1, 2026-06-11): owner-
tags: [next-dev, repo:mb-next-payment-gateway, next, rls, security-barrier, read-view, projection, sv7b, a4, gotcha, decision, review-fix, portal, entity-read-views, thread-13]
created: 2026-06-11
source: PR #412 commit 5981111; reviewer R1; supabase/migrations/20260611000300_entity_read_views_portal.sql; docs/spec/entity-read-views-slice.md
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# CORRECTION to the SV7b entity read-view pattern (PR #412 R1, 2026-06-11): owner-

CORRECTION to the SV7b entity read-view pattern (PR #412 R1, 2026-06-11): owner-context admin read-views MUST be created `WITH (security_invoker = false, security_barrier = true)` — the security_barrier is NOT optional.

Supersedes the template in 2026-06-11_admin-entity-read-views-pattern-for-sv7b-zero-gran.md (which showed only security_invoker=false). The reviewer (next-code-reviewer, PR #412) requested security_barrier=true on all three views and it is correct: a plain non-barrier owner-context view lets the Postgres planner push caller-supplied PostgREST quals AHEAD of the embedded aal2∧has_read_perm∧admin gate by cost heuristic. Then "ungated user → 0 rows" rests on qual-ordering luck, and a leaky/erroring pushed-down predicate (e.g. ?col=eq.x filters, division, type-casts) could become a row-content ORACLE on the projected columns. security_barrier=true forbids pushing non-leakproof caller quals below the view's own quals → the gate always runs first. This replicates the guarantee base-table RLS gives v_deposits for free (RLS quals are security-barrier by construction) — it is the price of deviating to owner-context+embedded-WHERE. InitPlan once-per-query is preserved and PostgREST reads are unaffected; minor cost is caller quals not pushed into the base scan (negligible for small entity tables).

CORRECTED TEMPLATE (use this verbatim for v_users / v_roles / any future SV7b-locked entity read-view):
  CREATE OR REPLACE VIEW public.v_<entity>
      WITH (security_invoker = false, security_barrier = true) AS
  SELECT <non-secret cols only>
  FROM public.<base>
  WHERE (SELECT public.auth_aal2())
    AND (SELECT public.has_read_perm('<resource>'))
    AND (SELECT public.auth_db_is_admin());
  GRANT SELECT ON public.v_<entity> TO authenticated;
  INSERT INTO role_permissions (role,permission) VALUES ('super_admin','<resource>:view') ON CONFLICT DO NOTHING;

To re-apply the barrier to an ALREADY-deployed view (db push won't replay a recorded migration while the PR is in review): ALTER VIEW public.v_<entity> SET (security_barrier = true); then verify pg_class.reloptions = {security_invoker=false, security_barrier=true}.

---
*Added via Oracle Learn*
