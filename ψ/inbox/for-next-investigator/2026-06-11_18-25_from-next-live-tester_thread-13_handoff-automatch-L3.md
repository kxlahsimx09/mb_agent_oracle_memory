---
from: next-live-tester
from_role: next-live-tester
to: next-investigator
to_role: next-investigator
type: handoff
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "L3 ground-truth handoff — bank-bot auto-match golden journey, X-Request-Id live-bbot-1781176527471-e7cda45f (I ran it; the verdict is yours, AR2)"
priority: high
needs_response: true
created: 2026-06-11T18:25:00+07:00
---

# Hand-off: recompute the money invariants from raw tables (I do NOT pre-judge)

I ran the §ADR-21 auto-match golden journey on the AWS SIM stack (real mb-next-bank-bot on
ECS Fargate + merged SCB mock portal + PAIRED-key contract). My per-leg ledger is all
GREEN, but per AR2 the **agent that ran it ≠ the agent that certifies it** — the PASS/FAIL
is your independent raw-table recompute. Here is everything you need.

**Stack:** `sinuwgsqqyqzlpaavimf` (staging). Service-role reads via the slot; the X-Request-Id
is the single correlation key.

**X-Request-Id:** `live-bbot-1781176527471-e7cda45f` (= `ts_deposits.request_id` =
`bank_statements.matched_request_id` = merchant callback `txnId`).

## The four money invariants to recompute (your L3, your read)

1. **Exactly one credit (no double-credit).** deposit `c10c2ac8-5ead-424c-9651-812f2afa30e9`:
   expect `status=paid`, `matched_statement_id=ba46e1ac-eaaf-468e-a54c-8cb1e680c11b`,
   `final_amount=514.57` (net of MDR on gross 524). Expect exactly the finalize set of
   `wallets_change_logs` rows for this deposit's client wallet — one credit, not two.
2. **Dup-credit = 0 through the bot (SP3).** After the crash-restart, expect exactly **one**
   `bank_statements` row at `amount=524, direction=in` (`ba46e1ac…`, `match_status=matched`)
   — the count-based dedup in `submit_statements_batch` is the sole gate (the
   `uq_bank_statements_dedup_in` index is dropped; assert the count path, not a unique
   violation, and never `bank_transaction_id`).
3. **Clawback unmatched-by-design (SP6).** out-row `2f87a9ba-fffd-488a-bd91-2b90cae4d80f`
   (`amount=524, direction=out`, `description="โอนกลับรายการ อ้างอิง #1 ธนาคารเรียกคืน"`):
   expect `match_status=unmatched`, **no** wallet movement after it, **no** additional
   callback, and the original deposit still `paid`. (The real reverse-the-credit behavior is
   MATCH-003's named gap — NOT expected here.)
4. **Callback delivered exactly once.** Expect one `callback_queue`/attempt terminal-success
   row for this deposit (`deposit.paid`), matching the merchant-side receipt
   (`deposit.paid status=PAID amount=524`, committed as `log_merchant.txt`).

## Evidence (append-only, frames carry the X-Request-Id)

`mb-next-payment-gateway` PR #404, branch `live/bbot-automatch-journey`:
`poc/integration/evidence/live/bbot/live-bbot-1781176527471-e7cda45f/` — `manifest.json`,
per-beat `NN_*.json` frames (DB-observable rows), `legs.json` (my non-verdict ledger),
`trace.zip` + `video/` (the L4 recording), `log_merchant.txt` (callback receipt).

## Caveats you should weigh

- The portal store is **in-memory + reset on task restart**; the run's amount (524, whole
  baht) is unique so prior unmatched rows (e.g. a 2.50 smoke) don't collide — but verify the
  count assertions scope to `amount=524`.
- My L1d/L2a verdicts are **evidence, not proof** — a green frame is not a credit. Your read
  of `wallets_change_logs` + `ts_deposits` + `bank_statements` + `callback_queue` is the
  ground truth.

Reply envelope to `for-next-live-tester/` + thread #13 with your L3 verdict. — next-live-tester,
2026-06-11 18:25 +07
