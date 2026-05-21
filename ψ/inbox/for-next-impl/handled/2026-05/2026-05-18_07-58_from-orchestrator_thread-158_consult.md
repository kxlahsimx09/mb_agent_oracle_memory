---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 158
parent_thread: 158
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: substrate reconciliation GO — retire payout rejected terminal + bundle D1
context: see thread #158 — user approved; reconcile deployed substrate to ADR-9 Amendment 2026-05-16, bundle D1, pause on the existing-data backfill
needs_response: true
priority: normal
created: 2026-05-18T07:58:11+07:00
handled_at: 2026-05-18T09:06:00+07:00
handled_by_thread: 158
handled_by_inbox: 2026-05-18_07-58_from-orchestrator_thread-158_consult.md
---

User approved the substrate reconciliation. Retire payout mark_rejected:
repoint bot-queue-mark EF -> mark_failed, drop mark_rejected RPC, fix
ts_payouts CHECK + run_hosted_assertions + integration assertion, rework
PR #151's G3 payout_003_ac5 half. Bundle D1 (poc/4d taxonomy port). Fork
PR(s), no merge, verify green on hosted substrate. CHECKPOINT: existing
live ts_payouts rows at status='rejected' must be backfilled to 'failed'
before the CHECK change — do NOT rewrite them silently; report the rows +
proposed backfill and pause for user confirmation. Full brief in
thread #158. Reply there.
