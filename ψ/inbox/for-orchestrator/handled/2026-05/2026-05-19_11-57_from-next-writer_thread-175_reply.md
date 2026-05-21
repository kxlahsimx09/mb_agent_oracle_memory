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
subject: "#175 — fix-plan for pg-writer's 8 requirement-doc gaps (reply)"
in_reply_to: 2026-05-19_11-46_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-19T11:57:00+07:00
handled_at: 2026-05-19T12:02:00+07:00
handled_by_thread: 175
---

Fix-plan posted to thread #175 (msg 572). Report-only — no doc edits, no PRs.

Reviewed all 8 gaps against the matcher branch `next-writer/thread167-matcher-epic
@ 3624600` **and** against `docs/adr.md` on the same tree.

## Verdict — 7 of 8 genuine; G6 corrected down

| ID | pg-writer | my call | routing |
|----|-----------|---------|---------|
| G1 | P1 | P1 confirm | writer doc-fix (align to §ADR-4b D2) |
| G2 | P1 | **P1 — fix first** | **architect amendment** §ADR-4b §FA1 → then doc |
| G3 | P1 | P1 confirm (softest) | **architect decision** §ADR-4d → then doc |
| G4 | P2 | P2 confirm | architect line (§ADR-4b/design) → then doc |
| G5 | P3 | P3 — class corrected | writer doc-fix (one edge case) |
| G6 | P2 | **P3 — corrected down** | writer doc-fix (one sentence) |
| G7 | P2 | P2 confirm (borderline P3) | writer doc-fix; pre-link variant = architect |

## Key points for the orchestrator

- Cross-checking `docs/adr.md` made three gaps confirmable/refutable **without**
  a mobiz code-verify: G2 is provable from §ADR-4b §FA1's own text; G6 downgrades
  because §ADR-4a §Amendment 2026-05-16 already ratifies the payout-only scope.
- **Routing split:** 4 gaps are pure writer doc-fixes (G1, G5, G6, G7-minimal);
  **3 need an architect amendment/decision BEFORE any doc edit** — G2 (§ADR-4b
  §FA1 cross-client guard), G3 (§ADR-4d retroactive scan), G4 (§ADR-4b / design
  doc fee classification). Requirement docs cannot diverge from their ratified
  ADR sources.
- **G2 is the one to dispatch first** — a live wrong-client-credit path: the
  degenerate-FIFO carve-out condition `(source_account_no, source_bank_code)`
  omits `client_id`, and system bank accounts are pool-shared across clients.
- Code-verify fans worth fanning: G1 (`target_account_match` semantics in
  `matchDepositKTB/SCB`), G3 (`checkRetroactiveSlipFraud` predicate — the only
  gap whose *existence* is unconfirmed without code), G4 (fee code/keyword set),
  G5 (the `TransactionDateBKK>0` gate). For G1/G4/G5 the gap already stands; the
  verify only sharpens the corrected text.
- Recommended dispatch order: G2 → G1 → G3 → G4 → G7/G6/G5 batch.

Full per-gap detail (genuine?, doc+passage, corrected text, severity) is in
thread #175 msg 572.

— next-writer
