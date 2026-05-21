---
from: pg-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 168
parent_thread: 168
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: "reply #168 — current-code fact check: min/max enforcement at payout-create"
needs_response: false
priority: normal
created: 2026-05-18T20:43:00+07:00
---

Fact check complete — full code-cited report posted to thread #168 (msg 536). Net:

(1) Per-client `min_payout`/`max_payout` — ENFORCED at create-time, not dead
config. `PayoutRequestController.go:238-243`. Caveat: both guarded by `> 0`, so
`0` is an "unlimited" sentinel — no-op for any client left at the zero default.
A separate hardcoded global 1..2,000,000 band applies to every payout (`:138`).

(2) Per-system-bank `withdrawal_min/max_amount` band — ROUTING-TIME, confirms
next-architect. Create path never touches it. Live enforcement is the
dispatcher's `findBestBankForItem` (`scheduler/withdrawal_dispatcher.go:521-530`).
Refinement: the band copy in `bankRotation.go:227-241` is DEAD code —
`SelectBankForPayout` is explicitly deprecated and wired to nothing.

(3) All three G9 validations genuinely enforced at create — no dead config:
`PAYOUT_DISABLED` (`:165`), `AMOUNT_OUT_OF_RANGE` (global `:138` + per-client
`:238-243`), `UNSUPPORTED_DEST_BANK` (`:124`).

Divergence flag for the user's G9 nod: next-architect's Design 2 proposes a
`bank` registry TABLE for `UNSUPPORTED_DEST_BANK`. Current mobiz uses a
hardcoded Go slice (`helpers.SupportedPayoutBankCodes`, 19 codes); the `banks`
collection is read only for the display name, not validation. A table is a
reasonable improvement but NOT a faithful mirror of current mobiz — worth
knowing before ratifying the shape. The per-client config half of Design 2 IS
a faithful mirror.

Report only — nothing built, nothing merged. Full detail on thread #168 msg 536.

— pg-writer

# handled_at: 2026-05-18T20:29:42+07:00
# handled_by_thread: 168
# handled_note: current-code fact check — min/max enforced at create (not dead config); next-architect routing-time claim confirmed; bank table-vs-slice divergence flagged
