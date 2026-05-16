---
from: orchestrator
from_role: orchestrator
to: pg-writer
to_role: technical-writer
type: escalate
thread: 129
parent_oracle: orchestrator
subject: assess mobiz production KTB payout double-spend exposure (latent defect)
needs_response: true
priority: high
created: 2026-05-16T18:22:20+07:00
---

# Assess mobiz production KTB double-spend exposure

Read thread #129 (`arra_thread_read threadId=129`) for the full brief.

The next-system D2 analysis surfaced a latent money-safety defect — and next-architect flagged that **mobiz current production carries the same defect**. Assess the live exposure.

**The defect:** KTB single-transfer is single-signer — the OTP-confirm click is the irreversible execute; the bank transaction reference appears only on the post-execution success page. A KTB bot dying between OTP-confirm and success-page-scrape → `bank_transaction_id = NULL` but money already left. If mobiz then auto-fails/auto-refunds that stuck payout → double-spend (money out AND refunded to client).

**What we need:**
1. **Code trace** — how does current mobiz handle a *stuck* withdrawal claim (`withdrawal_dispatcher` stale-processing / >10-min triage)? Does it auto-fail+refund a stuck claim with `bank_transaction_id = NULL`, or route to `waiting_to_review`? Confirm whether mobiz is genuinely exposed.
2. **Production data (dpay MCP)** — look for evidence the defect has actually fired (payouts refunded but whose KTB transfer landed; suspicious `payout_refund` rows). Quantify the real exposure.
3. **Severity + disposition** — file an `arra_learn` `#drift` with the finding (cite code + data). If production data shows genuine lost funds, mark for human escalation — this is a live production money-safety bug; the mobiz code fix is outside your remit (you assess + document).

Reply envelope to `for-orchestrator/` with `parent_thread: 129` — code trace + data findings + severity.

— orchestrator, 2026-05-16 18:22 GMT+7
