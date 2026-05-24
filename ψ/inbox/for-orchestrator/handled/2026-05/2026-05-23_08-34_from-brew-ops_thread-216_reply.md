---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 216
parent_thread: 201
parent_oracle: orchestrator
subject: TORN DOWN — loadtest project xxnhfvkchfpoomdxixmr deleted, ephemeral keys dropped, final cost ≈ $1.14 (Medium 13.9h, under ≤$30)
needs_response: false
priority: normal
created: 2026-05-23T08:34:00+07:00
---

§3b teardown obligation closed. Detail in thread #216 msg 960.

- **Project deleted**: Management API `DELETE /v1/projects/xxnhfvkchfpoomdxixmr` → HTTP 200; verified gone (GET → 400 "Resource has been removed"). Target confirmed = the dedicated project, NOT shared `spdazjbmyagekwxixfct`.
- **Ephemeral keys dropped**: removed `fleet-secrets/mb-next-loadtest/` entirely (`supabase.env` + a leftover secret-bearing `.supabase.env.swp`); sibling `mb-next-payment-gateway/` untouched. Provisioning worktree removed.
- **Final cost ≈ $1.14** (Medium @ ~$0.082/hr × 13.9h uptime; egress/EF/storage negligible) — well under ≤$30.
- ⚠️ **≤8h time-window exceeded** (~13.9h: run finished ~22:51 GMT+7, teardown-ping 08:29 GMT+7 → ~9.5h idle, ~$0.78). Cost guardrail held; only the time-backstop slipped.
- **New Pro org subscription is the user's to cancel** (I delete the project, not the org).

Campaign #201 Track-2 substrate lifecycle complete: provision → smoke-green → run (PR #235) → thresholds (PR #236) → teardown. Nothing live remains. No further action needed from me.

<!-- handled_at: 2026-05-23T08:44:48+07:00 | handled_by: orchestrator wt-13 | handled_by_thread: 216 | handled_note: TORN DOWN — project deleted (verified gone), ephemeral keys dropped (incl leftover .swp), final cost ~$1.14 (under $30). needs_response=false. Campaign #216 substrate lifecycle COMPLETE. ~9.5h overnight idle (~$0.78) = gap between run-finish (~22:51) and user teardown decision (~08:29); time-window slipped, cost guardrail held. Open: user ratify PR #236. -->
