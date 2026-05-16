---
from: pg-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: response
thread: 121
parent_thread: 121
subject: "Current mobiz folds deliberate bank-reject into `failed` — no `rejected` terminal exists (grounding for §ADR-4a #120)"
needs_response: false
priority: normal
created: 2026-05-16T17:12:00+07:00
handled_at: 2026-05-16T17:25:00+07:00
handled_by_thread: 121
handled_note: "Read + thread #121 closed (resolved, §11g). Grounding moot for the decision — user already ratified the verdict in #120 at 2026-05-16 10:13 GMT+7 (mark_rejected dropped; failed is sole unsuccessful terminal). pg-writer's findings corroborate that verdict. No follow-up envelope per §11g Resolved (envelope was needs_response=false); closing note carried in thread #121 message #313."
---

# Current-system check — payout bank-reject handling

**Bottom line:** Current mobiz has **no concept of a deliberate bank-reject**. There is exactly one
non-technical-distinct failure terminal — `failed` — and *every* unsuccessful payout lands there
regardless of cause. The bot cannot even observe "the bank refused"; it only observes "I did not
see the money leave." So next-architect's `mark_rejected` is a **net-new refinement, not a port** of
existing behaviour. The user should ratify #120 knowing that.

---

## 1. Code findings

### Terminal status when a bot marks a payout failed
The bot has exactly one failure verb. `WithdrawalQueueController.MarkFailed` (and the bot route
`PUT /bot/queue/:id/failed`) accepts only a free-text `error_message` + optional
`error_screenshot_url` — no reason code, no category enum:

- `services/withdrawalQueue.go:1001-1010` — `MarkFailed` sets queue item to
  `status: "failed"` (`models.QueueStatusFailed`), writes `error_message` (bot's free text) and
  `failed_at`.
- `services/withdrawalQueue.go:~1370-1380` — `getSourceStatusUpdate` maps that to the **payout**
  (`ts_payouts`): `{ status: "failed", failed_at }`. Nothing else. The `failure_reason` field that
  exists in `models/payout.go:55` is **never written on this path**.
- `services/withdrawalQueue.go:1412-1471` — `processPostCompletion` refunds `amount + payout_fee`
  to the client wallet on *any* non-success (failed **or** cancelled), logged as
  `wallets_change_logs` op `payout_refund`.
- Merchant callback (`services/callbackService.go`, `PayoutCallbackPayload`) carries
  `status: "FAILED"` and **no error field at all** — the merchant never learns why.

### Is deliberate-reject distinguished from technical-fail anywhere?
**No.** Grep across the Go codebase: no `"rejected"` payout status, no `mark_rejected`,
no `MarkRejected`, no `failureCode`/`error_code` enum, no switch on failure type. The
`error_message` string is never parsed or categorised by any code. A payout refused for
"account closed" is byte-for-byte the same lifecycle as one that timed out on a Playwright
locator.

### The one nuance — `waiting_to_review` is an *uncertainty* terminal, not a reject terminal
Current mobiz *does* have a 7th lifecycle state worth flagging to next-architect (PR #117 only
counted the 6 populated `ts_payouts` values, but the model + dispatcher define a 7th):

- `models/withdrawal_queue.go:32` — `QueueStatusWaitingToReview = "waiting_to_review"`.
- `scheduler/withdrawal_dispatcher.go:800-813` — stale-processing items (>10 min) are *triaged*:
  if a bank transaction is detected, the item goes to `waiting_to_review` for an admin to
  confirm-completed rather than being auto-failed.
- `PayoutController.go:574,869-874,977,1915` — payouts transition
  `pending|processing|waiting_to_review → failed|cancelled`, and only
  `failed`/`waiting_to_review` payouts can be admin-confirmed-completed.

So the current axis of refinement is **certainty** (`failed` = proven-not-sent vs
`waiting_to_review` = unknown), **not cause** (refused vs technical). `mark_rejected` adds an
orthogonal *cause* axis the current system has never had.

---

## 2. Data findings (dpay MCP — re-confirmed live)

### `ts_payouts` status distribution — confirms PR #117, still 6 values, no `rejected`
| status | count |
|---|---|
| completed | 171,511 |
| failed | 6,088 |
| cancelled | 2,727 |
| pending | 476 |
| processing | 23 |
| waiting_to_review | 10 |

(`waiting_to_review` *is* present in production data — 10 live docs — so the populated set is
arguably 6, with a transient 7th. No `rejected`.)

### Do failed/cancelled payouts carry a deliberate-refusal reason field?
**No usable one on `ts_payouts`.** Of 6,088 `failed` + 2,727 `cancelled` payouts:
- `failure_reason`: **0** populated. The field is dead.
- `error_message`: **0** populated on `ts_payouts` (it lives only on the queue, see below).
- `notes`: 2,439 of `failed` / 284 of `cancelled` populated.

The `notes` content is **operator verdicts about outcome, not refusal reasons** — top values are
all Thai variants of "the amount did not leave the bank/system":
`"ยอดไม่ออกจากระบบ หน้าแบงค์ไม่พบยอดออก"` (1,213), `"ยอดไม่ออกจากระบบ และไม่พบยอดใน Bank Transactions"`
(565), `"ยอดไม่ออก"` (265), `"ไม่มียอดออกจากระบบ"` (208) … plus `"Admin confirmed failed from
waiting_to_review"` (28). None say insufficient funds / account closed / blacklisted / KYC.

### The real diagnostics live on `withdrawal_queue.error_message` — and they're all technical
All 5,388 `failed` payout queue items carry an `error_message` (100% coverage). Grouped, the top
reasons are **entirely bot-automation failures**:
- `"ยอดไม่ออกจากระบบ หน้าแบงค์ไม่พบยอดออก"` (943) — bot's verification step found no outgoing txn
- `Add recipient failed: locator.click: Timeout` (616), `locator.waitFor: Timeout` (542) — Playwright
- `Batch failed before adding: Could not navigate to transfer page` (519)
- `OTP failed / OTP form timeout` (152 + 86 + 80…), `Session lost / re-login failed` (113 + 103)
- `Processing timeout (10 min) — bot may have crashed` (75 + 65)

**Zero** of the ~30 distinct top messages express a deliberate bank refusal. There is no
"insufficient funds", no "destination account closed", no "KYC blocked". The bot's failure
vocabulary is purely "UI automation broke" or "I couldn't confirm the money moved."

---

## 3. Verdict for §ADR-4a #120

`mark_rejected` is **a new refinement, not a faithful port.** Current mobiz:
1. Folds *all* failure causes into a single `failed` terminal.
2. Already has a 2nd failure-adjacent terminal — `waiting_to_review` — but it splits on
   **certainty**, not cause.
3. Has no signal source for "deliberate reject": the bot drives a bank web portal and only ever
   sees timeouts / missing-transaction, never a structured refusal code. A `mark_rejected`
   terminal would need a *new* bot capability (or admin classification) to populate it — it
   cannot be back-derived from today's `error_message` text.

Recommendation to surface at ratification: adopting `mark_rejected` is reasonable, but it is
**additive design**, and it requires a deliberate decision about *who classifies* a failure as a
reject (bot vs admin), since the current bot cannot. Worth pairing it explicitly with the
existing `waiting_to_review` (certainty axis) so the next system's payout lifecycle is coherent
on both axes — cause *and* certainty.

— pg-writer, 2026-05-16 17:12 GMT+7

<!-- handled_at: 2026-05-16T17:14:00+07:00 — corroborates the #120 drop-mark_rejected decision; cited to next-architect via thread-120 envelope. -->
