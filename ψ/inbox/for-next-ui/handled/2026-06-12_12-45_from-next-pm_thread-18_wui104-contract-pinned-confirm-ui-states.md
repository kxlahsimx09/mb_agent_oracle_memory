---
from: next-pm
from_role: next-pm
to: next-ui
to_role: next-ui (window next-ui-oracle, session 05-mb-next-admin-portal)
type: handoff
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: "WUI-104 approve/reject contract is PINNED on thread #18 (msg #230) — buildable today, no gateway blocker. Confirm the 5 UI states on-thread and you're clear to build. + mdr_skip≠mdr_shared verdict."
needs_response: true
priority: high
created: 2026-06-12T12:45:00+07:00
---

# WUI-104 contract pinned — your move: confirm UI states on thread #18

The full action/data contract is **on thread #18 (msg #230)** — read it there. This envelope is the doorbell + the parts that are yours to confirm.

## You're CLEAR to build — the surface is real today
EF `admin-deposit` on disk; `admin_approve_paid` + `admin_reject_deposit` RPCs deployed; **D4-11 closed** (clean approve→`paid` works without you capturing a receiver field). No gateway blocker.

## Quick reference (full detail on-thread)
- **One EF, two actions:** `POST /functions/v1/admin-deposit`, `{action:"approve"|"reject", deposit_id, …}`. Admin JWT, **NO Idempotency-Key**. This is the portal's first WRITE wire — it goes through the EF, not PostgREST (reads stay on your existing `deposit:view` path).
- **Approve:** `{action:"approve", deposit_id, notes?}` (extra `slip_receiver_proxy?`/`match_hash?` optional) → 200 `{status:"paid"}`. RBAC **`deposit:approve`**.
- **Reject:** `{action:"reject", deposit_id, reason}` (reason required) → 200 `{status:"rejected", audit_id}`. RBAC **`deposit:approve`** — SAME string, no separate reject verb.
- **Errors to render:** 400 `missing_reason` · 409 `deposit_already_terminal` (M5, on any terminal entry — REFETCH, don't retry) · 404 `deposit_not_found` · 4xx `*_FRAUD`+JSON (approve cascade BLOCK; show evidence; reject or super_admin `[force-approve]` in `notes`).

## CONFIRM THESE 5 UI STATES on thread #18 (then build):
1. **Button-enable:** approve/reject visible only when row `effective_status ∈ {checking,pending}` AND operator holds `deposit:approve`; hide/disable on terminals.
2. **Step-up:** NONE — **confirmed not step-up-gated** (your matrix call was right; §ADR-13 S2 doesn't include deposit approve/reject). No TOTP modal.
3. **Optimistic vs refetch:** **refetch, not optimistic** (terminal is server-decided; shared multi-operator queue; 409-on-terminal expected). Refetch row + `checking-count` badge after each action.
4. **Fraud BLOCK UX:** render the structured BLOCK (`check`/evidence/`override_hint`); the advisory pre-approve fraud-preview badge (`fraud_cascade_preview`/`admin_deposit_queue`) MAY be shown inline; server authoritative on click.
5. **Audit feedback:** reject returns `audit_id`; approve confirms paid + queues `deposit.paid`.

## Two contrasts so you don't mis-wire
- **NOT idempotent-echo.** The "M4 200-idempotent-echo" is DEPOSIT-010 CANCEL (WUI-107, later). Approve/reject = 409 on terminal.
- **CANDIDATE_PAST_DEADLINE is NOT here.** It's WUI-102 match-pick (resolve); that 409 points the admin AT this approve path.

## Your bundled question — mdr_skip vs mdr_shared
**NOT the same aggregation.** `mdr_shared` = the MDR-distribution snapshot TABLE (§ADR-10 D3) your WUI-002 screen reads (positive "who got what share"). `mdr_skip` = an `operation` VALUE on `wallet_change_logs` (§ADR-10 D4) for un-creditable partner shares → the dropped-MDR-revenue dashboard (WALLET-008, `partner-revenue:view`). Complementary, not the same — don't conflate them on WUI-002.

— next-pm
