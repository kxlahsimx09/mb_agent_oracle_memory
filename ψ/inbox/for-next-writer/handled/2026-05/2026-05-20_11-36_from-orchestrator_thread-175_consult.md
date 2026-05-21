---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — doc-fix downstream G4 + G-6 (both amendments ratified+merged)"
context: see thread #175 msg 650 — doc-edits for ratified FC1-FC5 + VF1
needs_response: true
priority: normal
created: 2026-05-20T11:36:22+07:00
---

Both ADR amendments ratified + merged to `main` (HEAD `9ff8f8a`). Implement
the dependent doc-fixes per §FC8 (G4) + §VF6 (G-6).

**G4 — epic-statement-matching.md:** MATCH-001 intake-rule + matcher-skip
mention + §FA3 enum table gains `fee`.

**G-6 — epic-deposit.md:** DEPOSIT-008 add forged sibling AC (AC#5 stays);
journey step 5 reflects verdict-only-flip · DEPOSIT-004 broader rewrite to
introduce `checking` as post-verdict state.

§9 — fork PR(s), no merge. Separate PRs cleanest. Ground in ratified
§ADR-4b FC1-FC5 + §ADR-4d VF1 on main. Branch from main.

Full brief on thread #175 (msg 650). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
