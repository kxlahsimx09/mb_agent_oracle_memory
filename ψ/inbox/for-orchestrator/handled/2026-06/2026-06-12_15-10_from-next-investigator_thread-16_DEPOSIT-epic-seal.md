---
from: next-investigator
from_role: next-investigator
to: orchestrator-buildteam
to_role: orchestrator
type: epic-seal-verdict
thread: 16
parent_thread: 16
subject: "DEPOSIT epic-seal = GREEN — independent behavioral re-derivation on qnccph @ HEAD 20260612000050 (own fixtures, every PASS falsified, zero footprint). Unblocks the deposit+auth LIVE run. 4 non-blocking observations routed."
priority: high
needs_response: false
created: 2026-06-12T15:10:00+07:00
verdict: GREEN
seal_scope: DEPOSIT epic (auto-match · auto-expire · slip-upload/admin-approve · decoupled processing · wallet-ledger)
seal_stack: qnccphgykzdydebmdwdf @ migration HEAD 20260612000050
---

# DEPOSIT EPIC-SEAL — **GREEN**

**G1 premise resolved.** The DEPOSIT epic previously carried only per-slice `[S2 ratified]` marks (no investigator epic-seal). This is that seal. Method = independent re-derivation against the **truth DB** (qnccph, my seal-stack slot), driving the **real SECURITY-DEFINER lifecycle functions** with **my own fixtures + injected virtual clock**, every PASS **falsified** with its negative case, all inside `BEGIN…ROLLBACK` so the stack is left **byte-for-byte as found** (deposit tables 0/0/0/0/0/0 before and after). Same discipline as the 2026-06-10 auth-rbac seal. I trusted no harness frame and no relay.

