---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 158
parent_thread: 158
parent_oracle: orchestrator
subject: reply — payout substrate reconciled (PR #152 verified green), D1 ported (PR #153), CHECK-drop paused for GO
needs_response: false
priority: normal
created: 2026-05-18T09:06:00+07:00
---

Substrate reconciliation done. Full report on thread #158 (msg 473).

PR #152 — payout `rejected` retirement (fork branch, NOT merged). migration
20260518000001 (DROP mark_rejected + run_hosted_assertions repoint) pushed to
spdazjbmyagekwxixfct; bot-queue-mark EF repointed to mark_failed + deployed;
hosted-assertions assertion renamed; PR #151 G3 reworked to mark_failed.
Verified green on hosted substrate: 89/89 assertions pass; payouts_rejected
sentinel = 0; mark_rejected gone (PGRST202).

PR #153 — D1 poc/4d taxonomy port (admin_approve_failed→admin_approve_rejected,
status rejected, deposit.rejected event, schema CHECK). CODE-COMPLETE but
pgTAP NOT verified — Docker is not running in this worktree and there is no
local pgTAP, so poc/4d/run-tests.sh could not run. Flagged honestly per #146;
NOT reported as green. run-tests.sh must run in a Docker env before merge.

CHECKPOINT — held the status CHECK-drop per the brief. Finding: the 2
ts_payouts rows at status='rejected' were PoC fixtures (reset_runtime_state
DELETEs all payouts every run); post-reconciliation the live substrate has 0
rejected rows in both ts_payouts and withdrawal_queue (verified). No real-data
backfill needed. Proposed held migration 20260518000002 (defensive 0-row
UPDATE + CHECK swap dropping `rejected`) quoted in the thread reply. Awaiting
your GO to push it — ~1-minute follow-up.

PRs: #149 #151 #152 verified green; #153 pgTAP-unverified. None merged.

Reply on thread #158.

# handled_at: 2026-05-18T08:29:30+07:00
# handled_by_thread: 158
# handled_note: payout reconcile done (PR#152 green); D1 PR#153 pgTAP-unverified; CHECK-drop awaiting user GO
