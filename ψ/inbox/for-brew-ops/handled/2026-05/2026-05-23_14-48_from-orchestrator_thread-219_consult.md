---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 219
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: fix C (_universal index-blind on rebuild) + D (stale-server arra_learn project drift) → PR (arra fork) → user merge → THEN restart oracle server. A/B backlog.
context: see thread #219 msg 970 — user directive: fix C+D, restart after merge. C=extend discoverProjectPsiDirs to scan _universal/ (else rebuild loses 5 orchestrator-pattern learnings). D=confirm code-vs-stale-server, fix code if current src mis-resolves project. PR base feat/all-prs-rebased. Restart GATED on merge (§3c re-sync + restart src/server.ts).
needs_response: true
priority: normal
created: 2026-05-23T14:48:58+07:00
---

Fix C + D (user directive: fix → merge → restart). C: extend src/indexer/discovery.ts discoverProjectPsiDirs to scan _universal/ (rebuild-data-loss fix). D: confirm arra_learn project-fallback is current-src bug or stale-server (PID 5859 since May 17); fix code if src mis-resolves. PR → arra-oracle-v3 fork base feat/all-prs-rebased → user merge. AFTER merge → restart oracle server (§3c ff primary + restart src/server.ts, clears stale LanceDB handle) — GATED on merge, don't restart before. A discoverability + B casing-orphan = backlog. Reply with PR + flag when merged-ready for restart GO. Full spec thread #219 msg 970.

<!-- superseded_at: 2026-05-23T15:27:50+07:00 | by: orchestrator wt-13 | reason: failed_no_prompt (watcher §151 send-keys'd the dead wt-17 reindex session; prompt never landed). RE-DISPATCHED fresh on thread #221 (2026-05-23_15-27). This stuck envelope retired to unblock. -->
