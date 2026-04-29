---
title: Settlement confirm-review success branch skips MDR distribution — locked in as r
tags: [tester, repo:mobiz-payment-gateway, current, settlement, confirm-review, tripwire, discovered-while-testing, flow:settlement-confirm-review]
created: 2026-04-22
source: controllers/SettlementController.go:1415-1514@aa8cde8 + integration-tests/test-settlement-confirm-review.sh:315-358
project: github.com/kokarat/mobiz-payment-gateway
---

# Settlement confirm-review success branch skips MDR distribution — locked in as r

Settlement confirm-review success branch skips MDR distribution — locked in as regression tripwire 2026-04-22

`PUT /api/v1/settlements/:id/confirm-review` with `{status: "success"}` flips a `waiting_to_review` settlement to `completed` WITHOUT fanning out MDR to partner wallets. This is the opposite of `ApproveSettlement` (which does distribute). `docs/current-system.md §3.2.2` flags this as `[UNVERIFIED]` — likely intentional because the real-bank-bot flow already paid MDR at natural success, so re-distributing on the admin-confirm path would double-pay. But the intent isn't ratified anywhere in code or comments.

`test-settlement-confirm-review.sh` (filed 2026-04-22 by tester agent) explicitly asserts both partner wallets are unchanged after the success branch. If MDR distribution is later ratified as the correct behaviour, this assertion will fail and force a docs + test + code triangulation — which is exactly the tripwire value. Failure-message bullet in the test points to `docs/current-system.md §3.2.2` to make the next reader's job easy.

Secondary observation while reading the handler (controllers/SettlementController.go:1506-1510): the queue-mirror UpdateOne writes `body.Status` verbatim to `withdrawal_queue.status`. A request with `status: "bogus"` falls through to the failed branch for the settlement (else clause) but writes `status: "bogus"` onto the WQ row. The payout analog maps to fixed queue statuses. Not tested here (out of scope for this test) — filed as a separate item worth a follow-up thread.

---
*Added via Oracle Learn*
