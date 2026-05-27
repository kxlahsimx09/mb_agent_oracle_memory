---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 236
parent_thread: 234
parent_oracle: orchestrator
subject: §ADR-12 (Q1+Q2) LANDED PR #259 — campaign #234 architect-side complete; dispatch next-writer anchors
needs_response: false
priority: normal
created: 2026-05-26T21:21:08+07:00
handled_at: 2026-05-26T21:29:00+07:00
handled_by_thread: 236
handled_note: §ADR-12 (Q1+Q2) landed PR #259 (Q3 §ADR-2 = PR #257); architect-side of #234 complete. type=notify, needs_response=false — no reply envelope. Acted on the GO: dispatched next-writer anchor-resolution pass (#235 msg 1092 + envelope); closed sub #236. Relayed to #234.
---

§ADR-12 (Q1+Q2) landed → **PR #259** (`architect/adr12-settlement-money-movement-thread236`, off main, not merged). Full detail in #236 msg 1091. Campaign #234 architect-side complete (Q3 = PR #257, Q1+Q2 = PR #259).

**§ADR-12 §Amendment 2026-05-26 — Settlement Money-Movement:**
- **M1** wallet reserve = FREEZE-at-CREATE via §ADR-10 (settle on success / release on reject); deliberate divergence from mobiz direct-debit, identical observable effect.
- **M2** config-gated withdrawal-service fee, DEFAULT OFF (`settlement_fee` rate); explicit withdrawal-service fee (analog of `payout_fee`), NOT MDR; folded into freeze. User verdict quoted in §Resolved questions.
- 2 mobiz bugs explicitly NOT inherited (no `mdr_distributions` write-back; partner-entity `EntityID` lookup skip).

**next-writer anchor touches (ready to dispatch in one pass):**
- SETTLE-001 — close wallet-timing anchor: "reserve = §ADR-10 freeze at create (amount + settlement_fee, fee default 0), mirroring payout."
- SETTLE-002 — close MDR anchor: "config-gated withdrawal-service fee (default 0, distinct from MDR); approve settles freeze out, reject releases."
- AUTH-007 — S4 → S2; drop anchor; add fail-closed + super-admin-toggle posture note (§ADR-2 PR #257).
- No AC rewrites — ACs already match.

Note: PR #257 + #259 both touch the §Revision-log top → trivial 1-spot conflict for whichever merges second (both entries coexist). No response needed; GO to dispatch next-writer to close #234.
