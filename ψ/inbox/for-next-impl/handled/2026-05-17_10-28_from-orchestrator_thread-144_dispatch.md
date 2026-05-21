---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementer
type: dispatch
thread: 144
parent_thread: 144
parent_oracle: orchestrator
subject: Audit #141 remediation phase 2 — findings #3 + #4 + #5
priority: normal
needs_response: true
created: 2026-05-17T10:28:47+07:00
---

# Audit #141 remediation phase 2 — findings #3, #4, #5

The user authorized remediation of the remaining findings from your own thread #141 audit. All three are yours (POC test layers + coverage). Findings #1 and #2 already landed (mb-next #140, #141).

## Finding #3 — `poc/4a` pre-§ADR-10 wallet model

`poc/4a` tests **02 / 08 / 10** assert a balance-debit/refund wallet — e.g. `10_mark-failed-runs-4-step-bundle-atomically.spec.sql:34-38` expects `mark_failed` to *increase* wallet `balance` by amount+fee. The ratified model (§ADR-10 AM2) is **freeze-release**: a failed payout does `frozen -= amount+fee` and never touches `balance`. The `poc4a` schema (`_helpers.sql:44`) is pre-§ADR-10 (debits `balance` at enqueue, no `frozen` column).

**Embedded decision — your call to recommend:** either (a) align the `poc/4a` schema + tests to the §ADR-10 freeze/settle model, or (b) formally retire the pre-§ADR-10 `poc/4a` layer (the §ADR-10 model is already exercised correctly by the `poc/integration` probes, so `poc/4a`'s wallet assertions may be redundant dead weight).
- If you land on **(a) align** — do it.
- If you land on **(b) retire the layer** — that deletes a test layer; **post the recommendation on thread #144 and pause for the user** before removing it.

## Finding #4 — wallet-op name drift

`poc/integration` substrate (`src/schema/02_entry_points.sql:171`, `src/rpc/withdraw/lifecycle_rpcs.sql:33`) and `tests/assertions.ts:51-52` use the old op names `withdrawal_debit` / `withdrawal_refund`. §ADR-10 AM4 + the deployed `supabase/migrations` substrate use `payout_freeze` / `payout_settle` / `payout_unfreeze`. Reconcile the local `poc/integration` substrate + assertion to the §ADR-10 AM4 taxonomy. Clear correction — just do it.

## Finding #5 — missing test coverage

Spec'd requirements with no test. Add coverage:
- **§PAYOUT-008** (auto-cancel) — entire story, 9 ACs (`cancel_stale_payout`, `v_payouts.effective_status`, `payout_auto_cancel_enabled` fail-closed flag, claim/cancel race).
- **§PAYOUT-009** — amount-mismatch → no auto-resolve + alert; flag-off / unreadable-flag fail-closed; concurrent / already-resolved race no-op.
- **§PAYOUT-007** — resend terminal callback.
- **§PAYOUT-001** error paths — idempotency (no-key → `IDEMPOTENCY_KEY_REQUIRED`; reuse-different-body → 409) + validation rejections (`PAYOUT_DISABLED`, `AMOUNT_OUT_OF_RANGE`, `INSUFFICIENT_FUNDS`, `UNSUPPORTED_DEST_BANK`).
- **§PAYOUT-002** — partner MDR fan-out (partner wallet credit + per-partner `wallets_change_logs`).

## Scope

#3 and #4 are small corrections — one PR. **#5 is substantial — phase it; do not cram one mega-PR** (e.g. §PAYOUT-008 its own PR, etc.). Each PR off `main`, do not merge — the user merges.

`needs_response: true` — reply on **thread #144** with the PR numbers + the #3 decision, then archive this envelope (§11d).

— orchestrator, 2026-05-17 10:28 GMT+7
