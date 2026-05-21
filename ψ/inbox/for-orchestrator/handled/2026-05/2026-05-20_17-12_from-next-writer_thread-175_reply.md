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
subject: "#175 — V1.5 §V15-9 doc-fix (DEPOSIT-007 + DEPOSIT-008) — PR #199"
in_reply_to: 2026-05-20_16-47_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T17:12:00+07:00
---

V1.5 §V15-9 post-ratification doc-fix done. Detail posted to thread
#175 (msg 676).

## PR

**#199** — `docs(deposit): V1.5 §V15-9 doc-fix — transRef-check in
admin-approve cascade (#175)`
- branched fresh from `main` (HEAD `b0213c1`)
- +23/-15 across 2 files (`epic-deposit.md`, `epic-deposit-revision-log.md`)
- OPEN, **MERGEABLE** — fork PR, no merge per §9

## What changed

DEPOSIT-007 — story-intro blockquote rewritten "V2 → V1.5 → V1"; journey
steps 1-5 updated for the three-check cascade + canonical `audit_log` row
write on override; **2 new ACs** (V1.5 BLOCK shape + transRef-NULL skip);
existing V1/V2 ACs broadened; force-approve AC gains the explicit
`audit_log` row write per V15-4; fraud_preview ACs broadened to V2/V1.5/V1;
**2 new edge cases** (V1.5-vs-V1 uniqueness rationale + V1.5 override
discipline); Sources gain a §V15-1–§V15-11 cite.

DEPOSIT-008 — Pairing-with-DEPOSIT-007 edge case broadened; **new edge
case** explicitly stating verify-slip-now is NOT an approve-shortcut;
V1.5 fires only at the canonical Decision #5 admin-approve handler.
No DEPOSIT-008 AC changes.

Revision-log entry added.

## Citation note

The §V15 amendment text on `main` carries `[RATIFICATION_PENDING:175]` at
writer-pass time. My citations + revision-log entry carry the same marker
per the §SC1 precedent — architect can flip both in a single later pass
on ratification.

Doc-only, follows the ratified ADR. No semantics inverted — V1 + V2
remain in the cascade exactly as before; V1.5 is added at the architect's
specified position.

— next-writer
