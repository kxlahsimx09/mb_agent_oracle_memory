---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: R1.C reverted — sweep cadence held at 1/min; PR #276 MERGEABLE
needs_response: false
priority: normal
created: 2026-05-28T11:08:00+07:00
handled_at: 2026-05-28T18:11:00+07:00
handled_by_thread: 254
handled_note: >
  next-impl R1.C revert confirmation (msg 1235) relayed to user. State-grounding caught
  three new thread messages since msg 1232 marker (msgs 1233/1234/1235): wt-21
  cadence-revert dispatch (user clarification 1 นาทีครั้ง = hold at 1/min) + wt-21
  LIMIT 500 grounding consult dispatch (user's parallel sharp question) + next-impl
  revert reply (this envelope). next-impl applied the revert via commit 4a6f2ac on
  branch next-impl/substrate-hygiene-r1r2; PR #276 still MERGEABLE. R1.A/R1.B/R2 all
  intact. Verify counters confirm new shape. CRITICAL: this envelope does NOT address
  the LIMIT 500 grounding consult (msg 1234) — that work is still in flight, will
  arrive as a separate next-impl envelope. Relayed revert confirmation + LIMIT 500
  in-flight status to user via Telegram (chat 2002026175, msg id 44) at
  2026-05-28T18:11+07:00. Made clear merging #276 should probably wait on the LIMIT
  500 answer since any adjustment folds into the same PR. Trace marker posted to
  thread #254 (msg 1236). Thread left pending; envelope needs_response=false → no
  reply to next-impl. §151 owner remains wt-21.
---

User correction (msg 1233) applied. Pushed commit `4a6f2ac` to `next-impl/substrate-hygiene-r1r2`:

- R1.C cron-cadence DO block removed from the migration (replaced with a RETRACTED comment recording the original intent + the user correction).
- Local DB schedules reverted `*/5 * * * *` → `* * * * *` to match the new migration shape.
- All other R1.A / R1.B / R2 work untouched.

`gh pr view 276` → state=OPEN **mergeable=MERGEABLE** mergeStateStatus=UNSTABLE (UNSTABLE = optional/no-CI status, same as the prior 4 PRs that merged clean).

Verify counters (post-revert):
- sweeps_at_1min=8, sweeps_at_5min=0
- simulate_admin_active=0 (R1.B intact)
- sweep_unmatched_overloads=1 (R1.A intact, no 42725 trap)
- idx_bank_statements_sweep_present=1 (new partial intact)

Ready for brew-ops db push + §D re-run for the apples-to-apples delta vs `evidence/cf-gateway-216/`. With cadence held constant, the delta now isolates the perf win to R1.A query rewrite + R2 index hygiene alone. Thread #254 msg 1235 has the in-thread summary.
