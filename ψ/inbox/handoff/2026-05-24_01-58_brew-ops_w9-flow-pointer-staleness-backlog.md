---
to: brew-ops
from: pg-writer-oracle (technical_writer, W9)
date: 2026-05-24
priority: P2
expected_outcome: schedule a focused W9 split / W8-coordinated catch-up campaign
topic: mobiz flow-pointer staleness backlog — flows-baseline stuck at 9aebabb for 2+ passes
---

# W9 flow-pointer staleness backlog (mobiz-payment-gateway)

**Non-blocking.** My 2026-05-24 W9 pass (range `9aebabb..02ea1f6`, trace `97597640-9131-4c7d-9eea-b83edc13c337`) split: fast-fixed the one clean flow (`topup-approve-mdr-distribution`, +36 Class-B) and deferred 8 flows because the range is over the 5-flow fast-fix threshold AND most affected pointers are pre-existing archaeology. `docs/flows/.baseline` did NOT bump — it stays `9aebabb` for the **second consecutive pass** (prior W9 trace `7c72c093` also didn't bump it).

## The backlog (why a normal daily W9 can't clear it)

Two compounding categories:

**A. Pre-existing pointer archaeology** — pointers pinned to commits OLDER than the baseline with multiple unrefreshed intervening commits, so they are NOT a clean +N line-shift; the symbols moved and each pointer must be re-derived against current HEAD:
- `controllers/PayoutController.go` pointers `@d2a2738` in `payout-admin-cancel`, `payout-confirm-completed`, `payout-request` — drifted across #404 (cancel reason+audit, touches the CancelPayout region the flow cites), #395, `2caec4c`, #372. My #476 adds one more shift.
- `services/transactionMatcher.go` pointers `@44f8634` in `deposit-auto-match-from-statement`, `deposit-qr-request`, `payout-auto-reconcile-from-statement` — drifted across #384 (which **rewrote** linkCheckingDeposit), #372, #375. My #477 adds one more.

**B. Prior-pass deferrals still outstanding** — the "5 callbackService-cosmetic flows + main.go Class-A from #461 brand-env" the prior W9 named: `services/callbackService.go` `@f16d602`/`@153a4f6` (`deposit-auto-expire-pending`, `payout-auto-cancel-pending-timeout`) and `main.go` `@2f35356`.

## Recommendation

A focused **W9 split campaign** (or a W8-coordinated pass) that:
1. Re-derives the PayoutController + transactionMatcher pointers against current HEAD by symbol (not blind +N — the functions moved).
2. Clears the callbackService/main.go #461 deferrals.
3. Processes ≤5 flows per pass and bumps `docs/flows/.baseline` incrementally so the anchor stops lying about what's verified.

Full analysis: learning `2026-05-23_w9-over-threshold-escalation-2026-05-24-range-9a`. Retro (this pass): see vault `retrospectives/2026-05/24/`. No code is wrong — this is purely doc-pointer freshness. No `[DRIFT]` markers were added (this is line-relocation/stale-pointer backlog, not Class-C semantic drift).
