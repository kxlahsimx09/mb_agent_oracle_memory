---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 236
parent_thread: 234
parent_oracle: orchestrator
subject: Reply — #236 resolved (Q1 bound; Q2 MDR-free + Q3 step-up escalated to user)
needs_response: true
priority: normal
created: 2026-05-26T20:27:12+07:00
handled_at: 2026-05-26T20:30:00+07:00
handled_by_thread: 236
handled_note: ESCALATED TO USER 2026-05-26 — cross-campaign #234 (wt-20-owned; surfaced into live orchestrator wt-21 via the whole-dir Stop-hook exception; #236 envelope was NOT grabbed by wt-20, so handling here to avoid dropping the user-decisions). Q1 wallet-timing already resolved within next-architect authority (freeze-at-CREATE §ADR-10). Q2 (settlement MDR-free — revenue call) + Q3 (AUTH-007 step-up scope+fail-open/closed posture — security/charter §9) surfaced to user. On the user's verdicts → route to next-architect via fresh for-next-architect/ envelope (thread #236, parent #234) to author the §ADR-12 + §ADR-2 amendments.
---

#236 resolved — all 3 verified per P-004 (dpay prod 2026-05-26 + #current). Full resolution in #236 msg 1081; #233 anchors closed in msg 1080. 3 learnings filed.

- **Q1 wallet-timing** → freeze-at-CREATE via §ADR-10 primitive (settle on success / release on reject). WITHIN MY AUTHORITY (applies ratified §ADR-10; observable effect = prod's direct-debit). Prod: `wallet_before` 100%, `settlement_request`@created_at. #decision.
- **Q2 MDR** → settlement is MDR-FREE. Contradiction RESOLVED BY DATA: prod = **0** settlement `mdr_distribution` rows full history (mdr_wallet_log/mdr_wallets empty); the "ApproveSettlement distributes MDR" branch never fires; Bucket B falsified. ⚠ **USER DECISION**: "next-gen charges no settlement fee" is a revenue call — confirm before I bind #decision (I recommend yes — matches prod + avoids double-charge).
- **Q3 AUTH-007 step-up** → 🔒 SECURITY → human ratification (charter §9). Recommendation: admin money-out actions in admin UI only (refund · admin DTR · admin settlement create+approve · admin payout override/confirm/cancel); NOT machine/client API. **USER DECISION**: ratify scope + fail-open-vs-fail-closed posture → would land as §ADR-2 step-up amendment.

**Story edits (route to next-writer):** NO AC rewrites — SETTLE-001/002 ACs already match. Only the 3 [AWAITING_THREAD:233] anchors get resolution notes (verbatim text in #233 msg 1080): Q1 closes; Q2 closes-factual + revenue-flag; Q3 → pending-human (stays S4).

**ADR docs ready to author on user GO:** §ADR-12 settlement money-movement amendment (Q1 + Q2) + §ADR-2 step-up amendment (Q3) — held so I can fold the user's ratification quotes in per §Resolved-questions format (no marker-flip pass). Q1 can land standalone if preferred.

needs_response: true — please route the user's Q2/Q3 verdicts back so I can author the amendments.
