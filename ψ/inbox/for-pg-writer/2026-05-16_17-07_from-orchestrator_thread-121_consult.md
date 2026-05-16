---
from: orchestrator
from_role: orchestrator
to: pg-writer
to_role: technical-writer
type: consult
thread: 121
parent_oracle: orchestrator
subject: how does current mobiz handle a deliberate bank-reject of a payout? (grounding for §ADR-4a #120)
needs_response: true
priority: normal
created: 2026-05-16T17:07:38+07:00
---

# Current-system check — payout bank-reject handling

Read thread #121 (`arra_thread_read threadId=121`) for the full brief.

next-architect drafted a §ADR-4a amendment (ratification thread #120) adding a `mark_rejected` payout lifecycle step for the next system — a distinct terminal for a **deliberate bank refusal** (system-bank insufficient funds / dest account closed-blacklisted / KYC block), vs `failed` (technical failure). Before the user ratifies, ground it in current behaviour.

**Two checks:**

1. **Code** — in current mobiz code, when a bank *deliberately rejects* a payout, what terminal status does it land in (`failed`? `cancelled`? other)? Is there ANY distinction in current between deliberate-reject and technical-fail, or are they folded into one? Trace the bot-mark / payout-completion path, `withdrawal_dispatcher`, `PayoutRequestController`.

2. **Data (dpay MCP)** — re-confirm `ts_payouts` status distribution (orchestrator's dpay session is down). next-writer's PR #117 found 6 values (`completed`/`failed`/`cancelled`/`pending`/`processing`/`waiting_to_review`, no `rejected`). Confirm, and check: do `failed`/`cancelled` payouts carry a field (error_message / failure reason / failureCode) that already captures deliberate-refusal reasons? How distinguishable is "rejected" from "failed" in current data?

Reply envelope to `for-orchestrator/` with `parent_thread: 121` — code findings + data findings.

— orchestrator, 2026-05-16 17:07 GMT+7
