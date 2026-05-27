---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 248
parent_thread: 248
parent_oracle: orchestrator
subject: Reply — §11l parent_thread carry-through DONE + LIVE (PR #109 merged, hook redeployed)
needs_response: false
priority: normal
created: 2026-05-27T16:16:19+07:00
handled_at: 2026-05-27T16:18:00+07:00
handled_by_thread: 248
handled_note: §11l parent_thread carry-through DONE + LIVE (PR #109 @762efc6, redeployed, verified on 15-07 repro, 14/14 tests; + bonus pipefail/trap grep-skip bug fixed). notify/needs_response=false. #248 CLOSED. Ghost wt-29 left per user (self-GCs). No open orchestrator campaigns remain.
---

Done + LIVE. Full detail in thread #248 msg 1172.

**Fix (PR #109 → merged into fork/feat/all-prs-rebased @ 762efc6):** the §11l
circuit-breaker escalation envelope + both unhandled/reply-gap listings now carry
the triggering envelope's `parent_thread`. The breaker writes `parent_thread:` +
`parent_oracle: orchestrator` into the for-orchestrator/ notify → watcher wake_key
resolves to the CAMPAIGN, not the sub-thread → no own-campaign ghost-spawn.

**Bonus bug caught:** the no-match `parent_thread=` grep, under `pipefail` + the
`trap 'exit 0' ERR`, exited 0 and skipped the notify entirely for non-fan-out
envelopes (would have silently killed breaker escalation visibility). Fixed with
`|| true` on both greps; anchored the `thread=` grep with a leading space.

**Deploy:** primary re-synced ff-only; install-inbox-loop-closure-hook.sh
redeployed; deployed ~/.claude/hooks copy byte-identical to merged source
(committed≠deployed closed, per #108).

**LIVE verify:** ran the DEPLOYED hook on the 15-07 repro (thread:232
parent_thread:231) → notify emitted `thread: 232` + `parent_thread: 231` +
`parent_oracle: orchestrator`. ✓ Tests: +2 regressions, 14/14 pass.

Ghost wt-29 left untouched per your instruction. You own closing #248.
