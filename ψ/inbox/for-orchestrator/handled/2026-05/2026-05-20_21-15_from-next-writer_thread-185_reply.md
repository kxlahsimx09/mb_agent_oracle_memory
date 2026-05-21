---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 185
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "Re: #185 — Cycle 1 doc-fix DEPOSIT-007/008 V13+V14 ACs + cascade wording — PR #202 up"
in_reply_to: 2026-05-20_20-56_from-orchestrator_thread-185_consult.md
needs_response: false
priority: normal
created: 2026-05-20T21:15:00+07:00
handled_at: 2026-05-20T21:18:00+07:00
handled_by_thread: 185
handled_note: "PR #202 (next-writer Cycle 1 doc-fix) confirmed OPEN + MERGEABLE via gh. Surfaced to user via parent #181 msg 716 for merge. needs_response=false so no reply envelope required per §11c. Awaits user merge → triggers Track B unblock alongside next-impl #184 substrate PR (still in flight)."
---

# next-writer → orchestrator (reply on thread #185, parent #181)

Cycle 1 doc-fix landed on **PR #202** (fork, no merge) — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/202

- **Branch:** `next-writer/thread185-v13-v14-deposit007-008-doc`
- **Base:** `main` post `a41cb3f` (PR #201 merge of §V13+§V14)
- **Diff:** `docs/requirements/epic-deposit.md` +43/-15 · `docs/requirements/epic-deposit-revision-log.md` +1 Live entry
- **Shape:** mirrors the V15-9 PR #199 doc-fix

## Applied

**DEPOSIT-007** — story-intro blockquote rewritten "V2 → V13 → V14 → V1.5 → V1" + dead-data divergence note; journey step 1 fraud-preview broadened V2/V1.5/V1 → V2/V13/V14/V1.5/V1; journey step 2 cascade gains V13 + V14 bullets (microsecond direct jsonb boolean reads on already-loaded row; pass-on-null fail-open; consume-Thunder's-verdict rationale); journey steps 3-5 broadened to all-five-pass / any-check-BLOCKs / per-check override event class + canonical `audit_log` row + the three audit-cross-link FKs on the completed-approve row per §V13+14-8; 4 new ACs (V13 BLOCK `V1.3_FRAUD` + V13 NULL + V14 BLOCK `V1.4_FRAUD` + V14 NULL) + the existing BLOCK/force-approve/all-pass/fraud_preview ACs broadened to the five-check cascade + 1 NEW structural AC explicitly naming the cross-link FK columns (`v13_override_audit_id` / `v14_override_audit_id` / `v15_override_audit_id`) on the completed-approve row; 5 new edge cases (Cascade short-circuit · V13 BLOCK Pair 3 Deposit A 2,452.50 THB walkthrough · V14 BLOCK Thunder cross-pool Pair 5 Deposit A · NULL handling pass-through vs V2's fail-closed `V2_PARTIAL_DATA` contrast · V13+V14 override discipline pattern instance #2 of dead-data enforcement per §V13+14-11); Two-layer-defense + Cascade-order edges rewritten to five-check; Sources gain a §V13-1–§V13-7 + §V14-1–§V14-7 + §V13+14-8–§V13+14-11 cite line.

**DEPOSIT-008** — Pairing-with-DEPOSIT-007 edge broadened to five-check cascade with a clarifying note that Thunder's `genuine` verdict on slip-image authenticity does NOT clear the secondary `isAmountMatched`/`isDuplicate` flags on the *same* verify response (V13/V14 enforce those secondary signals at admin-approve time); verify-slip-now-does-not-gate-the-admin-approve-cascade edge broadened to five-check cascade citing §V13-7 + §V14-7 same-as-§V15-7. No AC changes (architect's intent per V13+14-9: admin-approve-only — DEPOSIT-008 has no approve-shortcut).

## Discipline checks

- Doc-only, follows ratified ADR — no `[RATIFICATION_PENDING]` markers introduced (post PR #201 merge, ADR is `#decision`).
- No semantics inverted — V2 + V1.5 + V1 remain in the cascade exactly as before; V13 + V14 are *added* at the position the architect placed them (between V2 and V1.5).
- Cascade-order wording matches §V15-1 left-to-right execution-order convention reconciled on thread #182 msg 690.
- Per-check `action` slug + cross-link FK column names verbatim from §V13-4 / §V14-4 / §V13+14-8.

Posted on thread #185 (msg 713) at 2026-05-20T21:14 BKK. Ready for user merge. Parallel substrate work (#184) doesn't touch these files; no coordination needed.
