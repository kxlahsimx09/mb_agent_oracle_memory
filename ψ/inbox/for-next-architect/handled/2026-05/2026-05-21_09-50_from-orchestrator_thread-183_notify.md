---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: notify
thread: 183
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#183 — Track B unblocked: Cycle 1 fan-out merged (PR #202 + #203); cleared to draft per locked refined scope"
context: "wake envelope for thread #183 msg 719 — both Cycle 1 fan-out PRs landed on main, gating cleared"
needs_response: true
priority: normal
created: 2026-05-21T09:50:56+07:00
handled_at: 2026-05-21T10:00:15+07:00
handled_by_thread: 183
handled_by_inbox: for-orchestrator/2026-05-21_10-00_from-next-architect_thread-183_reply.md
handled_note: "Track B drafted per locked refined scope on branch next-architect/adr4d-adr4b-track-b-review-canonical-rename off main@6d20710 (rebases clean). PR #204 opened (fork, no merge per §9). Amendment §CR1..§CR11 + §Resolved-questions block landed in §ADR-4d; inline annotation added to §ADR-4b §FA2 line ~605 (§H3-Fix precedent). 28 [RATIFICATION_PENDING:183] markers in live body. Three shape decisions flagged for user-ratify-ask surfacing: (1) §CR2 drops 'review_required' with no replacement (deposit lane carries human-review semantic on match_status, not status); (2) §CR5 leaves 'review' ghost-token in §V15-2 predicate as deliberate-no-op; (3) §FA2 inline annotation in §ADR-4b, not separate amendment block. Reply on thread #183 msg 721 + reply envelope written. ADR-level #decision count unchanged at 19."
---

# orchestrator → next-architect (notify on thread #183, parent #181)

Both Cycle 1 fan-out PRs merged:
- **PR #202** (next-writer): merged 2026-05-21T02:47:33Z → `37fe77f`
- **PR #203** (next-impl): merged 2026-05-21T02:48:15Z → `6d20710`

main now at `6d20710`. Cycle 1 sub-threads closed (#182 architect, #184 impl, #185 writer).

**Cleared to draft Track B** per the user-ratified refined scope (msg 700 table + `poc/4a/` cleanup fold-in):

- Deposit-side substrate canonicalization:
  - `ts_deposits.status` CHECK drops `'review_required'`
  - `bank_statements.match_status` CHECK drops `'review_required'` (keeps only `'review'`)
  - `poc/integration/src/rpc/deposit/match_deposits_cascade.sql:105/109` rewrites `'review_required'` → `'review'`
  - `poc/4b/src/match_deposits_cascade.sql:100` same rewrite (or retire `poc/4b/` layer at your discretion)
  - `hosted-assertions.ts:181-185` field rename
  - §V15-2 predicate update `('paid','pending','review')` → `('paid','pending','checking','review')`
- Withdrawal-side: NULL (already canonical via §Amendment 2026-05-16 thread #123)
- `poc/4a/src/lifecycle_rpcs.sql:183` callback INSERT-branch removal (folded into Track B PR)
- Drop deprecated alias cleanly on both deposit CHECKs (no transient alias)

Branch off `main@6d20710`. `[RATIFICATION_PENDING:183]` markers. Reply on thread #183 with PR link + shape-decision flags.

Full context: thread #183 msg 719.
