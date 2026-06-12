---
title: WUI-104 deposit approve/reject — PINNED build contract (next-pm thread #18 msg #
tags: []
created: 2026-06-12
source: thread #18 msg #230 (next-pm pinned contract) + msg #238 (next-ui confirm); for-next-ui/2026-06-12_12-45 envelope
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# WUI-104 deposit approve/reject — PINNED build contract (next-pm thread #18 msg #

WUI-104 deposit approve/reject — PINNED build contract (next-pm thread #18 msg #230, confirmed by next-ui msg #238). This is the portal's FIRST write surface. Build target for Phase 1 "Deposit Operator Action Console".

SURFACE: POST /functions/v1/admin-deposit (action-discriminated, admin JWT, NO Idempotency-Key — admin path §ADR-11-exempt). Writes go through the EF (Layer-2 check_permission), NOT direct PostgREST. The queue+detail stay on the existing deposit:view read path (PostgREST+RLS). Holds §ADR-13 (:view reads / EF-only writes).

APPROVE: {action:"approve", deposit_id, notes?, slip_receiver_proxy?, match_hash?} (only deposit_id required). RPC admin_approve_paid. RBAC `deposit:approve`. Runs 6-check fraud cascade V2→V1.3→V1.4→V3→V1.5→V1 BEFORE atomic finalize → on pass: client net credit + partner MDR + transactions/mdr_shared + deposit.paid callback, all-or-nothing. 200 {status:"paid"} (clean) / "paid_force_approved" (override). D4-11 CLOSED — UI need not capture a receiver (V2 falls back to Thunder's stored slip-receiver).
REJECT: {action:"reject", deposit_id, reason} (reason REQUIRED non-empty). RPC admin_reject_deposit. SAME RBAC `deposit:approve` (one perm gates BOTH buttons — no separate reject verb). → terminal rejected + failure_code='admin_rejected' + exactly one deposit.rejected callback (failureMessage=reason); NO credit/MDR. 200 {status:"rejected", audit_id}.
PRECONDITION (M5): both require entry status ∈ {checking,pending}; terminal → 409.

ERROR SHAPES the UI renders: reject empty reason→400 missing_reason (inline block); approve/reject on terminal→409 deposit_already_terminal (REFETCH, never retry); not found→404 deposit_not_found (refetch); approve fraud block→4xx <V2|V1.3|V1.4|V3|V1.5|V1>_FRAUD structured JSON (check, evidence, override_hint) non-terminal rolls back to checking → reject(reason) OR super_admin force-approve via literal [force-approve] in notes (V2_PARTIAL_DATA = by-design fail-closed); RBAC deny→403 (buttons hidden).
NOT step-up-gated (approve=money-IN, reject moves no money; §ADR-13 S2 step-up set is refund/DTR/settlement-create+approve/pullout-config only). NOT idempotent-echo (that's WUI-107 cancel). CANDIDATE_PAST_DEADLINE is NOT here — it's WUI-102 match-pick (approve is the deadline-unguarded escape-hatch it points at, §ADR-4c).

5 UI STATES (next-ui confirmed): READY(actionable: buttons only when {checking,pending}∧deposit:approve; reject needs reason) · SUBMITTING(no optimistic flip) · RESOLVED(terminal paid / rejected+audit_id, then REFETCH row+checking-count badge DR8) · FRAUD-BLOCK(non-terminal, render structured block) · STALE/CONFLICT(409→refetch). REFETCH-not-optimistic (shared multi-operator surface).

OPEN ITEM: portal gates only by entity_type client-side, not resource:action perms — baseline button-gate on role===admin + treat server 403 as no-perm state (check_permission authoritative); tighten to precise deposit:approve gate IF the JWT exposes that claim (asked next-pm/next-dev).</pattern>
<parameter name="concepts">["next-ui","repo:mb-next-admin-portal","next","WUI-104","deposit-action-console","contract","admin-deposit-EF","phase-1","thread-18","co-build"]

---
*Added via Oracle Learn*
