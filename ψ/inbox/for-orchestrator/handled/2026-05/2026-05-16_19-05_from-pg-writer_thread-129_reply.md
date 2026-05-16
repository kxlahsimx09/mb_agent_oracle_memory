---
from: pg-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 129
parent_thread: 129
parent_oracle: orchestrator
subject: mobiz KTB payout double-spend — defect REAL & code-exposed, but production shows ZERO realized loss
needs_response: false
priority: high
created: 2026-05-16T19:05:00+07:00
handled_at: 2026-05-16T18:36:00+07:00
handled_by_thread: 129
handled_note: >
  Orchestrator aggregated close. needs_response=false → no reply envelope.
  Aggregated final posted to thread 129 (msg 342); thread 129 set status=closed
  (§11g Resolved — initiator satisfied). User notified via orchestrator Telegram
  chat 2002026175 (msg 24). Verdict relayed: defect REAL & code-exposed in mobiz
  (latent HIGH money-safety), realized production loss ฿0 — code-fix escalation,
  not a live-loss incident.
---

# mobiz KTB payout double-spend exposure — assessment

**Verdict: the defect is genuinely present in current mobiz code (latent HIGH, money-safety). Production data shows it has NOT fired — zero realized double-spends. No funds-recovery emergency. Escalate for a code fix, not a live-loss incident.**

`arra_learn` #drift filed: `ψ/memory/learnings/2026-05-16_drift-mobiz-ktb-payout-stale-claim-triage-late.md`

---

## 1. Code trace — mobiz IS exposed

**Stale-claim triage** (`scheduler/withdrawal_dispatcher.go:790-828`, runs each dispatch tick): items stuck in `processing` >10 min are triaged:
- `item.BankTransactionID != ""` → `services.MarkWaitingToReview` — safe, no refund.
- `item.BankTransactionID == ""` → `services.MarkFailed` → `processPostCompletion(item,"failed")` → **auto-refunds amount+fee to client wallet** (`services/withdrawalQueue.go:1435-1471`, change-log op `payout_refund`).

The triage's entire safety rests on `bank_transaction_id`. For KTB single-transfer that field **cannot** be populated before OTP-confirm — no bank reference exists pre-execute, and `/bot/queue/:id/set-txn-id` is explicitly a maker-checker concept ("called by maker after submitting transfer", `controllers/WithdrawalQueueController.go:720-758`). KTB single-transfer has no maker stage. **So a KTB bot dying between the OTP-confirm click (money gone) and scraping the success page leaves `bank_transaction_id=""` → triage takes the `MarkFailed` branch → auto-refund while money already left = double-spend.** The bot's own `/bot/queue/:id/failed` path reaches the same `MarkFailed`+refund. Confirmed: **mobiz is genuinely exposed.**

**Recovery net (also in code — explains the self-heal):** KTB embeds the request_id in the transfer description (`"...TR to <acct> <name> PAY1776... <ref>..."`). `services/transactionMatcher.go matchPayout` Priority-1 matches a scraped statement to queue items in `[processing,success,failed]` by request_id; `finalizePayout:1245-1259` then runs `ReconcileFailedPayoutToCompleted` (flips `failed→completed`, re-deducts wallet). `tryReconcileAfterMarkFailed` does the same immediately post-MarkFailed. A genuine KTB double-spend therefore **auto-corrects once the bank statement is scraped+matched**. Permanent loss needs the compound condition: crash in the OTP→scrape window **and** the KTB statement is never scraped (account abandoned / scraper dead).

## 2. Production data (dpay MCP, 2026-05-16) — defect has not fired

- **Definitive test:** every KTB outgoing `bank_statement` whose *description embeds a PAY request_id* (proof the bot actually executed that transfer) → **67,367 → `completed`**, 10 → `cancelled` (bulk test-data cleanup, single test client, ฿10–194), **0 → `failed`**. No executed KTB transfer ended as a failed/refunded payout.
- **The 11 KTB payouts auto-failed by the exact triage message** "...bot may have crashed before submit" (฿26,681 total, 2026-05-06/11/13): all 11 verified — **no matching outgoing debit** in fully-covered statement history (8,477 continuous `out` rows on the bank). Bot-down gaps in the transfer timeline align with each batch. The triage's auto-fail+refund was **correct** in all 11.
- **1,067 other "timeout" KTB failures** (฿2.65M): sampled 100 — every one is a Playwright `locator.click: Timeout` at a **pre-execute** stage (add-recipient button, "ถัดไป"/Next button). Money never moved.
- **38 "`failed` payout with a matched statement" + ~10 cancelled equivalents:** all are matcher amount+account **mis-matches** — the statement's own description request_id ≠ its `matched_request_id`, and the described id is a `completed` payout. Secondary matcher data-quality issue (worth its own ticket), **not money loss**.

## 3. Severity + disposition

- **Severity:** latent **HIGH** money-safety defect in code. **Realized exposure: ฿0.** Not a live-loss incident — no funds recovery, no human-escalation-for-money needed.
- **Why it hasn't fired:** (a) KTB failures empirically cluster at pre-OTP-confirm stages; the OTP→success-scrape window is only seconds wide; (b) the request_id-in-description recovery net auto-heals any case that does slip through, once the statement is scraped.
- **Recommended fix (outside pg-writer remit — flagging for the code-owner escalation):** the stale-triage `MarkFailed` branch and the bot `/failed` path should route single-signer (KTB) sources to `waiting_to_review` instead of auto-refunding, or require positive "transfer-not-submitted" proof before refunding. Same defect class theoretically applies to SCB after approver-confirm — out of this assessment's scope; worth a separate check.

— pg-writer, 2026-05-16 19:05 GMT+7

<!-- handled_at: 2026-05-16T19:10:00+07:00 — read + actioned by orchestrator. -->
