---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 141
parent_thread: 141
subject: re — integration-test vs. doc audit complete; 5 discrepancies (3 contradiction / 1 drift / missing-coverage list)
needs_response: true
priority: high
created: 2026-05-17T09:13:00+07:00
handled_at: 2026-05-17T09:20:00+07:00
handled_by_thread: 141
handled_note: campaign #141 aggregated (msg 393) + closed; audit report-only complete, remediation flagged to user
---

# Audit complete — integration tests vs. payout requirement docs

Full discrepancy report posted to **thread #141** (message 392). Audited ~55
payout-relevant test cases — 10 `poc/4a` pgTAP substrate specs + 3
`poc/integration` probes (payout-reconcile, bot-restart-claim,
cron-fallback-dispatch) + the smoke `assertions.ts` payout assertions —
against `epic-payout.md` PAYOUT-001…009, §ADR-4a, §ADR-9, §ADR-10 AM2/AM4.
PR #135 is already merged into `main`; audited at current HEAD.

## 5 discrepancies — summary

**Contradictions (3):**
1. `bot-restart-claim.ts:206 & :264` assert one `callback_queue` row after
   `sweep → review` — but §PAYOUT-004 AC#2 / §ADR-9 §Reconciliation CS1 make
   `review` callback-silent (zero rows). **Test wrong** — stale, predates
   thread #132/CS4 (`42d6713`) which dropped the `mark_review` callback
   INSERT; the probe now also contradicts the live substrate and would fail.
2. `bot-restart-claim.ts:199-200` + `poc/4a/tests/08_*.spec.sql` assert
   NULL-`bank_transaction_id` stuck claim → `review`; §PAYOUT-004 AC#1 still
   says → `failed`. **Doc wrong** — AC#1 stale vs §ADR-4a §Amendment
   2026-05-16 SA1 (every stuck claim → `review`). §PAYOUT-003 AC#5 is stale
   the same way and self-contradicts PAYOUT-003's own edge case.
3. `poc/4a/tests/10_*.spec.sql:34-38` asserts `mark_failed` *increases*
   wallet `balance`; §PAYOUT-003 / §ADR-10 AM2 say a failed payout releases
   the freeze only (`balance` untouched). **Test wrong** — `poc/4a` runs a
   standalone pre-§ADR-10 balance-debit/refund schema (systemic, tests
   02/08/10).

**Drift (1):**
4. `assertions.ts:51-52` ledger reconciliation keys on `withdrawal_debit` /
   `withdrawal_refund`; §ADR-10 AM4 + the deployed substrate use
   `payout_settle` / `payout_unfreeze`. Local `poc/integration` substrate
   diverges from the hosted one. **Test/local-substrate side stale.**

**Missing coverage:** §PAYOUT-008 entirely (auto-cancel — 9 ACs);
§PAYOUT-009 amount-mismatch / flag-off-fail-closed / race-no-op ACs;
§PAYOUT-007; §PAYOUT-001 error paths (payout-create idempotency +
validation rejections); §PAYOUT-002 partner MDR fan-out.

## Notes for routing

- Findings 1 & 2 both trace to the thread #128/#132 amendments not being
  swept fully — finding 1 needs **next-impl** (update the stale probe),
  finding 2 needs **next-writer** (PAYOUT-004 AC#1 + PAYOUT-003 AC#5 stale
  text). User decides remediation per dispatch — flagged here, not actioned.
- No fixes applied. Report-only, per dispatch.

— next-impl, 2026-05-17 09:13 GMT+7
