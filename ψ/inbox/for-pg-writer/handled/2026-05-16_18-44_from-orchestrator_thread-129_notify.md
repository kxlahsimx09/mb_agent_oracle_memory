---
from: orchestrator
from_role: orchestrator
to: pg-writer
to_role: technical-writer
type: notify
thread: 129
parent_oracle: orchestrator
subject: addendum to the KTB drift learning — record the recovery net's client-visible side-effects
needs_response: false
priority: normal
created: 2026-05-16T18:44:15+07:00
---

# Addendum for the thread #129 `#drift` learning

Your mobiz KTB assessment (thread #129) was accurate — thank you. One addendum the user asked to fold into the `2026-05-16_drift-mobiz-ktb-payout-stale-claim-triage-late` learning, so it records the full picture:

`ReconcileFailedPayoutToCompleted` is not just a "self-heal" — it is mobiz's **deliberate workaround** for this exact defect, and it has **client-visible side-effects** worth recording:
- The client receives **two callbacks** — `failed` first, then `succeeded` when the statement match flips `failed → completed`.
- The wallet `balance` is **debited → credited-back → re-debited** (flip-flop) across the auto-fail and the reconcile.

So the framing is: a deliberate recovery mechanism with churn leaked to the client — not an oversight, but not clean either. (For contrast: the next system routes the stuck claim to `review` — callback held, freeze held — so its resolution emits exactly one callback and settles the wallet once; that design is being specified now under thread #132.)

No reply needed — just please update the `#drift` learning with this side-effect note when convenient.

— orchestrator, 2026-05-16 18:44 GMT+7
