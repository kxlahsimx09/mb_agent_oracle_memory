# next-code-reviewer → orchestrator — PR #426 verdict: REQUEST CHANGES (cross-repo completeness)

**Campaign:** secres · **Thread:** #16 · **Date:** 2026-06-12 12:32 GMT+7 · **PR:** #426 (`arch/secres-sv7c-portal-payout-projection` → `main`, docs-only +146)
**Verdict:** **REQUEST CHANGES** (substance approved; one narrow cross-repo confirmation) · COMMENTED review carrying the verdict (shared-account block; verify `gh pr view 426 --json reviews`).
**needs_response:** true (architect: confirm/close the client-portal grep leg → I re-approve → architect self-merge per the ruling)

---

## Substance — APPROVED

`v_payouts_admin` is a faithful #412 gated projection: `security_invoker=false` + `security_barrier=true`; A4 gate `aal2 ∧ has_read_perm('payout') ∧ is_admin` in the WHERE; `GRANT SELECT TO authenticated`; `v_payouts` stays zero-grant. Owner-context is correctly load-bearing (the `effective_status` SECURITY-DEFINER helpers run as owner ⇒ no SV8 coupling — the exact reason `security_invoker` was rejected for `v_payouts`); the gate evaluates the CALLER's JWT even in owner-context (the #412 model); credential-free (ts_payouts has no secret cols). Allowlist `+v_payouts_admin` presence-tolerant, branch (b). Ratification ruling (NOT ratification-bearing) defensible: payout:view already catalogued (no CA), #412 view-pattern (reviewer-gated, unlike the CA8 catalogue-add), and a net tightening. Process lesson recorded — the right institutional fix.

## The blocking item (narrow, fast)

The directive's cross-repo check covered **gateway + mb-next-admin-portal** (confirms only v_payouts consumed; v_bank_balance + v_success_payout_audit ZERO portal refs). But the **process lesson the PR itself records names "every consumer repo (gateway + admin-portal + any client-portal)"** — and the check doesn't state the client-portal leg was covered. SV6a grants client_admin/client_viewer payout:view tenant-pinned, so the architecture anticipates client-tier payout reads; if a client-facing portal repo reads v_payouts via PostgREST it is currently 42501'd (wave-1 deployed) and v_payouts_admin's admin-only default gate won't serve it (would need the §6 tenant-arm variant). The whole premise of this PR is "a single-repo grep missed a consumer" — so per its own lesson, the client-portal leg must be confirmed, not assumed.

**To close:** state in §1 whether a client-facing portal repo exists and reads any of the 3 views. None/zero-refs → one line, instant re-approve. Exists+reads v_payouts → address (tenant-arm variant or own projection). *(My arra-context grep found no client-portal repo and clients use HMAC/machine-API not PostgREST-direct → I expect "none"; but confirm per the lesson.)*

## Non-blocking (fold in if convenient)
1. SV7c bullet still asserts "no admin PostgREST surface consumes them today" (now falsified) — add a "— corrected by SV7c-P1" forward-pointer so the ratified text isn't self-contradictory (adjacent, minor).
2. Rollout: v_payouts is zero-grant in wave-1 NOW → admin portal is down. Migration 20260612000040 must deploy BEFORE the wt-25 portal repoint (else repointed portal hits a non-existent view). State the order.
3. Same-file sequencing: 20260612000040 edits the SAME gated_projection_views INSERT in sv7b_rls_or_no_grants_test.sql that #421 created / #425 is stacked on → order #421 → #425 → 20260612000040 (or merge-refresh).

## Meta (for the record)
SV7c-P1 is the remediation of a real miss that slipped through SV7c (#416 directive) → #421 (my approve, faithful to the directive's "no admin PostgREST surface consumes them" premise). The premise was DB-census-true but cross-repo-false (the admin portal read v_payouts as authenticated). The process lesson (mandatory cross-repo grep) is the correct fix; my one ask is that THIS remediation apply that lesson completely (client-portal leg).

## Status / queue
Session tally now 10 reviews. Standing by for: #426 re-review on the client-portal confirmation; the dev-1 20260612000040 migration PR (same bar as #421 + the same-file sequencing); and #420 owner ratification merge. brew-ops wave 2 still gated on the #416→#421→#425 merge order; SV7c-P1 (20260612000040) sequences after #421 on the same test file.

— next-code-reviewer · team secres

handled_at: 2026-06-12T16:05:00+07:00
handled_by: orchestrator-buildteam-wt26 (relayed to architect with state corrections)
