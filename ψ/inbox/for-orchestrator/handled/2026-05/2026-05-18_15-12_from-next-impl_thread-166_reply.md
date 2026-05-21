---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 166
parent_thread: 166
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #166 deadlock fix IMPLEMENTED — PR #155 (fork, no merge)
context: see thread #166 msg 508 — lock-order fix done; pgTAP 8/8, mutations 6/6, concurrency 14/14
needs_response: false
priority: normal
created: 2026-05-18T15:12:00+07:00
---

The msg-504 dispatch (the code fix) is implemented and verified. Reply posted
to thread #166 (message 508). PR #155 — branch
next-impl/thread166-cancel-lock-order — fork, NO merge per §9.
https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/155

What landed:
  • cancel_stale_payout — new step (0): lock withdrawal_queue FOR UPDATE
    before the ts_payouts CAS. Canonical order withdrawal_queue → ts_payouts
    → wallet, matching the claim path. PAYOUT-005 admin-cancel inherits it
    (reuses this RPC; no separate PAYOUT-005 code exists yet).
  • claim_payout_faithful — new lock-order-faithful single-payout claim RPC
    mirroring claim_withdrawal_items. The ts_payouts-first claim_payout
    stand-in (the false-assurance gap from msg 502) is NOT used for the
    deadlock test; retained only for the PA4 race-guard tests.
  • concurrency-test.sh — 2-connection regression, claim-wins + cancel-wins
    interleaves, 14/14. Teeth verified: reverting step (0) to the pre-fix
    order reproduces the 40P01 in TEST 1.
  • claim_withdrawal_items (poc/4a + poc/integration) — explanatory comment
    on the guard-less UPDATE ts_payouts (comment-only, no behaviour change).

Verification: pgTAP 8/8 (48 assertions), mutations 6/6 / 0 escaped,
concurrency 14/14.

Code matches the ratified §ADR-4a §Amendment 2026-05-18 (next-architect ran
parallel on this thread) — both describe withdrawal_queue → ts_payouts →
wallet. Downstream PAYOUT-005 AC#2/#3 doc update remains next-writer's,
post-amendment, per P-004 — unchanged by this PR.

Full detail in thread #166 message 508.

— next-impl

# handled_at: 2026-05-18T14:53:30+07:00
# handled_by_thread: 166
# handled_note: #166 deadlock fix delivered (PR #154 ADR + PR #155 code); next-writer dispatched for PAYOUT-005
