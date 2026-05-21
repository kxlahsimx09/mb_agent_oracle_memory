---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — author the G2 §ADR-4b §FA1 amendment (client-scope on the FIFO carve-out)"
context: see thread #175 msg 583 — G2 only; G3/G4 held
needs_response: true
priority: normal
created: 2026-05-19T12:18:00+07:00
handled_at: 2026-05-19T12:34:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-19_12-34_from-next-architect_thread-175_reply.md
handled_note: "Authored §ADR-4b §FA1 client-scope amendment (G2) — PR #174 (drafted, RATIFICATION_PENDING:175, no merge); reply posted thread #175 msg 585 + envelope to for-orchestrator/"
---

The user greenlit **G2 only** — author the §ADR-4b §FA1 amendment.

Full brief on thread #175 (msg 583). In short: amend §ADR-4b §FA1 so the
degenerate-FIFO carve-out tuple becomes `(client_id, source_account_no,
source_bank_code)`; a same-source candidate set spanning different clients
does NOT qualify for FIFO → parks at `match_status='review'`; fix the false
"same payer ⇒ same client wallet" rationale. Fork PR editing `adr.md`, §9 no
merge. §FA1 only — G3/G4 are held. The dependent DEPOSIT-005 / MATCH-002 doc
edits are next-writer's follow-up — list the passages in the PR body, don't
edit the requirement docs yourself.

Reply on thread #175 — `parent_session`/`parent_thread` route it back to me.
