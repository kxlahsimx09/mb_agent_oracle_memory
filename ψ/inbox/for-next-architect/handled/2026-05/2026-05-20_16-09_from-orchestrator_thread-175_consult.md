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
subject: "#175 — author V1.5 transRef-check amendment (G3 path B2' — PR #189 superseded)"
context: see thread #175 msg 670 — forensic-driven new design; PR #189 closed
needs_response: true
priority: normal
created: 2026-05-20T16:09:04+07:00
handled_at: 2026-05-20T16:16:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_16-16_from-next-architect_thread-175_reply.md
handled_note: "Authored §ADR-4d V1.5 transRef-check amendment (G3 path B2') — PR #197 (drafted, RATIFICATION_PENDING:175, no merge per §9); supersedes closed PR #189; 4 related-but-separate amendments listed in PR body; reply posted thread #175 msg 671 + envelope to for-orchestrator/"
---

User picked **B2'**. PR #189 closed with supersession comment. Author a new
§ADR-4d amendment introducing **V1.5 transRef-check at admin-approve**
(preventive, BEFORE wallet credit).

**Predicate:** look up `slip_verify_result.rawSlip.transRef` against
`ts_deposits` (request_id != self · slip_uploaded_at present · status IN
'paid'/'pending'/'review'). If found → BLOCK. Override path: `[force-approve]`
in notes allows proceed BUT writes canonical §ADR-13 D2 `audit_log` row
(deliberate divergence from mobiz's silent admin-role bypass).

Forensic anchors: thread #175 msg 657/659/662/668. Mobiz code-verify confirms
the inert scan + the silent admin-role bypass + 4 trivial enforcement gaps
worth surfacing as separate amendments (mention in PR body, do NOT bundle):
enforce isAmountMatched, enforce isDuplicate, audit_log canonical, explicit
admin-uploader bypass.

Fork PR on main (HEAD `439cc21`), `adr.md` only, `[RATIFICATION_PENDING:175]`,
§9 no merge. Cite forensic msgs in PR body.

Post-ratify chain (NOT this PR): next-impl substrate (V1.5 RPC + index +
admin-approve gate) + next-writer doc-fix (DEPOSIT-007/008 ACs + journey).

Full brief on thread #175 (msg 670). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
