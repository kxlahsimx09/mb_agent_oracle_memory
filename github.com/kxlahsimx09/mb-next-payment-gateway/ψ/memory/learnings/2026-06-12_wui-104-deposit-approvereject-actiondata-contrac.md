---
title: WUI-104 Deposit approve/reject action/data contract — PINNED by next-pm (thread 
tags: [next-pm, repo:mb-next-payment-gateway, next, progress, deposit, WUI-104, contract, admin-portal, rbac, idempotency]
created: 2026-06-12
source: thread #18 msg #230 (next-pm co-scope with next-ui); gateway specs deposit-slip-expire-slice.md §1.2 + deposit-fraud-cascade-slice.md + epic-deposit.md + adr.md §ADR-13/§ADR-10 + next-architect_depmatch_proposal.md
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# WUI-104 Deposit approve/reject action/data contract — PINNED by next-pm (thread 

WUI-104 Deposit approve/reject action/data contract — PINNED by next-pm (thread #18, co-scope with next-ui, 2026-06-12). Source: gateway artifacts at HEAD — docs/spec/deposit-slip-expire-slice.md §1.2, docs/spec/deposit-fraud-cascade-slice.md (DEPOSIT-007), docs/requirements/epic-deposit.md, docs/adr.md §ADR-13/§ADR-10, next-architect_depmatch_proposal.md.

SURFACE (portal's FIRST write wire): POST /functions/v1/admin-deposit, action-discriminated, body {action, deposit_id, …}. Admin JWT. NO Idempotency-Key (admin path §ADR-11-exempt). Writes go through the EF (Layer-2 check_permission), NOT direct PostgREST → holds §ADR-13 `:view`-reads-via-RLS / EF-only-writes posture. EF on disk (supabase/functions/admin-deposit/index.ts); RPCs deployed.

APPROVE: {action:"approve", deposit_id, notes?, slip_receiver_proxy?, match_hash?} (only deposit_id required) → RPC admin_approve_paid → 6-check cascade V2→V1.3→V1.4→V3→V1.5→V1, then atomic finalize (credit+MDR+transactions/mdr_shared+deposit.paid), all-or-nothing → 200 {status:"paid"} / "paid_force_approved". RBAC deposit:approve (super_admin-tier seed). D4-11 (clean approve→paid) CLOSED by migration 20260605000010 — V2 falls back to Thunder's stored slip-receiver when no proxy supplied, so UI need NOT capture a receiver field.

REJECT: {action:"reject", deposit_id, reason} (reason required, non-empty) → RPC admin_reject_deposit → terminal `rejected` + failure_code='admin_rejected' + one deposit.rejected callback; no credit/MDR → 200 {status:"rejected", audit_id}. RBAC deposit:approve — SAME string as approve (the §ADR-13 catalogue did NOT mint a separate reject verb; one permission gates both buttons).

ENTRY PRECONDITION (M5): entry ∈ {checking,pending}; terminal entry → 409 deposit_already_terminal (no cascade/credit/audit).

ERRORS UI renders: 400 missing_reason · 409 deposit_already_terminal · 404 deposit_not_found · 4xx <V2|V1.3|V1.4|V3|V1.5|V1>_FRAUD + structured JSON (non-terminal BLOCK, rolls back to checking; reject OR super_admin [force-approve] in notes; V2 fail-closed = V2_PARTIAL_DATA by design).

THREE CROSS-STORY DISAMBIGUATIONS (the dispatch bundled these):
1. "M4 200-idempotent-echo" = DEPOSIT-010 CANCEL (re-cancel → 200 echo, cancelled_at unchanged) = WUI-107, a LATER story. WUI-104 approve/reject are NOT idempotent-echo → 409 on terminal (M5). UI treats 409 as "already actioned → refetch", never silent retry.
2. 409 CANDIDATE_PAST_DEADLINE = NOT on WUI-104. admin_approve_paid is deliberately deadline-unguarded (Option B late-credit surface, owner GO 2026-06-10 §ADR-4c §Amendment). It belongs to DEPOSIT-005 resolve / match-pick (WUI-102) — that 409 DIRECTS admin to the approve path.
3. Step-up: deposit approve/reject NOT step-up-gated — confirmed. §ADR-13 S2 set = {refund · admin DTR · admin Settlement create+approve · pullout drain-config} (5 members); deposit approve/reject not a member (approve=money-IN, reject moves no money).

UI STATES (next-ui to confirm on-thread before build): button-enable on effective_status∈{checking,pending} ∧ holds deposit:approve; no step-up; refetch-not-optimistic (+ refetch checking-count DR8 badge); fraud-BLOCK UX renders structured block + advisory fraud_cascade_preview badge; reject returns audit_id.

mdr_skip vs mdr_shared VERDICT: NOT the same aggregation. mdr_shared = one of the 3 audit TABLES (§ADR-10 D3) — the MDR-distribution snapshot INSERTed at finalize (positive who-got-what-share; WUI-002 reads this). mdr_skip = an `operation` VALUE on wallet_change_logs (§ADR-10 D4) for un-creditable partner shares (partner inactive / wallet missing) — the no-silent-drop audit row, read by the dropped-MDR-revenue dashboard (WALLET-008, partner-revenue:view). Table vs wallet-log enum value; complementary halves of the MDR audit.

FINDINGS to orchestrator: NONE blocking — contract buildable against live gateway today. Scope held to WUI-104 only; WUI-102/114/103 follow same pattern later.

next-pm role note: this was a CONTRACT-PIN (relay ratified gateway behaviour to next-ui), not authoring — gateway behaviour read from artifacts; anything needing a gateway change would have been a FINDING routed back per dispatch §4 (none needed).

---
*Added via Oracle Learn*
