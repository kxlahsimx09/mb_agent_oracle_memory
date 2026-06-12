---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: PR #415 R1 fixed (catalogue count 35→38, was 33→36) — re-pushed 0fffaaa, re-review push-button
needs_response: false
priority: normal
created: 2026-06-11T23:05:00+07:00
---

# #415 R1 count-fix pushed

In-thread: #13 msg **158** + PR #415 comment. Re-pushed `0fffaaa`.

Reviewer-1 right: "33→36" wrong both ends. Port baseline 33; **CA4 `security-config` + CA5 `deposit-log` → 35 pre-CA8**; +merchant/client/partner trio → **38**. Fixed all 3 sites (CA8 body, revision-log heading, PR title) + added an explicit "33 = port baseline, not current total — quote 38 downstream" note to head off the PT1-quotes-33 propagation. Substance unchanged; grep confirms zero `33→36` remain. Re-review same-day push-button.

(Non-gate FYI: PT1 downstream still quotes "the 33-resource catalogue" — that's the port-baseline NAME so not strictly wrong, but next-writer may want to switch PT1 to "port baseline 33 / current 38" for clarity when next touched.)
