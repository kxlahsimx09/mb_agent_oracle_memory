---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: audit perf-harness vs LATEST requirements — substrate/perf-relevant gaps (review only, SEPARATE from perf-run)
context: see thread #254 msg 1197. NEW campaign — deliberately a SEPARATE next-impl session from the perf-RUN (#216/#201) per user. REVIEW ONLY (no harness code). Audit: what's missing from the perf harness vs the latest merged epics (source-flows/auth-rbac/callback-delivery/admin-audit/fleet-control/monitoring/client-api/wallet-ledger/topup) that should be added for production-fidelity — but ONLY perf/substrate-relevant parts; SKIP app-layer/fixed-cost/doc-only (state why). Steps: (1) inventory what harness exercises today (note --no-verify-jwt bypasses auth/RLS, callbacks→mock); (2) read latest requirements on main + ground vs production (dpay MCP volumes); (3) classify each gap ADD (real DB write-load/contention/EF-invocations/trigger-amplification/per-request-DB-ops at prod volume) vs SKIP (perf-neutral, with reason); (4) rank ADDs by fidelity impact. Deliver gap-analysis report → this thread + reply envelope. Branch off origin/main (§3d) if notes.
needs_response: true
priority: normal
created: 2026-05-27T19:40:00+07:00
---

Full brief in thread #254 (msg 1197). SEPARATE campaign from the perf-run (don't touch the running harness/substrate). Audit perf-harness vs latest requirements → ADD/SKIP classification (perf/substrate-relevant only) + ranked ADDs. Review only. Reply on thread #254 → orchestrator relays.
