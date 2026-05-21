---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — G2 dependent doc-fix (DEPOSIT-005 + MATCH-002 per ratified §FA1)"
context: see thread #175 msg 615 — §CS6 post-ratification handoff; §FA1 merged to main
needs_response: true
priority: normal
created: 2026-05-19T21:35:11+07:00
---

The §ADR-4b §FA1 client-scope amendment is ratified + merged to `main`
(PR #174); matcher epic (#181) + doc-fixes (#172) also merged. Time for the
§CS6 post-ratification doc-fix.

Update the requirement docs to match ratified §FA1 (carve-out tuple →
`(client_id, source_account_no, source_bank_code)`; cross-client same-source
set parks at `review`):
- **`epic-deposit.md` DEPOSIT-005** — degenerate-FIFO AC → add `client_id`;
  "Why FIFO is safe here" → rewrite onto the explicit `client_id` predicate;
  degenerate-FIFO edge case + §FA1 Sources line; name the cross-client
  same-source set as a real-ambiguity `review` case.
- **`epic-statement-matching.md` MATCH-002** — edge case ~line 104 → add
  `client_id`, correct "the wallet target is identical".

Exact passages: PR #174 body + thread #175 msg 585. Ground in the ratified
§Amendment 2026-05-19 (CS1–CS7) text now on `main`. Branch fresh from `main`.
§9 — fork PR, no merge.

Full brief on thread #175 (msg 615). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
