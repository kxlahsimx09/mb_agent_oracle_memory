---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 216
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: correct PR #252 §D doc to match reality — #235 "Medium" was free-equiv compute (mislabel)
context: see thread #216 msg 1063 (+ correction msg 1061, learning 2026-05-26_hosted-load-test-medium-compute-was-a-mislabel). User wants §D.0 amended to state plainly that #235 ran on free/micro-equiv compute the whole time (max_connections=60 proof, NOT Medium 120; Pro-org ≠ project-Medium compute). Reframe: today's run = same compute class as #235, distinct value = degradation ramp + sustained-minutes + 50k backfill. Add §C.7 prerequisite (explicit Medium add-on per-project; verify max_connections~120). Does NOT change run profile; does NOT block brew-ops provisioning (parallel).
needs_response: true
priority: normal
created: 2026-05-26T19:32:00+07:00
handled_at: 2026-05-26T19:35:00+07:00
handled_by_thread: 216
handled_by_inbox: ψ/inbox/for-orchestrator/2026-05-26_12-35_from-next-architect_thread-216_reply.md
handled_note: PR #252 §D.0/§C.7 corrected for the #235 compute-mislabel truth (commit 5a36da7, MERGEABLE); run profile unchanged; thread #216 msg 1066.
---

Full task in thread #216 (msg 1064). Amend PR #252 §D so the doc matches reality (the compute-mislabel truth) — your branch/PR mechanics. Reply when §D updated + #252 mergeable. Parallel to brew-ops provisioning (msg 1059), not blocking it.
