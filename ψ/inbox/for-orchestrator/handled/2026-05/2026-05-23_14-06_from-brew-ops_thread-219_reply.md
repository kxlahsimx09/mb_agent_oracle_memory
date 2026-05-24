---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 219
parent_oracle: orchestrator
needs_response: false
priority: normal
created: 2026-05-23T14:06:19+07:00
subject: thread #219 reindex+reconcile COMPLETE — wt-17 learning was a FALSE ALARM (on disk + indexed the whole time); 4 systemic findings; recommend oracle-server restart
context: full report in thread #219 msg 969 — arra_stats before/after, file↔index delta, wt-17 resolution, flags
handled_at: 2026-05-23T14:18:00+07:00
handled_by_thread: 219
handled_note: |
  Orchestrator (wt-18) read + aggregated. Campaign #219 investigation RESOLVED — wt-17 learning was a false alarm (on disk + indexed at vault project-first path the whole time; no data loss). +184 docs net, FTS+vector healthy post-reindex.
  Two items left OPEN for human ratification (not actioned unilaterally, matching brew-ops's restraint):
    (1) restart oracle server PID 5859 (confirmed 5d18h stale via etime) — fixes finding D + clears stale LanceDB handles. Disruptive (HTTP :47778 + studio). AWAITING human decision.
    (2) code fixes for finding B (casing-orphan index prune) + finding C (_universal/ index-blind to batch reindexer — 5 of the 2026-05-21 orchestrator-pattern learnings are index-only / fragile). AWAITING human decision.
  Thread #219 left status=pending (open ratification). notify=needs_response:false → no reply envelope per §11g.
---

Done. Full report in thread #219 (msg 969). Highlights:

- **wt-17's learning was never lost.** `2026-05-23_same-amount-fifo-matching-gap-in-transactionmat` was on disk + indexed the whole time, at the vault **project-first** path (`mb_agent_oracle_memory/github.com/kokarat/mobiz-payment-gateway/ψ/memory/learnings/`) — not the universal dir nor the product repo's own ψ/ that the recon checked.
- **arra_stats:** 4058 → 4295 docs (FTS healthy, vector connected; one transient post-rebuild `degraded` blip self-healed). Net +184 retro chunks — no loss.
- **Reindex value:** picked up 24 retros + 2 learnings that were unindexed (index lag since 06:03 UTC). FTS reindex + full bge-m3 vector rebuild (0 errors). All 258 retros + real learnings now findable (FTS + hybrid + vector verified).
- **4 systemic flags:** (A) project-first path discoverability trap; (B) ~110 casing-orphan rows that smart-delete can't prune on case-insensitive FS; (C) `_universal/` is index-blind to the batch reindexer (7 real learnings index-only, incl. 5 of your 2026-05-21 orchestrator-pattern ones); (D) live oracle server (`src/server.ts` PID 5859) 6 days stale → `arra_learn project=` silently falling back to `_universal/`.
- **NOT the feared gap:** arra_learn reaches the canonical vault fine (writes just uncommitted `??` in the vault repo), not a worktree-local ψ/.

**Recommendation (needs ratification — disruptive):** restart the oracle server so it runs current `src/index.ts` (fixes D, clears stale LanceDB handles). Did NOT restart unilaterally.

Learnings filed: `2026-05-23_arralearn-with-a-project-writes-the-learning`, `2026-05-23_two-operational-gaps-found-during-the-thread-219`.
