---
from: pg-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 167
parent_thread: 167
parent_oracle: orchestrator
subject: current-system cross-check — gap review of next's epic-deposit + epic-payout (16 gaps, prioritized)
needs_response: false
priority: normal
created: 2026-05-18T16:45:00+07:00
---

# Gap review complete — epic-deposit + epic-payout

Full findings posted to thread #167 (message 517). Audited both docs at `origin/main`
HEAD (`8aa2d01`; epic-payout already carries the #166 §Amendment 2026-05-18 LO1 edit —
not flagged, per brief). Verified gaps against live mobiz code (`services/bankRotation.go`,
`controllers/DepositRequestController.go`, `controllers/PayoutRequestController.go`) and
ratified project memory.

## Headline

Both docs are well-grounded — production-verified, incident-cited, divergence-tracked.
16 gaps found; the two to escalate are both money-safety exposures in epic-payout:

- **P1#1 — Payout-side intra-bank routing never avoided.** epic-deposit handles KTB→KTB
  exclusion and even cites the *payout* incident 2026-04-11; epic-payout's fair-router
  picks a source bank with no destination-bank-code check. Confirmed: mobiz
  `SelectBankForPayout` takes no `excludeBankCode`. Also breaks PAYOUT-009's request_id
  memo signal (stripped on intra-bank transfers).
- **P1#2 — No defense against a falsely-reported bot `mark_success`.** PAYOUT-002 fully
  trusts the bot; PAYOUT-009's matcher is scoped to `review`-only and never verifies a
  bot-reported `success` against a statement. Grounded in ratified memory
  `project_bank_bot_silent_fail_pattern.md` (KTB treats non-throwing `.click()` as success).

P1 also: bank-statement dedup spec (DEPOSIT-002) likely wrong as written — "dedup by
system bank and transaction code" would collapse two genuine identical deposits; and
callback-URL SSRF validation absent from both create paths though mobiz validates both.

P2 (9 items): payout bank-routing eligibility predicate left vague (per-bank withdrawal
band + `balance >= amount`); maintenance-window exclusion missing; DEPOSIT-001 missing
`enable_deposit` check; no QR artifact / public status+image endpoints; no client-initiated
cancellation; deposit-side MDR partner-failure modes unspecified; shared/priority-ordered
withdrawal queue treated as payout-only; wrong-amount deposit recovery undescribed.

P3 (4 items): `expired_deposit_time` unset behavior; rate limiting; bank IBFT fee vs
system-bank balance; `maximum_deposit_total` cap.

Report only — no docs edited; next-writer owns them. Full per-item what/why/severity in
thread #167 msg 517.

— pg-writer, 2026-05-18 GMT+7

# handled_at: 2026-05-18T16:39:10+07:00
# handled_by_thread: 167
# handled_note: 16-gap current-system cross-check delivered; relayed to user for action decision
