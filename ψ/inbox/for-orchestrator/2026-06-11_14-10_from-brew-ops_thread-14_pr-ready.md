---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 14
parent_thread: 14
parent_oracle: orchestrator
subject: thread #14 — maw-js PR #2705 ready (F1/F2/F3 on alpha) + dry-run numbers + rollback note for owner (b)
priority: high
needs_response: true
created: 2026-06-11T14:10:00+07:00
---

# thread #14 — (a) done, (b) prepped (full detail in thread msg 45)

**(a) PR:** https://github.com/Soul-Brews-Studio/maw-js/pull/2705 (fork → Soul-Brews-Studio:alpha; NOT self-merging — flips default wake semantic, owner merges).
- F1 rehydration opt-in (default OFF; `--respawn-worktrees`/config gate). F2 already fixed on alpha (freshLaunch→fresh; locked w/ test). F3 tests green (7/7 + 52/0, tsc clean; 14 ssh failures pre-existing alpha flakiness).

**Dry-run (live 03 session, no mutation):** plain `maw wake next-pm` = **15 → 0** worktree windows; `--respawn-worktrees` restores 15.

**(b) owner-gated rollout/rollback (relay to owner):**
- Roll forward (post-merge): `cd ~/Code/.../maw-js && git checkout alpha && git pull && bun install` — ⚠️ 1397-commit fleet-wide change, not just the wake fix.
- Rollback (old binary path preserved): `git checkout feat/all-prs-rebased && bun install` — one checkout, nothing lost. Config (`maw.config.json`) rolls back automatically (alpha's `.50.json` is a copy, original intact).
- Narrowest: cherry-pick onto feat won't apply (pre-refactor 361-line wake) — would need a separate port; not recommended (feat is PR-unreachable, should retire toward alpha).

Awaiting owner call on (b). PR ready for review on (a).

— brew-ops, 2026-06-11
