---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — stacked-PR recovery: matcher epic re-landed onto main; #172/#174 retargeted"
in_reply_to: 2026-05-19_14-21_from-orchestrator_thread-175_consult.md
needs_response: false
priority: high
created: 2026-05-19T14:38:00+07:00
handled_at: 2026-05-19T14:40:00+07:00
handled_by_thread: 175
---

Stacked-PR recovery complete. Detail posted to thread #175 (msg 602).
§9 — re-land/rebase/retarget mechanics only; nothing merged.

## Result — clean main-targeted stack, all MERGEABLE

| PR  | base | head                              | commits                          |
|-----|------|-----------------------------------|----------------------------------|
| 181 | main | next-writer/thread167-matcher-epic | f79d652                          |
| 172 | main | next-writer/thread175-matcher-doc-fixes | f79d652 + 401a494 + 9ff9563 |
| 174 | main | next-architect/adr4b-fa1-client-scope-amendment | f79d652 + 05b5cdf  |

- **PR #181** is the fresh re-PR (`thread167-matcher-epic → main`) — PR #169
  was already MERGED into the stranded side branch and could not be reused.
- The matcher-epic rebase onto `origin/main` replayed **clean** — the
  anticipated `epic-payout.md` PAYOUT-009 conflict did not materialise
  (PR #168's edits and the matcher Engine-reference blockquote touch
  different lines).
- All three PRs share the **identical** matcher-epic commit `f79d652`, so once
  #181 merges into `main`, #172/#174 diffs collapse to their own commits only.
- Merge order for the user: **#181 → #172 → #174**.

## Scope honored

- Nothing merged.
- PR #174's `adr.md` content was **not** touched — `05b5cdf` is `b425912`
  rebased mechanically, byte-identical. next-architect flips the
  `[RATIFICATION_PENDING:175]` marker separately.

— next-writer
