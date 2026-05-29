---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: ⚠️ DUAL-WAKE COLLISION on §D re-run — wt-17 YIELDED, wt-19 is sole owner mid-run
needs_response: true
priority: high
created: 2026-05-28T22:15:21+00:00
handled_at: 2026-05-29T05:18:00+07:00
handled_by_thread: 254
handled_note: >
  DUAL-WAKE COLLISION incident report (msg 1254 from next-impl wt-17) relayed to user.
  State-grounding: envelope timestamp 22:15:21+00:00 is explicit UTC (5:15 GMT+7 next
  day). Sequence: msg 1252 dispatch silent-failed at watcher (failed_no_prompt T1
  state); wt-21 RE-FIRE (msg 1253) ~6h later; RE-FIRE reached wt-17 (alive again)
  AND watcher --fresh-spawned wt-19 per §151 owner-gone fallback. Both started §D run
  7s apart. wt-17 yielded textbook: killed only own tree, verified non-interference,
  wt-19 sole-owner mid-run. §151 ownership transitioned wt-17→wt-19. Preliminary win
  signal STRONG (contaminated-high through early-20x): 537 fail-open events / 0 5xx,
  low-tier p99 3-5× lower (warm 5994→1749, 1x 5553→1253, 5x 5331→2254), 20x 5xx
  7.34%→0%. Data caveat: warm→early-20x ~2× contaminated, sustained-30 onward clean
  solo. Contamination only inflates. Relayed incident + correct-handling + preliminary
  signal + caveat + process-gap learning + 3 user options (continue/abort/wait) +
  next-impl recommendation (continue) to user via Telegram (chat 2002026175, msg id 49)
  at 2026-05-29T05:18+07:00. Trace marker posted to thread #254 (msg 1255).
  CRITICAL: NO dispatch fired — any orchestrator action that triggers a session spawn
  could repeat the collision; wt-17 explicitly directed wt-19 to NOT also yield.
  wt-19 must complete + post full table; wt-17 monitors as backup. Two durable
  learnings captured for arra_learn + potential brew-ops fix: (1) inbox-watcher needs
  owner-liveness check before --fresh-spawn fallback on failed_no_prompt state; (2)
  orchestrator RE-FIRE on `route=owner_send_keys` failed_no_prompt should perhaps
  direct the watcher to RE-FIRE-to-owner-only, no --fresh fallback within N seconds.
  §151 owner now wt-19 (campaign-side); wt-21 remains orchestrator-side.
---

Full content in thread #254 msg 1254. Headline:

- **Collision:** the RE-FIRE (msg 1253) reached wt-17 (alive, not dead) AND the watcher `--fresh`-spawned a 2nd next-impl (wt-19). Both launched the §D run against the SAME hosted substrate 7 s apart → 2× real load, mutual contamination; neither apples-to-apples if both run.
- **My action:** wt-19 is the §151 fresh-owner + started first → wt-17 yields. Killed ONLY my own tree (runner bash + reparented orphan driver, by `FT_OUT`), left wt-19 untouched, verified clean. **Exactly one run now live (wt-19, solo).**
- **wt-19 must complete + post the table** — must NOT also yield (mutual-yield deadlock). I've already stood down + am monitoring as backup; if wt-19 dies I take over.
- **Read-caveat:** warm→early-20x ~2× contaminated; sustained-30 onward clean solo. Contamination only inflates, yet wt-19 already beats cf-gateway-216 → restart optional, headline lands clean.
- **Preliminary win signal:** ~537 `rate_limit_kv_*_fail_open` w/ 0 5xx through early-20x — PR #277 patch absorbing the KV faults that were 6.85% 5xx in cf-gateway-216. Low-tier p99 down 3-5×; 20x 5xx 7.34%→0%. Strong RECOVERY trend. `[MICRO·SHARED-BURSTABLE·CF-GATEWAY·PAID·HYGIENE-APPLIED·NOT-RATIFIABLE]`.

Process gap worth a fix: the watcher should verify the "dead" owner is actually dead (or have the revived session detect the peer) before `--fresh` spawning — this is the live-process analogue of the inbox-misroute. Captured as a durable learning.
