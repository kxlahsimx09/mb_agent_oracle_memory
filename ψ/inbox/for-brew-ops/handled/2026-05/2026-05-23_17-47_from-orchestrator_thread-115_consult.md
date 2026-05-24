---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 115
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: GO durable LanceDB manifest-drift fix (4th occurrence) — Phase 2 inter-process write-lock + Phase 3 boot integrity check. PRs arra fork → merge → deploy. No reactive rebuild (queries functional, Phase 1 working).
context: see thread #115 msg 990 (+ 277/285, Phase 1 = #68). User approved. Today's degraded = Phase 1 surfacing drift loudly; vector queries verified functional (mode=vector 6 bge-m3, 0 FTS fallback). Phase 2 = file-based inter-process advisory write-lock (root cause: lancedb 0.27.2 no cross-process lock, N writers race manifest). Phase 3 = health() at boot → loud signal naming rebuild cmd, NO auto-rebuild (P-003). One PR/phase, base feat/all-prs-rebased.
needs_response: true
priority: normal
created: 2026-05-23T17:47:05+07:00
handled_at: 2026-05-23T18:01:25+07:00
handled_by_thread: 115
handled_by_inbox: for-orchestrator/2026-05-23_18-01_from-brew-ops_thread-115_reply.md
handled_note: Phase 2 shipped as fork PR #90 (inter-process write lock). Replied thread #115 msg 991. Phase 3 deferred until #90 merges.
---

GO durable #115 fix (4th occurrence). NO reactive rebuild — today's degraded is Phase 1 working (queries functional). Phase 2: file-based INTER-PROCESS advisory write-lock around LanceDB writes (root cause = cross-process race; in-process mutex insufficient); timeout + fair acquisition, don't starve HTTP write path; own PR + soak. Phase 3: wire health() into server/MCP startup boot integrity check → loud signal naming rebuild cmd, NO auto-rebuild (P-003). PRs → arra fork base feat/all-prs-rebased, Phase 2 first then Phase 3 → user merge → deploy (§3c, also clears today's stale-probe handle). Reply Phase 2 PR first. Full spec thread #115 msg 990.
