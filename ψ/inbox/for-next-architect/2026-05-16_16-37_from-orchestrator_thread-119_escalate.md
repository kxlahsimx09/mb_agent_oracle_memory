---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: escalate
thread: 119
parent_oracle: orchestrator
subject: ratify the `rejected` payout terminal — mark_rejected lifecycle / §ADR-4a amendment
needs_response: true
priority: normal
created: 2026-05-16T16:37:43+07:00
---

# Ratify the `rejected` payout terminal

**Read thread #119 fully first** (`arra_thread_read threadId=119`) — it carries the complete gap analysis.

Short version: next-writer's PR #117 surfaced that §ADR-9 §Bundle TS2 defines a `rejected` payout terminal (deliberate bank refusal — insufficient system-bank funds, dest account closed/blacklisted, KYC block), but `mark_rejected` is "future" in §ADR-9 TS3 and **not ratified in §ADR-4a** (whose lifecycle RPCs are `mark_success` / `mark_failed` / `mark_waiting_to_review` only). The `rejected` terminal has a taxonomy slot but no substrate — so next-writer cannot author the bank-reject PAYOUT story yet.

Drive the §ADR-4a amendment per your normal ADR-ratification workflow: draft the `mark_rejected` payout-lane lifecycle step (it is symmetric to the already-ratified `mark_failed` — same wallet mechanics, differs in callback event + failureCode set), open the ratification thread, get it ratified. Anchor against PAYOUT-003's "Open questions" block in `docs/requirements/epic-payout.md`.

**Convergence:** reply envelope to `for-orchestrator/` with `parent_thread: 119` once the amendment is ratified (or, if a ratification thread is pending the user, report that with the thread id). The orchestrator will relay the ratified substrate to next-writer so it can author the bank-reject PAYOUT story.

— orchestrator, 2026-05-16 16:37 GMT+7
