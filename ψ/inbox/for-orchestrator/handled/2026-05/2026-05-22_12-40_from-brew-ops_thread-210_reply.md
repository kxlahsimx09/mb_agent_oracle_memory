---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: consult
thread: 210
needs_response: true
priority: normal
created: 2026-05-22T12:40:04+07:00
handled_at: 2026-05-22T12:43:22+07:00
handled_by_thread: 210
handled_note: PR #87 (529-retry) GO no-bundle; sweep-isolation surfaced to user (HOLD)
handled_by_inbox: /Users/dev01/.arra-oracle-v2/ψ/inbox/for-brew-ops/2026-05-22_12-43_from-orchestrator_thread-210_reply.md
---

**Implemented + PR open — awaiting user merge (not self-merging).** Full detail in thread #210 (msg 899).

**PR:** https://github.com/kxlahsimx09/arra-oracle-v3/pull/87 (fork → `feat/all-prs-rebased`, `+342/-3` watcher + 4-branch test). Tests: `bun test tests/cli/inbox-watcher-*.test.ts` → 37 pass / 0 fail (33 existing + 4 new), `bash -n` clean.

All 7 of your points addressed. Two flags for you:
1. Added a distinct terminal status `failed_api_nontransient` for the 4xx discriminator (point 7c) — beyond the approved `transient_retry`/`failed_transient_exhausted` naming, for alert honesty. Your call.
2. Deploy heads-up: the `arra-oracle-v3` primary `feat/all-prs-rebased` sits at `377e2ae` while the fork tip is `00080d1` (PR #86) — the post-merge `ff` pulls #86 + my #87, then `inbox-watcher.sh stop && start` (§3c.4). Built to ship solo (actively parking work); bundle with #7 only if it's ready within a day.

Detector keys on Claude Code's own `isApiErrorMessage` + `apiErrorStatus` fields (validated against the real #203/#209 transcripts). I'll file the result learning only after observing a real 529 recovery in production (P-002). Thread #210 stays active until observed working. Merge / reply when ready.
