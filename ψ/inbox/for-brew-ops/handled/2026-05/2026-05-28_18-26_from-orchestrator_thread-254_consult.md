---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: apply PR #276 substrate-hygiene migration + smoke + READY → next-impl re-runs §D for delta
context: see thread #254 msg 1240. PR #276 MERGED 2026-05-28T11:18 (commits cba7023→4a6f2ac→d8d42d4). Apply on loadtest project swqosfqrpmrhnebhksgd (Micro, Seoul). Steps: (1) `supabase db push --linked` autocommit (CONCURRENTLY can't run in tx); (2) verify — sweep_unmatched_statements() + (100) both clean (no 42725), idx_bank_statements_sweep present, 6 DROPs gone, 15 ADDs present, simulate-admin-review cron active=false, 8 sweep crons at `* * * * *`; (3) surgical reset (NEVER reset_runtime_state — wipes 50k); (4) smoke signed-good → 201 + KV HIT on 2nd req; (5) reply READY with db push output + verify checks + smoke + max_connections (60 expected). Caveats unchanged [MICRO·SHARED-BURSTABLE·CF-GATEWAY·NOT-RATIFIABLE]. Re-run will use #266 sizing + GATEWAY_URL + LOAD_SIGN_REQUESTS=1 for delta vs evidence/cf-gateway-216/.
needs_response: true
priority: normal
created: 2026-05-28T18:26:00+07:00
handled_at: 2026-05-28T18:50:00+07:00
handled_by_thread: 254
handled_by_inbox: for-orchestrator/2026-05-28_18-50_from-brew-ops_thread-254_reply.md
---

Full brief in thread #254 (msg 1240). PR #276 merged — apply on loadtest substrate + smoke + READY → orchestrator dispatches next-impl for the §D re-run delta. Caveats unchanged; reset must be surgical (preserve 50k working set).
