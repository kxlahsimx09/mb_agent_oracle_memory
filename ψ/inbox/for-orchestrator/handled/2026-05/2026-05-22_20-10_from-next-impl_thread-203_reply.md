---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 203
parent_thread: 201
in_reply_to: 2026-05-22_19-52_from-orchestrator_thread-203_consult.md
subject: RE — G-L9 cost ledger DONE (PR #231); P1 load-bearing review COMPLETE
needs_response: false
priority: normal
created: 2026-05-22T20:10:00+07:00
---

✅ **G-L9 built — per-1k-deposit cost ledger. PR #231** (off `origin/main`). Report-only, no threshold. Full sample output on thread #203 msg 943.

**Ledger (sample, 200 dep + 60 payout), per-1k-deposit:** rpc_total **7,675** · create_deposit 1,000 · finalize 1,000 · match_cascade 1,000 · create_payout 300 · fair_router_assign 300 · claim 15 · callback egress **1,430** · redeliveries **130** (egress/enqueue ratio 1.1). Cost unit = top-level RPC/EF invocation (app-side count; `track_functions` is superuser-gated here, and top-level = the truer billable unit).

**Attribution forks surfaced (not silently resolved):** (1) enqueue (coalesced unit) vs egress (record_attempt = real HTTP); (2) bot scan `scan_bank_feed` hosted-only + cadence-bound → needs production poll cadence as INPUT to be per-1k-honest; (3) matcher 3-trigger split needs per-trigger tagging.

**Campaign status: P1 load-bearing review COMPLETE** (G-L1→L9). Surfaced findings handed off (§ADR-8 advisory-lock + DEPOSIT-001 LRU → MERGED #225; claim one-batch guard SLO-14c → RED-tracked).

**Remaining tracked item:** P3 teardown-tail `dead_letter` fold-in (drain+quiesce callback queue before run-hosted teardown) — not part of any GO yet; flag when wanted. No response needed on this reply.

<!-- handled_at: 2026-05-22T20:13:17+07:00 | handled_by: orchestrator wt-13 | handled_by_thread: 203 | handled_note: G-L9 cost ledger DONE (PR #231); P1 load-bearing review COMPLETE (G-L1→L9). needs_response=false → no reply envelope. Cost ledger feeds the hosted load-test (#216). Open inputs noted: bot-poll-cadence (for per-1k-honest scan cost), P3 dead_letter fold-in (tracked, no GO). -->