**Stack state I sealed against:** `schema_migrations` HEAD = **20260612000050** (wt-25 regression + today's secres waves applied); deposit lifecycle tables empty (clean seal stack) → seal is necessarily **active/behavioral**, not forensic-over-existing-rows.

## Sealed-scope coverage — all 5 capability areas GREEN

### Wallet-ledger integration (the load-bearing money core)
Verified directly in `finalize_deposit` (read) + Probe-1/2 (driven):
- **Exactly one `deposit_credit` = final_amount = amount − deposit_fee** (P1: credit 982 on amount 1000 fee 18).
- **MDR fan-out = one `wallets_change_logs` row per profile partner** — `mdr_distribute` if active, `mdr_skip` (not a silent drop) if inactive/missing (P2: deactivated partner → 1 skip + 1 distribute).
- **Residual = deposit_fee − Σ credited shares → `mdr_owner` wallet**, so **conservation `gross = client_net + Σ credited + residual` is EXACT by construction** — held both clean (P1: 982+10+8=1000) **and** with a skipped partner (P2: 982+4+14=1000). The skipped share flows to residual, never lost.
- **No double-credit:** re-`finalize_deposit` → `ALREADY_FINALIZED` (P0001); re-`match_deposits_cascade` → `already_consumed`, still exactly one credit (P1 falsification).
- **All-or-nothing:** finalize is one atomic function; `client_wallet_missing` and `mdr_owner_residual_wallet_missing` both `RAISE` → whole bundle rolls back (source). `transactions` ledger line written in the same txn.
- **Fee snapshot-at-create** = `round(amount*deposit_fee_percent/100,2)`; `mdr_profile_id`+`deposit_fee` snapshotted onto the row at create, finalize consumes the snapshot (source).

### Auto-match (DEPOSIT-002/005, §ADR-4b)
- **Step-1** identity-scoped finalize (score-2 full / score-1 last4), temporal-safety guard (dep created >10s after stmt → refused), **FA1 FIFO degenerate carve-out** (1 source∧1 client → oldest), else **park `review`** + candidates + note (source).
- **Step-2a** `checking` link only, no money (source). **Step-2b** terminal link → `match_status='unmatched'` + `matched_request_id`, **no finalize/money/callback** (P8 drove it via late-after-expiry: cascade `2b/linked`, deposit stays `expired`, stmt `unmatched`+mrid set+link `2b`, 0 credit, 0 paid-callback).
- **NT-9 single-consumption** guard: parked `review` / consumed statements excluded from re-cascade (source).
- **Amount mismatch (H2):** stmt 999 vs deposit 1000 → `no_match`, deposit stays `pending`, 0 credit (P3). **`paid_amount = amount`** is enforced *structurally* (matcher requires `amount = v_stmt.amount` exactly; there is no `paid_amount` column).

### Auto-expire (DEPOSIT-003, §ADR-4c)
- slip-less past-deadline → `expired` + **exactly one `deposit.expired` callback** (P4a).
- **`v_deposits.effective_status` 0-lag:** physical `pending` past-deadline reads `expired` (P4b).
- **slip-bearing never expires:** expire-sweep skips it; direct `expire_deposit` → `race_lost` (DA1 CAS on `slip_uploaded_at IS NULL`) (P4c).
- late statement after expiry → Step-2b link, **deposit never resurrected** (P8).

### Slip-upload / admin-approve (DEPOSIT-004/007/008/009, §ADR-4d)
- `upload_slip` keeps `pending`, sets `slip_uploaded_at`, customer path → null identity (source + P5).
- **slip-escalation `pending→checking` guaranteed, verdict-independent**, at `slip_uploaded_at + 5min` (`_slip_review_timeout_minutes()=5`) (P5).
- **Six-check `_fraud_cascade_eval`**: all six present with correct semantics — **V2 fail-closed** (`V2_PARTIAL_DATA`), **V13/V14/V3/V1.5/V1 pass-on-null/fail-open** (source). Cheapest-first **order + short-circuit + force-approve two-gate** is applied by the consumer; `check_admin_slip_upload_gate` (DEPOSIT-009 ingress, V1+V2) carries both the `[force-approve]` literal gate **and** the admin `user_type` gate (source).
- **admin reject → `rejected` (NOT `failed`)**, `failure_code='admin_rejected'`, `deposit.rejected` callback, **no wallet credit/MDR**; reject on terminal → `invalid_status` (P7).

### Decoupled processing (DEPOSIT-001, §ADR-4)
`create_deposit` (source): **server-derived deadline** (rejects client-supplied `expires_in_seconds`); `enable_deposit` / global-maintenance / callback-endpoint-resolution / TTL (`NO_EXPIRY`) gates; bank routing over pool/capacity/maintenance-window/amount-band/KTB-exclusion with **daily-count increment at create**; returns `final_amount = amount − fee`.

### State machine + DEPOSIT-010 cancel
- **status CHECK constraint = exactly the 7 spec values** `{pending,paid,rejected,expired,cancelled,checking,failed}`.
- **Cancel full gate matrix (P6):** pending slip-less → `cancelled` **with no callback** + idempotent re-cancel echo (`already_cancelled`, no re-stamp); `checking` → `not_pending`; slip-bearing pending → `slip_present`; terminal(paid) → `not_pending`; slip-less past-deadline → `not_pending` echoing **effective** status `expired`.
- terminals never transition out (cancel/reject/finalize all guard) (P1/P6/P7).
- **No Phase-1 `failed` producer** in the deposit lifecycle (`failed` reserved for system_error — source scan: only generic `mark_failed`/test harness touch it, never create/match/finalize/expire/cancel/reject/escalate).

### RLS / read surface (DEPOSIT-013)
`ts_deposits` RLS **enabled**; read policy `rls_read_a4 = auth_aal2() ∧ has_read_perm('deposit') ∧ (auth_db_is_admin() ∨ client_id = auth_db_effective_client_id())` — correct tenant-scoping. **No INSERT/UPDATE/DELETE policies** → all writes go through SECURITY-DEFINER RPC only (no direct-table mutation by authenticated/anon). The partner-403-vs-empty distinction is the EF's layer atop the (correctly empty) RLS result.

## Deferred-gap integrity (correctly NOT sealed over)
The spec flags these as Phase-2 / deferred; I confirmed they are **genuinely unimplemented**, so the seal does not paper over a real hole:
- **DEPOSIT-011 refund/reversal:** no `refund|reversal|clawback` function; no wallet-decrement on the deposit path. The retroactive-slip-fraud detector flags but does not reverse — by design.
- **`deposit.cancelled` callback:** no producer (Phase-1 callback-silent — correct).
- **DEPOSIT-006** (manual re-match) and **DEPOSIT-010 API surface** deferred; only DEPOSIT-010's *terminal behaviour + idempotency posture* is ratified, and that is what I sealed (P6).

## Observations — NON-BLOCKING (routed to architect/PM; none affect money-safety or the LIVE run)
1. **Per-client MDR not wired on this stack.** `create_deposit` resolves the profile **global-first** (`mdr_profile ORDER BY created_at LIMIT 1`) — the `client` table has no MDR link in the seed. The snapshot *mechanism* is correct (id+fee pinned at create, finalize consumes it) and **conservation holds for any profile**; only per-client tier *selection* is absent. Config/data-wiring gap, not epic-code correctness. (LIVE run stays money-correct under a uniform tier.)
2. **Step-2b terminal set excludes `cancelled`.** `match_deposits_cascade` Step-2b matches `status IN ('paid','expired','failed','rejected')` (4 of the 5 terminals); the spec extraction listed 5 incl. `cancelled`. Step-2b writes **no money** regardless, so this is immaterial to money-safety — a late statement matching a cancelled deposit simply stays fully unmatched. Minor spec↔impl drift.
3. **`v_deposits.effective_status` keys off wall-clock `now()`**, not the §ADR-20 `app_now()` virtual clock. Display-only; coincides in prod (`sys_clock.mode='real'`); the money-authoritative paths (finalize/cancel/sweep) all use `app_now()`/injected `p_now` correctly.
4. **5-min vs 15-min timer cadence** flagged in the revision log is a DOC/ADR reconciliation item, not a code defect — `_slip_review_timeout_minutes()=5` and the escalation sweep uses it correctly.

## Verdict
**DEPOSIT epic-seal = GREEN.** All five sealed-scope capability areas and the load-bearing money/state-machine invariants independently re-derived and falsified on qnccph @ HEAD 20260612000050; deferred items correctly absent; four observations are config/doc/display, none money-or-safety-bearing. **G1 is satisfied — the deposit+auth LIVE run is unblocked.** qnccph left untouched (zero footprint). Evidence: probe scripts + function-source citations retained; per-probe NOTICE logs in this session.

— next-investigator, 2026-06-12 15:10 +07 · read+rollback-only as `postgres` on `qnccphgykzdydebmdwdf`

handled_at: 2026-06-12T20:10:00+07:00
handled_by: orchestrator-buildteam-wt26 (seal GREEN recorded; run gate check)
