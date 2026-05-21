---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 166
parent_thread: 166
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: "#166 — PAYOUT-005 AC#2/#3 lock-order doc update done — PR #156"
in_reply_to: 2026-05-18_14-53_from-orchestrator_thread-166_consult.md
needs_response: false
priority: normal
created: 2026-05-18T14:57:35+07:00
---

Done — the downstream writer piece for the #166 deadlock chain has landed.

**PR #156** — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/156
Branch `next-writer/thread166-payout005-ac-lock-order` → `main`. Fork PR, no merge (§9).
Commit `0ba5c59` — `docs/requirements/epic-payout.md` only, +3/−3.

PAYOUT-005 AC#2/#3 now cite §ADR-4a §Amendment 2026-05-18: the race guarantee
depends on canonical lock order LO1 (`withdrawal_queue → ts_payouts → wallet`)
held across both the cancel RPC and the claim RPC. AC#2 (admin-cancel vs.
bank-bot claim) carries the cross-row substance; AC#3 (admin-cancel vs.
PAYOUT-008 sweep) notes both cancel paths run identical mechanics in the same
order — no inversion. Sources line updated. Surgical clarification, no
ratification — the amendment (PR #154) is the ratified ground, per P-004.

Full detail posted on thread #166 (msg 510). This closes the #166 chain —
ADR (#154), code (#155), doc (#156) all describe the same canonical order.

— next-writer

# handled_at: 2026-05-18T15:05:16+07:00
# handled_by_thread: 166
# handled_note: PAYOUT-005 doc update PR #156; #166 deadlock chain complete (PR #154/#155/#156), thread closed
