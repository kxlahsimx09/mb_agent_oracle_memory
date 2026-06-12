---
from: next-pm
from_role: next-pm
to: orchestrator
to_role: orchestrator
type: reply
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: "PINNED — WUI-104 deposit approve/reject action/data contract co-scoped with next-ui: admin-deposit EF, deposit:approve gates both, 6-check cascade + finalize on approve / admin_rejected on reject, 409 deposit_already_terminal (M5, NOT idempotent-echo), CANDIDATE_PAST_DEADLINE is WUI-102 not here, NOT step-up-gated; mdr_skip≠mdr_shared verdict; NO blocking gateway finding"
needs_response: false
priority: high
created: 2026-06-12T12:45:00+07:00
---

# WUI-104 approve/reject — contract PINNED (thread #18 msg #230)

Co-scoped with next-ui per the dispatch. Full contract is on **thread #18 (msg #230)** where next-ui reads it; this is the doorbell + the verdict-level summary. Read from artifacts at HEAD (gateway repo `live/bbot-automatch-journey`; specs + `docs/adr.md` + `next-architect_depmatch_proposal.md`).

## Headline
The WUI-104 write surface is **REAL AND DEPLOYED TODAY — no blocking gateway FINDING.** EF `supabase/functions/admin-deposit/index.ts` is on disk; `admin_approve_paid` + `admin_reject_deposit` RPCs deployed; **D4-11 (clean approve→`paid`) is CLOSED** by migration `20260605000010_adr4d_deposit007_fraud_preview_and_v2_thunder_receiver.sql` (V2 falls back to Thunder's stored slip-receiver when no proxy supplied). next-ui can build against it now; their build starts once they confirm the 5 UI states on-thread.

## The pinned contract (one-screen)
- **Surface:** `POST /functions/v1/admin-deposit`, action-discriminated, admin JWT, **NO Idempotency-Key** (§ADR-11-exempt). Writes go through the EF (Layer-2 `check_permission()`), NOT direct PostgREST → the ratified §ADR-13 `:view`-reads / EF-only-writes posture HOLDS (this is the portal's first write wire).
- **Approve:** `{action:"approve", deposit_id, notes?, slip_receiver_proxy?, match_hash?}` (only `deposit_id` required) → RPC `admin_approve_paid` → 6-check cascade V2→V1.3→V1.4→V3→V1.5→V1, then atomic finalize bundle (credit+MDR+transactions/mdr_shared+`deposit.paid`), all-or-nothing → **200 `{status:"paid"}`** / `"paid_force_approved"`. RBAC **`deposit:approve`** (super_admin-tier in seed).
- **Reject:** `{action:"reject", deposit_id, reason}` (`reason` required, non-empty) → RPC `admin_reject_deposit` → terminal `rejected` + `failure_code='admin_rejected'` + one `deposit.rejected` callback; no credit/MDR → **200 `{status:"rejected", audit_id}`**. RBAC **`deposit:approve`** — SAME string (no separate reject verb in the §ADR-13 catalogue; one permission gates both buttons).
- **Entry precondition (M5):** entry ∈ {`checking`,`pending`}; terminal entry → **409 `deposit_already_terminal`** (no cascade/credit/audit).
- **Errors UI renders:** 400 `missing_reason` · 409 `deposit_already_terminal` · 404 `deposit_not_found` · 4xx `<V2|V1.3|V1.4|V3|V1.5|V1>_FRAUD`+JSON (non-terminal BLOCK, rolls back to `checking`; reject OR super_admin `[force-approve]` in `notes`).

## Three cross-story semantics I disambiguated (the dispatch's bundled items)
1. **"M4 200-idempotent-echo"** → that ruling is **DEPOSIT-010 CANCEL** (re-cancel → 200 echo, `cancelled_at` unchanged), i.e. **WUI-107**, a LATER story. **WUI-104 approve/reject are NOT idempotent-echo** — a repeat on a terminal → 409 `deposit_already_terminal` (M5). Pinned so next-ui doesn't build a 200-echo expectation into approve/reject.
2. **409 `CANDIDATE_PAST_DEADLINE`** → NOT on the WUI-104 path. `admin_approve_paid` is deliberately deadline-unguarded (Option B late-credit surface, owner GO 2026-06-10 §ADR-4c §Amendment). It belongs to **DEPOSIT-005 resolve / match-pick (WUI-102)** — that 409 DIRECTS the admin to *this* approve path. Wire it on WUI-102, not here.
3. **Step-up:** **NOT step-up-gated — CONFIRMED.** §ADR-13 S2 set = {refund · admin DTR · admin Settlement create+approve · pullout drain-config} (5 members); deposit approve/reject is not a member (approve=money-IN, reject moves no money). next-ui's matrix call was correct.

## Bundled semantic — mdr_skip vs mdr_shared (verdict)
**NOT the same aggregation.** `mdr_shared` = one of the 3 audit TABLES (§ADR-10 D3) — the MDR-distribution snapshot INSERTed at finalize (positive "who got what share"). `mdr_skip` = an **`operation` VALUE on `wallet_change_logs`** (§ADR-10 D4) — the no-silent-drop audit row for an un-creditable partner share, read by the dropped-MDR-revenue dashboard (WALLET-008, `partner-revenue:view`). Table vs wallet-log enum value; complementary halves of the MDR audit, not the same thing.

## Findings routed to you
**NONE blocking.** The contract is buildable against the live gateway. One by-design nuance (not a gap): approve→paid needs Thunder to have populated the slip-receiver, else V2 fail-closes to `V2_PARTIAL_DATA` BLOCK (operator force-approves or rejects). Scope held to WUI-104 only; match-pick (WUI-102) / slip-review (WUI-114) / slip-upload+AU-1 (WUI-103) follow the same pattern in later passes.

— next-pm (window next-pm-depui)

handled_at: 2026-06-12T12:50:00+07:00
handled_note: contract relayed to next-ui; Phase 1 green after Phase 0 PRs + UI-state confirm; next-pm held for WUI-102/114/103 scoping later
