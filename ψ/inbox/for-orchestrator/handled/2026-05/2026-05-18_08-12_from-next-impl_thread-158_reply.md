---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 158
parent_thread: 158
parent_oracle: orchestrator
subject: reply — PAYOUT-003 re-verified: verdict (a), deployed substrate is stale vs §ADR-9 §Amendment 2026-05-16
needs_response: false
priority: normal
created: 2026-05-18T08:12:00+07:00
---

PAYOUT-003 failed/rejected re-verified. Full report on thread #158 (msg 471).

Verdict: (a). §ADR-9 — as currently ratified, including §Amendment
2026-05-16 (thread #120 verdict) — ALREADY agrees with the user: payout has
NO `rejected` terminal; `failed` is the sole unsuccessful-payout terminal;
bank refusal + insufficient funds resolve to `failed`; `mark_rejected` "will
not be authored" (RC4/RC5). Verbatim quotes in the thread reply.

My earlier msg-469 "PAYOUT-003 doc-wrong" verdict was WRONG and I corrected
it: I read the deployed substrate as source-of-truth and missed §ADR-9
§Amendment 2026-05-16. PAYOUT-003 doc is CORRECT.

The conflict is deployed-substrate drift: the bot-queue-mark EF + the
mark_rejected RPC + the ts_payouts CHECK + run_hosted_assertions' rejected
counters were all built on the superseded 2026-05-13 TS3 and never
reconciled to §Amendment 2026-05-16. Not doc-wrong, not ADR-vs-intent —
code/substrate stale.

Flagged: PR #151's G3 probe payout_003_ac5_mark_rejected_reentry_noop
exercises the stale mark_rejected path; it needs rework to re-report
mark_failed as part of the reconciliation. PAYOUT-002 AC#7 (mark_success)
half is unaffected.

Changed nothing this pass (verification + mapping only, per brief). Fix
owner: next-impl substrate reconciliation, future pass — sits adjacent to
parked D1; recommend bundling. Awaiting your scheduling call.

Reply on thread #158.

# handled_at: 2026-05-18T07:53:34+07:00
# handled_by_thread: 158
# handled_note: PAYOUT-003 verdict (a) - doc+ADR correct, deployed substrate stale; relayed to user for reconciliation scheduling
