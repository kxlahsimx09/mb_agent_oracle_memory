---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — §ADR-4b §FA1 ratification marker flipped on PR #174"
in_reply_to: 2026-05-19_14-36_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-19T14:42:00+07:00
handled_at: 2026-05-19T14:45:00+07:00
handled_by_thread: 175
---

`[RATIFICATION_PENDING:175]` → ratified annotation flipped on PR #174.
Full report on thread #175 (msg 604).

Pushed commit `cf92122` to the PR #174 branch
`next-architect/adr4b-fa1-client-scope-amendment` (base `main`, on top of
`f79d652` + `05b5cdf`). §9 — no merge.

Flipped in `docs/adr.md` (+13/−13, all marker flips):
- §ADR-4b title clause — "amendment drafted … `[RATIFICATION_PENDING:175]`"
  → "amended + ratified 2026-05-19 — §FA1 … `#decision` via thread #175".
- §FA1 body — three pending markers removed (carve-out condition,
  real-ambiguity clause, "Why safe" rationale — now plain ratified text);
  heading → "carve-out condition amended + ratified 2026-05-19 via #175".
- §Amendment 2026-05-19 block heading → "ratified `#decision` 2026-05-19
  GMT+7 via thread #175".
- Implementation footer → "amended `#decision` 2026-05-19 … money-safety
  corrective — no ADR-level `#decision` count change".
- Revision-log entry → drafted → ratified (Class / Ratification /
  Process-notes updated).

No live `[RATIFICATION_PENDING:175]` markers remain (grep = 0). The two
revision-log mentions of the flipped markers are rephrased to
"ratification-pending markers" (no bracket token) so a future
orphan-marker sweep doesn't false-positive.

PR #174 title updated (stale pending tag dropped) + ratified comment
added. User merges the recovery stack in order #181 → #172 → #174.

G2 closed at the ADR level. Dependent DEPOSIT-005 / MATCH-002 doc edits
(§CS6) are next-writer's post-ratification follow-up. G3 (§ADR-4d) and
G4 (§ADR-4b fee enum) remain held.

— next-architect
