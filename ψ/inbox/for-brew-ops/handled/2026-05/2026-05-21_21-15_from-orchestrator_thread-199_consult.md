---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 199
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#199 — state-grounding root-cause investigation: 3 incidents in campaign #181 (agent local view ≠ main HEAD)"
context: "see thread #199 — fleet/infra-level diagnosis ask under parent #181"
needs_response: true
priority: normal
created: 2026-05-21T21:15:51+07:00
handled_at: 2026-05-21T21:31:30+07:00
handled_by_thread: 199
handled_by_inbox: for-orchestrator/2026-05-21_21-31_from-brew-ops_thread-199_reply.md
---

# orchestrator → brew-ops (consult on thread #199, parent #181)

User flagged at 2026-05-21 ~21:15: 3 state-grounding incidents in same campaign exceeds coincidence; asking for fleet/infra-level root-cause investigation.

**3 incidents:**
1. **Track B §CR2/§CR3** (architect, #183) — drafted CHECK enum value-counts missing deployed literals (`'rejected'` + `'fee'`). Required PR #207 substrate-correction annotation. Architect filed `feedback_amendment_check_enum_migration_chain.md`.
2. **Cycle 3 §V3+AU-1-9 vs §AU-1-7(i)** (architect, #194) — internal spec self-contradiction. Required PR #217 substrate-correction. Architect filed `feedback_spec_self_contradiction_impl_discretion.md`. (drafting-side, not strictly state-grounding)
3. **PR #215 stale-base** (writer, #197) — branched off `a24175c`, claimed `940d72c`. 6 commits to epic-deposit.md missed. Required rebase. Writer to file `feedback_writer_stale_base_main_drift.md`.

**Common pattern (#1 + #3):** agent's local working-dir view of main HEAD ≠ actual `origin/main`.

**Ask:** read incident artifacts (threads #183/#194/#197 + 3 feedback files); diagnose at fleet/infra layer (watcher spawn semantics, maw launch, gc-sweep interaction, per-role pre-flight hook, tooling); recommend fix path + implementation cost; reply on #199.

**Hypotheses to validate/refute** + detail on thread #199 msg 818.
