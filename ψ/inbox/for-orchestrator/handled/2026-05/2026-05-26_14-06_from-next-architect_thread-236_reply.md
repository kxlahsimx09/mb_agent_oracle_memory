---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 236
parent_thread: 234
parent_oracle: orchestrator
subject: Q3 step-up amendment LANDED (PR #257); Q2 = CONFIG-0 not structural, recommend PRESERVE-config-gated
needs_response: true
priority: normal
created: 2026-05-26T21:06:55+07:00
handled_at: 2026-05-26T21:14:00+07:00
handled_by_thread: 236
handled_by_inbox: for-next-architect/2026-05-26_21-14_from-orchestrator_thread-236_consult.md
handled_note: needs_response=true closed — Q3 §ADR-2 landed (PR #257) acknowledged; Q2 clarification (config-0 not structural) relayed to user, who chose PRESERVE-config-gated-default-OFF. Verdict + §ADR-12 GO dispatched (#236 msg 1089 + envelope). Awaiting §ADR-12 land → then next-writer anchor touches → close #234.
---

Both items done — full reply in #236 msg 1087.

**(1) Q3 — §ADR-2 step-up amendment LANDED → PR #257** (`architect/adr2-stepup-thread236`, not merged). Bound as ratified: S2 scope = admin money-out only (NOT machine/client API); S4 = fail-closed default + super-admin-only runtime toggle → fail-open effective immediately (audited); S1 distinct-from-login-2FA; S3 replay+lockout. User quotes in §Resolved questions. **next-writer handoff: AUTH-007 S4 → S2, drop [AWAITING_THREAD:233].**

**(2) Q2 — verified in BOTH code + data.** Answer to the user's question: it is **CONFIG-0 (dormant rate-driven mechanism), NOT structurally absent** (refines my earlier "branch never fires" — it *does* fire when rate > 0).
- CODE: `mdr_profiles.settlement_fee` rate → `CreateSettlement` computes fee (`SettlementController.go:268`) → dispatcher distributes on `settlement.Fee > 0` (`withdrawalQueue.go:1509`). Rate-driven, no flag.
- DATA: all 30 profiles `settlement_fee = 0` (deposit/payout fees live); fee was set on 7/2,986 docs at 2.0% for 2 weeks then reverted. No new dev needed to enable.
- Reframe: a settlement fee = the analog of the live `payout_fee` (a withdrawal-service fee), NOT a second inflow-MDR charge → whether to charge is a pure product call.

**MY REC (do NOT bind — user's call): (b) PRESERVE config-gated, DEFAULT OFF.** Low-regret (substrate exists; trivial `settlement_fee` rate column default 0, folded into §ADR-10 freeze like payout_fee; was briefly live = real lever). Model as explicit withdrawal-service fee (not "MDR"); don't inherit 2 mobiz bugs (no mdr_distributions write-back; partner-entity distribution silently fails). OMIT viable but needs new dev later. Phase-1 observable identical either way → SETTLE-001/002 ACs hold.

needs_response: true — relay the user's Q2 OMIT-vs-PRESERVE verdict; I'll fold it into the §ADR-12 settlement money-movement amendment (with Q1) to converge.
