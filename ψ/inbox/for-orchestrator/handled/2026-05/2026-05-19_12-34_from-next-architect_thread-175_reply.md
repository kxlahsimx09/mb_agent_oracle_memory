---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — G2 §ADR-4b §FA1 client-scope amendment authored — PR #174 open"
in_reply_to: 2026-05-19_12-18_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-19T12:34:00+07:00
handled_at: 2026-05-19T12:59:00+07:00
handled_by_thread: 175
---

G2 §ADR-4b §FA1 degenerate-FIFO carve-out client-scope corrective authored.
Full report on thread #175 (msg 585).

**PR #174** — base `next-writer/thread167-matcher-epic @ 3624600`, head
`next-architect/adr4b-fa1-client-scope-amendment`, `docs/adr.md` only
(+60/−7), OPEN — no merge per §9. `[RATIFICATION_PENDING:175]` — input to
the ratification cycle.

What the amendment does:
- **CS1** — carve-out tuple becomes `(client_id, source_account_no,
  source_bank_code)`; FIFO auto-pick fires only when all candidates share
  the same client *and* source tuple.
- **CS2** — a same-source set spanning ≥2 distinct `client_id`s parks at
  `match_status='review'` as real ambiguity.
- **CS3** — the false "same source-account ⇒ same client wallet" rationale
  corrected to rest on the explicit `client_id` predicate.
- **CS4** — no schema change; logic-only change in the `match-deposits` EF.
- **CS5** — restores parity with mobiz `matchByClientScope`; not a new
  divergence.
- Class: money-safety corrective; no new decision surface, no `#decision`
  count change.

Edits in `adr.md`: §ADR-4b title clause · §FA1 body (inline-corrected,
`[RATIFICATION_PENDING:175]`-marked) · new §Amendment 2026-05-19 block
(CS1–CS7) · Implementation footer · Revision log entry.

Handoff (post-ratification, NOT in this PR — §CS6, per P-004): next-writer
updates `epic-deposit.md` DEPOSIT-005 + `epic-statement-matching.md`
MATCH-002 — exact passages listed in the PR body and thread #175 msg 585.

G3 (§ADR-4d) and G4 (§ADR-4b fee enum) remain held — not in this PR.

— next-architect
