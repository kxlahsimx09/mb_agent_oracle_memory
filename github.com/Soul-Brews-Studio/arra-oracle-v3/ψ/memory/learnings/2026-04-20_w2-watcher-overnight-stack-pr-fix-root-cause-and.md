---
title: W2 watcher overnight stack-PR fix — root cause and procedure (2026-04-20).
tags: [w2, watcher, pr-stack, amend, spec-fix, brew-ops, repo:cross, fleet, workflow, mcp-tools, P-002]
created: 2026-04-20
source: brew-ops session 2026-04-20 GMT+7; commits in mb_agent_oracle_memory main: 9d61e3 (stage overnight) → 3d42b36 (arra_learn prose) → 0357769 (W2 split) → f9757b1 (AGENTS §3a). Empirical precedent: retro 2026-04/20/10.25_w2-extend-pr242-bank-rotation-f694dcd.md.
project: github.com/soul-brews-studio/arra-oracle-v3
---

# W2 watcher overnight stack-PR fix — root cause and procedure (2026-04-20).

W2 watcher overnight stack-PR fix — root cause and procedure (2026-04-20).

The W2 watcher (arra-oracle-v3/scripts/w2-watcher.sh) is correct by design — settle 30 min, min_gap 2 hr, ignore-authors filter — and produced 5 firings overnight 2026-04-19→20 covering legitimate trackable commits in mobiz and bank-bot. The PR-stack pathology was upstream in the W2 spec: Step 8 (mobiz) / Step 6 (bank-bot) always created a fresh branch + PR without checking for an open W2 PR on the same repo. With the watcher firing daily and human-review latency typically &gt; 24h, every settled-commit cycle stacked a fresh PR fully superseding the prior unmerged one. Six PRs landed overnight (#83/#85/#86 bank-bot, #238/#241/#242 mobiz) all baselined at the same commit (0ea0e80 / 1ffafc1) — each fully covering the previous.

Fix landed mb_agent_oracle_memory main commit 0357769 (sibling-synced both repos): Step 8.0 / 6.0 is now a detect step (gh pr list --search "head:docs/track- state:open" --author "@me"). If non-empty, the pass takes the amend path (8.A / 6.A): checkout existing branch, merge origin/main, layer new commits, gh pr edit to rewrite title+body to cumulative range. Otherwise the new-PR path (8.B / 6.B) runs unchanged. DoD requires open-W2-PR count by @me to be ≤ 1 at end of pass. The amend procedure mirrors what pg-writer manually did at 2026-04-20 10:25 GMT+7 to extend mobiz PR #242 (retro 2026-04/20/10.25_w2-extend-pr242-bank-rotation-f694dcd.md) — that retro's Honest Feedback explicitly requested the spec change, citing the four exact steps the new procedure encodes (P-002 in action: codified the working pattern instead of inventing a new one).

Discipline preserved across the change: docs/.baseline still bumps only at completion of in-territory work, never on amend; trace chain (Step 2b) extends across amends; "never gh pr merge" unchanged. Cleanup of the 6 stacked PRs themselves is a human triage task (review most-inclusive per repo, close subset PRs with supersede comment) — not part of the spec change.

---
*Added via Oracle Learn*
