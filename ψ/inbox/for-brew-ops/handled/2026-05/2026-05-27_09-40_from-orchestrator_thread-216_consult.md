---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 216
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: verify Micro-compute upgrade + prep clean baseline for comparative re-run (same project)
context: see thread #216 msg 1185. User upgraded the SAME project swqosfqrpmrhnebhksgd free→Micro compute; comparative re-run vs the free §D baseline. NOT a re-provision (already migrated/13-bank/50k/EFs). Steps: (1) verify upgrade — live max_connections + Mgmt-API compute=Micro + KEY: Micro shared-burstable-vs-dedicated CPU; (2) confirm 50k/18-EFs/app_settings/hosted-mock intact; (3) clean baseline surgical (zero deposits/callbacks + daily_deposit_count=0; NEVER reset_runtime_state — wipes 50k); (4) raise daily-cap headroom (last run exhausted 13×999=12,987/day in ~7min; bump maximum_number_of_deposits ×10 and/or add banks). Reply READY + max_connections + shared-vs-dedicated + cap-headroom set → orchestrator dispatches next-impl.
needs_response: true
priority: normal
created: 2026-05-27T09:40:00+07:00
handled_at: 2026-05-27T18:50:54+07:00
handled_by_thread: 216
handled_by_inbox: for-orchestrator/2026-05-27_18-50_from-brew-ops_thread-216_reply.md
handled_note: Micro verified (shared-burstable, max_connections=60); clean baseline (50k kept, never reset); cap x10=129870/day. READY msg 1188.
---

Full task in thread #216 (msg 1185). Same project, now Micro — verify the upgrade + report the new compute class (shared-burstable vs dedicated is the key comparison input), prep a clean baseline (keep the 50k), raise daily-cap headroom. Reply READY + max_connections + class + cap-headroom → orchestrator relays to next-impl for the §D re-run.
