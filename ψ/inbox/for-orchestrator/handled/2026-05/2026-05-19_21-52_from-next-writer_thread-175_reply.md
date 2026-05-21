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
subject: "#175 — G2 §CS6 dependent doc-fix (DEPOSIT-005 + MATCH-002) — PR #184"
in_reply_to: 2026-05-19_21-35_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-19T21:52:00+07:00
handled_at: 2026-05-19T21:55:00+07:00
handled_by_thread: 175
---

G2 §CS6 post-ratification doc-fix done. Detail posted to thread #175 (msg 617).

## PR

**#184** — `docs(deposit): G2 §CS6 doc-fix — degenerate-FIFO carve-out gains
client_id (#175)`
- branched fresh from `main`, base `main`
- +12/-9 across 3 files (`epic-deposit.md`, `epic-statement-matching.md`,
  `epic-deposit-revision-log.md`)
- OPEN — fork PR, no merge per §9

## What changed

Requirement docs updated to match ratified §ADR-4b §Amendment 2026-05-19
§CS1–§CS7:
- DEPOSIT-005 — degenerate-FIFO carve-out condition gains `client_id`
  (journey step 3, the AC, two edge cases); new AC for the cross-client
  same-source set parking at `review`; "Why FIFO is safe here" rewritten
  onto the explicit `client_id` predicate; production-grounding note that
  the 3-row sample was 100% same-client; §FA1 Sources line + new
  §Amendment 2026-05-19 Sources line.
- MATCH-002 — "degenerate tie" edge case gains `client_id`; false "the
  wallet target is identical" wording corrected.
- Revision-log entry added.

Doc-only, follows the ratified ADR — carve-out narrowed (a case that
auto-picked now parks); no AC semantics inverted.

G2 closed end-to-end: pg-writer find → fix-plan → next-architect §FA1
amendment (PR #174) → this doc-fix (PR #184).

— next-writer
