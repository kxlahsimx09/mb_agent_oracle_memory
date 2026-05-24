---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 216
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: CORRECTION — hosted run was TINY-profile (user-verified); re-frame PR #236 Part C infra claims as tiny-scale (60-cap never stressed), downgrade ~75 dep/s to estimate, alarms provisional, recommend full-scale run; logic-SLO stands
context: see thread #216 msg 961 — user checked: run on tiny → backends 24/60 because working set small, not headroom. Blocks ratification of infra thresholds (not logic-SLO). Confirm tiny via PR #235 run config + push re-framed Part C.
needs_response: true
priority: normal
created: 2026-05-23T09:07:32+07:00
handled_at: 2026-05-23T09:25:00+07:00
handled_by_thread: 216
handled_by_inbox: next-architect@mb-next-payment-gateway.wt-4-inbox-1779418491
handled_note: Confirmed tiny-profile via PR #235 run config (tiers max 20×=~30 dep/s/45s ≈ 19× current peak, not DB capacity; peak 24/60 background-dominated). Re-framed Part C → PR #236 (commit 93613d8): SCOPE banner + C.1/C.2/C.3 tagged [INFRA-PROVISIONAL]; "~75 dep/s ceiling" downgraded to flagged soft estimate; C.3 cap-source lesson + C.5 logic-SLOs STAND (ratifiable now — concurrency was meaningful + mechanisms scale-invariant); C.7 NEW recommends a full-scale re-provisioned stress run. Posted to thread #216 (msg 962) + reply envelope to for-orchestrator/.
---

User verified the hosted load run was TINY-profile → 60-conn cap never genuinely stressed (peak 24/60 = small working set, not headroom). Re-frame PR #236 Part C: mark infra baseline tiny-scale; downgrade "capacity ~75 dep/s" to a flagged estimate (needs full-scale run); G-L5 alarms provisional (cap 60 real but unstressed); logic-SLOs (spread/40P01/dup) likely stand — state scope. Recommend a full-scale re-provisioned run before ratifying infra numbers. Confirm tiny via PR #235 config + push re-frame. Full detail thread #216 msg 961.
