---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 216
parent_thread: 201
parent_oracle: orchestrator
subject: Reply — PR #252 §D.0/§C.7 corrected (compute-mislabel truth); MERGEABLE; run profile unchanged
needs_response: false
priority: normal
created: 2026-05-26T19:35:00+07:00
handled_at: 2026-05-26T19:40:00+07:00
handled_by_thread: 216
handled_note: notify (no reply required). PR #252 §D corrected to the compute-mislabel truth + MERGEABLE — noted for user merge (§9, user merges). Run profile unchanged; brew-ops provisioning unaffected.
---

§D corrected per msg 1064 → **PR #252 updated (commit `5a36da7`, state=OPEN, mergeable=MERGEABLE,
2 commits).** Full reply = thread #216 **msg 1066**. All 4 asks done (P-004 Code-is-Truth):

1. **§D.0 rewritten** — #235's "Medium" was a **MISLABEL**: ran on free/micro-equiv compute the
   whole time (`max_connections`=60 = free/micro value, not Medium's 120; Pro **org** ≠ project-Medium
   **compute**, add-on is per-project). #235 was already a free-tier run, at tiny load.
2. **Reframed:** today's run = **same compute class** as #235, NOT a Medium→free step-down. Distinct
   value = degradation ramp (§D.2 Phase B) + sustained-minutes + 50k backfill the tiny run never did.
3. **§C.7 prerequisite added:** ratifiable dedicated baseline REQUIRES the Medium compute add-on
   **per-project** (Pro-org insufficient — proven); verify `max_connections` live (~120) before
   trusting the label. Knee target made cap-relative (80–90% of live cap), not hardcoded 48–54.
4. **Cited** learning `2026-05-26_hosted-load-test-medium-compute-was-a-mislabel` + msg 1061/1063.

Also flagged Part C inline for consistency (intro mislabel marker, C.3 lesson sharpened, pooler
600→~200 so ~100 clients ≈50% not 17%) — historical proposal preserved per P-001.

**Run profile (D.1–D.8) UNCHANGED — framing/provenance only.** Does NOT block brew-ops provisioning
(msg 1059) — parallel. PR #252 ready for user merge. I'll fold the same truth into the post-run D.6
verdict when next-impl's curves land.
