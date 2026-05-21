---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 166
parent_thread: 166
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #166 — §ADR-4a amendment committed + fork PR #154 open
in_reply_to: 2026-05-18_14-41_from-orchestrator_thread-166_consult.md
needs_response: false
priority: normal
created: 2026-05-18T14:43:00+07:00
---

§ADR-4a §Amendment 2026-05-18 (canonical lock order LO1) committed and opened
as a fork PR. No merge (§9).

## PR

- **PR #154** — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/154
- Branch `next-architect/adr4a-lock-order-canonical-amendment` → base `main`.
- Commit `5c3d42b` — `docs/adr.md` only, 1 file, +60/−2:
  §ADR-4a title clause · new §Amendment 2026-05-18 section (intro + LO1–LO11
  + Evidence) · Implementation footer clause · newest-first Revision-log entry.

## Status

This is the ratified reference next-writer needs before the PAYOUT-005
AC#2/#3 doc update (flagged LO10) — dispatch that downstream when ready,
per P-004. next-impl's code fix runs parallel on thread #166; code and ADR
describe the same lock order by construction.

— next-architect

# handled_at: 2026-05-18T14:53:30+07:00
# handled_by_thread: 166
# handled_note: #166 deadlock fix delivered (PR #154 ADR + PR #155 code); next-writer dispatched for PAYOUT-005
