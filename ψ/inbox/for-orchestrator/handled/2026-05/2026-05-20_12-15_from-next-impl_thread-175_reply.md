---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
in_reply_to: 2026-05-20_11-36_from-orchestrator_thread-175_consult.md
subject: "#175 — G4 §FC8 + G-6 §VF6 substrate landed (PR #195 + PR #196, hosted-verified)"
context: thread #175 msg 656 — substrate ports for the ratified FC1–FC5 + VF1
needs_response: false
priority: normal
created: 2026-05-20T12:15:00+07:00
handled_at: 2026-05-20T12:20:00+07:00
handled_by_thread: 175
handled_by_inbox: for-orchestrator
handled_note: "Informational substrate-landing (needs_response=false). next-impl shipped PR #195 (G4 fee-row intake, hosted 177/177) and PR #196 (G-6 D4 verdict-only-flip, hosted 174/174); both branched fresh off main@9ff8f8a, §9 honoured. Surfaced to user with full thread #175 board: 6 PRs awaiting merge (#190/#193/#195 G4 trio + #191/#194/#196 G-6 trio) + G3/#189 decision. Flagged suggested merge order (architecture → doc-fix → substrate) as hygiene-not-blocking."
---

Both substrate ports landed as **separate fork PRs** per §9; both
hosted-verified against `spdazjbmyagekwxixfct` on top of `main` HEAD
`9ff8f8a`. No unratified config encountered — both predicates are faithful
ports of the ratified amendment text.

**G4 — §FC8 fee-row intake (PR #195, hosted 177/177 PASS)**
- Migration `20260520000007_adr4b_fee_row_intake.sql`.
- FC1 — `match_status` CHECK enum gains `'fee'`.
- FC2 — `submit_statements_batch` classifies `transaction_code ∈ {'FE','FEESDT'}` OR `description` contains `'ค่าธรรมเนียม'` / `'fee'`; code-first then description-gated; case-sensitive; universal across banks. Port-verbatim from mobiz `:718-727`.
- FC3 — `match_deposits_cascade` (IN) + `match_payout_statement` (OUT) gain explicit `fee_row_skipped` early-returns. Sweeps unchanged (`match_status IN ('pending','unmatched')` already excludes `fee`).
- Probe `fee-row-intake.ts` — 6 named assertions; baseline 171 + 6 = 177.

**G-6 — §VF6 D4 verdict-only-flip (PR #196, hosted 174/174 PASS)**
- Migration `20260520000008_adr4d_d4_verdict_only_flip.sql`.
- VF1 — `record_slip_verify_attempt` flip narrowed to `p_verdict IN ('genuine','forged')`. D9 append-only preserved (every attempt INSERTs + bumps denorm); only the status flip is gated.
- VF2 — `admin_verify_slip_now` (PR #183 / migration `20260519000010`) delegates the flip to the shared D9 body — gate moves with it; no separate change.
- `deposits-upload-slip` EF unaffected (hardcodes `verdict='genuine'`).
- Probe `deposit-verify-slip-now.ts` extended with the 4-outcome matrix (forged → flip, thunder_system_error → no flip, thunder_timeout → no flip — genuine→flip already covered by the existing happy-path); baseline 171 + 3 = 174.

**Discipline:** both PRs branched from `origin/main@9ff8f8a`; neither stacks on the other; §9 honoured (no merge from this session). Both migrations are currently applied on hosted (smoke covers the combined state per-branch). No unratified config touched.

**PRs:**
- https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/195
- https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/196

**Thread reply:** posted on #175 msg 656 (parent_session / parent_thread stamped — routes back to your session).

Awaiting orchestrator/user disposition.
