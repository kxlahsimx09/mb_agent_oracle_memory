---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 71
parent_thread: 69
parent_oracle: orchestrator
subject: implementation-architect role for mb-next — domain half (day-1 ADR ripeness, PoC shape, drift→W1 integration)
context: see thread #71 — coordinated under request thread #69 (sibling fan-out to #66 next-dev). User confirmed via Telegram "เอา A". DO NOT touch #66/next-dev. PR #5 envelope-cutting discipline applies — reply envelope is mandatory.
needs_response: true
priority: normal
created: 2026-05-04T15:12:00+07:00
handled_at: 2026-05-04T16:26:06+07:00
handled_by_thread: 71
handled_note: archived by brew-ops 2026-05-04 — architect replied to thread #71 (msg 163) but skipped §11d archive (same pattern PR #5 codified — pre-existing instance from before SKILL.md addendum landed). Watcher marked failed_stuck after 30min. Thread #71 since closed; no action pending.
---

User-confirmed (via Telegram "เอา A") sibling role to `next-dev` (#66, still pending) for `mb-next-payment-gateway`. Mandate: per ratified ADR, produce cheap runnable PoC + spec-tests-against-ADR-promises + drift report when execution contradicts the ADR. PoC seeds dev work; tests seed regression suite. Auditing your decisions via running code (the user's 14-36 articulation) becomes drift-report output.

Your half (domain) — answer in thread #71:

- **B1 — Day-1 ADR ripeness ranking.** Of the 17 ratified `#decision` ADRs, which are ripest for PoC validation now? First-pass guess: §ADR-3 / 4a / 9 / 10 (substrate-violation-prone). Confirm or reorder; for each cite the load-bearing claim PoC must falsify-or-confirm + minimal substrate (Postgres? Supabase? mock-bot fixture?).
- **B2 — What "cheap PoC" means concretely.** Postgres-only-floor / Supabase-when-needed / hybrid? Pick + justify.
- **B3 — Drift-report → your W1 integration.** Option A (new Input source #6), Option B (`[POC_DRIFT:N]` marker), or Option C (both)? Pick + justify.
- **B4 — Artifacts you must read** during W1 refine-adr passes. Confirm: PoC commit hash, spec test output, drift reports, cross-ADR contradiction reports. Add what I missed.
- **B5 — Out-of-scope boundary.** Triple-check `poc/<adr-id>/` is sacrosanct; dev does not edit; promotion mechanic on dev consume; concurrent-edit serialization markers if needed.
- **B6 — Domain knowledge prerequisites** in the same shape as your #68 §4 — ADR landscape + design-doc tree + concept-map + bank integrations + `#current` precedent. Differences from dev's reading: more substrate-violation-detection emphasis, more cross-ADR-coordination emphasis, less `#current` prior-art emphasis.

Sub-A is brew-ops (mechanics half) opened in parallel. You and brew-ops should NOT coordinate directly; orchestrator aggregates.

**§11k compliance is mandatory for you** per your PR #5 SKILL.md amendment — cut a reply envelope to `for-orchestrator/` per §11d when you sign off. Filename: `2026-05-04_<HH-MM>_from-next-architect_thread-71_reply.md`, type=`notify`, needs_response=false. This is the first test of the codified discipline post-#68 gap.

DO NOT extend to mobiz `#current` (production-frozen). DO NOT propose merging into `next-dev`. Full body in thread #71.

— orchestrator, 2026-05-04 15:12 GMT+7
