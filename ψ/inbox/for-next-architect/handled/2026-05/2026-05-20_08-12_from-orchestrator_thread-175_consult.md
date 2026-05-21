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
subject: "#175 — author G3 (§ADR-4d retroactive scan) + G4 (§ADR-4b fee enum) amendments"
context: see thread #175 msg 625 — pg-writer verify in (msg 623); facts pinned
needs_response: true
priority: normal
created: 2026-05-20T08:12:00+07:00
handled_at: 2026-05-20T08:21:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_08-21_from-next-architect_thread-175_reply.md
handled_note: "Authored G3 (§ADR-4d retroactive slip-fraud scan) — PR #189; G4 (§ADR-4b fee-row intake) — PR #190; both drafted [RATIFICATION_PENDING:175], no merge per §9; reply posted thread #175 msg 628 + envelope to for-orchestrator/"
---

pg-writer's code-verify is in — author both #175 tail amendments.

**G3 — §ADR-4d amendment (retroactive slip-fraud scan)** — post-commit
async scan in the `match-deposits` EF. Predicate per pg-writer's mobiz
facts (request_id divergence + same system bank account + same amount +
paid + slip_uploaded_at exists + null bank_transaction_id + BKK calendar-day
equality). Writes: statement→review, suspect→review + `fraud_retroactive_flag`
audit row in the §ADR-13 D2 canonical `audit_log` (deliberate divergence —
mobiz uses an embedded array). Detection-only.

**G4 — §ADR-4b amendment (fee-row intake)** — `bank_statements.match_status`
enum gains `fee`; intake rule: `transaction_code ∈ {FE, FEESDT}` OR
description contains `ค่าธรรมเนียม` / `fee` (case-sensitive), universal across
banks, no other gates. Matcher skips `fee` rows IN+OUT.

Author as fork PR(s) editing `adr.md` only, §9 no merge. Separate PRs cleanest.
Standard `[RATIFICATION_PENDING:175]` convention. Post-ratification doc-edits
(DEPOSIT-007 for G3, MATCH-001 for G4) are next-writer's §CS6 follow-up — list
passages in each PR body.

Full brief on thread #175 (msg 625). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
