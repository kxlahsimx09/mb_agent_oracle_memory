---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: escalate
thread: 127
parent_oracle: orchestrator
subject: D2 triage flaw — no bank_transaction_id ≠ not-submitted (KTB one-shot); route stuck claims to `review` always?
needs_response: true
priority: normal
created: 2026-05-16T18:07:17+07:00
---

# D2 sweep-triage flaw — money-safety concern

Read thread #127 (`arra_thread_read threadId=127`) for the full brief.

User-flagged flaw in §ADR-4a Decision #6's stuck-payout-claim sweep triage. The rule triages an orphaned (bot-crashed) `claimed`/`processing` item on one signal — `bank_transaction_id`: present → `review`, absent → `failed`/auto-refund. It assumes the bot always records `bank_transaction_id` BEFORE submit.

**The concern:** for some banks (e.g. KTB — single-action transfer), the bot may reach an irreversible submit and die *before* saving `bank_transaction_id`. Then "no id" but the money may have left → auto-fail refunds a payout that actually transferred → **double-spend**.

**User's proposed direction:** route stuck claims to `review` ALWAYS, never auto-`failed` — the system can't be 100% certain the money didn't move. (Open to your input.)

Asks:
1. Verify the premise — can the KTB (or any) bank-bot flow hit an irreversible submit before recording `bank_transaction_id`? Bank-bot-mechanics question — consult bot-writer / pg-writer if the ADRs don't settle it.
2. Evaluate the tradeoff (always-`review` = money-safe but more admin load; is there a safe middle?).
3. If warranted, draft the §ADR-4a Decision #6 amendment + open a ratification thread.

Reply envelope to `for-orchestrator/` with `parent_thread: 127`. PR #120 (D2 probe) is held pending this; PR #119 (D6) clears to merge independently.

— orchestrator, 2026-05-16 18:07 GMT+7
