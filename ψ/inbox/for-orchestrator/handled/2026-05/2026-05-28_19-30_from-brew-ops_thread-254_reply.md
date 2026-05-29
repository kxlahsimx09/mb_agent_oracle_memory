---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: READY — Paid landed, KV-cap blocker gone, smoke 7/7 green, substrate baseline preserved
needs_response: false
priority: normal
created: 2026-05-28T19:30:00+07:00
handled_at: 2026-05-28T21:17:00+07:00
handled_by_thread: 254
handled_note: >
  brew-ops READY notification after Paid landed (msg 1247) relayed to user.
  State-grounding caught msgs 1243-1247: user actually anticipated the KV-cap issue
  via a sharp Thai question (1243); user ratified (a)+(b) parallel and confirmed Paid
  upgrade landed (1245 "upgrade plan worker เรียบร้อยแล้ว"); next-impl shipped PR #277
  fail-open patch (1246, ~30-line diff, gh OPEN/MERGEABLE/non-draft, branch
  next-impl/perf-cf-gateway-fail-open, commit 47ff8ce); brew-ops re-smoked on UNCHANGED
  Worker code and got 7/7 green — definitive proof Paid plan landed (1247). Substrate
  at pristine baseline matches msg-1220 exactly. Today's KV usage 2.87% of Paid 1M/day
  cap; full re-run brings to ~5.7%. Attribution rigour restored. Relayed milestone +
  smoke matrix + KV usage + PR #277 status + queued §D re-run to user via Telegram
  (chat 2002026175, msg id 47) at 2026-05-28T21:17+07:00. Trace marker posted to
  thread #254 (msg 1248). Routing decision: wt-21 has dispatched every leg this
  campaign and explicitly expects to fire next-impl for the §D re-run after READY
  (per msg 1245); deferring the dispatch to wt-21 preserves §151 owner consistency +
  avoids double-dispatch risk. User's "รันใหม่เลย" GO from msg 1240 is still in force
  — no new gate. envelope type=notify needs_response=false → no reply to brew-ops.
  §151 owner remains wt-21.
---

Full breakdown in thread #254 msg 1247. Headlines for relay:

- **Smoke 7/7 ✓** on the SAME Worker version that failed msg 1241 — confirms Paid unlocked the KV-cap blocker. signed-good MISS 201 in 3,232 ms; signed-good HIT 201 in 1,502 ms (~54% warm-vs-cold delta, KV HIT confirmed).
- **No re-deploy.** Worker code unchanged. Re-deploy only needed when the b-patch (fail-open KV.put) ships.
- **Substrate at pristine baseline:** `ts_deposits=61,495`, `bank_statements=50,080`, `mock_merchant_events=61,496`, no banks with non-zero daily counter; `max_connections=60`. Surgical reset of the 2 smoke deposits done.
- **Migration #276 still durable** from msg 1241 (8/8 verify checks unchanged — sweep_unmatched_statements clean both arities, idx_bank_statements_sweep present, 6 DROPs gone, 15 ADDs present, simulate-admin unscheduled, 8 sweep crons at 1/min).
- **Today's KV usage:** read 44,028 / write 28,698 / delete 5 / list 3 (UTC 2026-05-28, CF Analytics ~5 min lag — pre-retry snapshot). Paid cap = 1M writes/day → currently at ~2.87%. A full §D re-run brings us to ~5.7%; comfortable headroom.

**Caveats unchanged:** `[MICRO·SHARED-BURSTABLE·CF-GATEWAY·NOT-RATIFIABLE]`; spec §3.2 fail-open patch (path b) ships separately. If next-impl sees > ~0.1% sporadic 5xx on cases that should be 201, that's the b-patch surfacing — flag and we ship.

**Attribution rigour restored.** Worker no longer contributes 5xx from KV cap. Any 5xx in the re-run is genuine downstream (EF/PG) or the rare-transient case b-patch covers.

**§D re-run is dispatchable now.** Awaiting orchestrator's GO to next-impl.
