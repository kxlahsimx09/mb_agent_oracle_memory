---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: READY (supersedes msg 1247) — PR #277 patched Worker deployed, smoke 7/7, both unblocks live
needs_response: false
priority: normal
created: 2026-05-28T19:40:00+07:00
handled_at: 2026-05-28T21:31:00+07:00
handled_by_thread: 254
handled_note: >
  brew-ops final-unblock READY notification (msg 1250, supersedes msg 1247) relayed to
  user. State-grounding: envelope filename timestamp 19:40 is brew-ops's clock-skew —
  actual thread time = 2026-05-28T14:29:07Z = 21:29 GMT+7. Both unblocks now live:
  (a) CF Paid landed (carry-over from msg 1247) and (b) PR #277 fail-open patch
  merged at 14:24 UTC then redeployed by brew-ops in msg 1250 — new Worker version
  1a8c9ab8-5bc3-4bd7-87dc-ba7575f8c28b (was 42abb4c1). Smoke 7/7 green on patched
  Worker. Substrate at pristine baseline. KV usage 2.87% of Paid 1M/day cap. Attribution
  rigour clean for §D re-run (no spec bug + no cap). Relayed concise both-unblocks-live
  confirmation + redeploy details + attribution-clean note + carry-forward item 7 CLOSED
  to user via Telegram (chat 2002026175, msg id 48) at 2026-05-28T21:31+07:00. Trace
  marker posted to thread #254 (msg 1251). Routing unchanged: wt-21 (§151 owner +
  consistent campaign dispatcher) handles the §D re-run dispatch as it has every prior
  leg. User's "รันใหม่เลย" GO from msg 1240 still in force; no new user gate needed.
  envelope type=notify needs_response=false → no reply to brew-ops. Notable pattern
  captured: two-step deploy (Paid → smoke → merge patch → redeploy → smoke) gave a
  clean A/B isolation of the Paid plan effect before stacking the spec-correctness
  change. §151 owner remains wt-21.
---

Full breakdown in thread #254 msg 1250. Headlines for relay:

- **Patched Worker deployed.** `wrangler deploy` of PR #277 fail-open patch → **new version `1a8c9ab8-5bc3-4bd7-87dc-ba7575f8c28b`** (was `42abb4c1` for the msg-1247 smoke). Branch FF'd to current `origin/main` (`6ad12a0`).
- **Smoke 7/7 ✓**: signed-good MISS 201 (3,180 ms); signed-good HIT 201 (1,456 ms; ~54% warm-vs-cold delta — KV HIT confirmed). Same 401/204 on cases 3-7.
- **Substrate at pristine baseline:** ts_deposits=61,495 / bank_statements=50,080 / mock_merchant_events=61,496 / banks_nonzero_daily=0. Surgical reset of the 2 new smoke deposits done. Migration #276 still applied (8/8 verify unchanged); max_connections=60.
- **KV usage today:** read 44,035 / write 28,703 / delete 6 / list 3 (CF Analytics ~5 min lag). Paid cap = 1M writes/day → ~2.87% used. A full §D re-run brings us to ~5.7%; comfortable headroom.
- **Attribution clean for the §D re-run.** Both unblocks live: (a) Paid plan removes the cap trigger, (b) fail-open patch ensures a transient/rare KV error logs `evt: rate_limit_kv_*_fail_open` and allows the request — never propagates a 5xx. Any 5xx in the next run is genuine downstream (EF/PG) or a new failure mode worth chasing on its own.

Carry-forward (msg 1247 list, item 7 closed):
7. ~~b-patch queued~~ → **landed in PR #277 version `1a8c9ab8-…`** ✓

§D re-run is dispatchable. Awaiting orchestrator's GO.
