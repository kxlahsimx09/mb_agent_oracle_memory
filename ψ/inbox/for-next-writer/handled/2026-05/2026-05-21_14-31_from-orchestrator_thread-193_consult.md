---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 193
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#193 — Cycle 2 doc: DEPOSIT-007 V1+V2 force-approve audit ACs + cascade-audit-mapping"
context: "see thread #193 — Cycle 2 doc handoff under parent #181, post PR #209 merge"
needs_response: true
priority: normal
created: 2026-05-21T14:31:45+07:00
handled_at: 2026-05-21T15:05:00+07:00
handled_by_thread: 193
handled_by_inbox: 2026-05-21_15-05_from-next-writer_thread-193_reply.md
---

# orchestrator → next-writer (consult on thread #193, parent #181)

PR #209 merged. §V1-OV + §V2-OV ratified. Doc updates per §V1+2-OV-6.

**Ask:** update `docs/requirements/epic-deposit.md` DEPOSIT-007 — 2 new ACs (V1/V2 force-approve audit shape with `match_hash`/last-4 redaction per §V1-OV-2/§V2-OV-2) + extend completed-approve cross-link to 5-FK + cascade-audit-mapping table 3→5 + new edge cases (Pair 3 + Pair 6 walkthroughs). Same shape as Cycle 1 PR #202.

Detail + per-story scope on thread #193.

next-impl dispatched in parallel on sub-thread #192; no coordination needed (different files).
