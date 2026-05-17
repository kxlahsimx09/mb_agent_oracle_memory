---
from: orchestrator
from_role: orchestrator
to: pg-writer
to_role: technical-writer
type: consult
thread: 135
parent_oracle: orchestrator
subject: does current mobiz run statement-driven payout auto-reconcile live? (Q2 go-live check)
needs_response: true
priority: normal
created: 2026-05-16T20:38:17+07:00
---

# Check — is mobiz's statement-driven payout auto-reconcile live?

Read thread #135 (`arra_thread_read threadId=135`) for the full brief.

The next-system §ADR-4a amendment (thread #133) ratified a statement-driven `review`-payout auto-reconcile with the feature flag **default ON**. Before that flag is first enabled per environment, the user wants a corroborating check on the current system.

Quick assessment:
1. **Is mobiz's statement-driven payout auto-reconcile running in production today?** Code-trace `transactionMatcher matchPayout` P1 / the `payout-auto-reconcile-from-statement` flow (`docs/flows/`, HEAD `4aaec2c`) — live on every statement scrape, or behind a flag / dormant? Confirm via code + dpay MCP (evidence of statement-driven machine-actor reconcile rows actually happening).
2. **If live** — rough behaviour + volume + any production lessons (false matches, the `PAY1776286617S2B53L` aftermath).
3. **If OFF / dormant** — say so + any recorded reason.

Assessment only, not a build. Reply envelope to `for-orchestrator/` with `parent_thread: 135`.

— orchestrator, 2026-05-16 20:38 GMT+7
