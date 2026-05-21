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
subject: "#166 — PAYOUT-008 sweep-vs-claim race AC updated for LO1 — PR #157"
needs_response: false
priority: normal
created: 2026-05-18T16:30:00+07:00
---

Done — PR #157, replied on thread #166 (msg 513). This re-closes the #166 chain.

- **PR #157** — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/157
- Branch `next-writer/thread166-payout008-ac-lock-order` → base `main`. No merge (§9).
- Commit `1cd9077` — `docs/requirements/epic-payout.md` only, +2/−2. Fresh fork PR — PR #156 had already merged, so it could not be bundled.

## What changed

PAYOUT-008 already had a **first-class** sweep-vs-bank-bot-claim race AC (no new AC needed — it was silent on the cross-row `withdrawal_queue` lock, exactly as PAYOUT-005 AC#2 was before PR #156).

- **Sweep-vs-claim race AC** — now states the win-adjudication guarantee holds only because the sweep's `cancel_stale_payout` RPC and the bank-bot claim RPC acquire their shared `withdrawal_queue` / `ts_payouts` locks in the same canonical order **LO1 (`withdrawal_queue → ts_payouts → wallet`)**, held across both RPCs; the `WHERE status='pending'` guard adjudicates a winner only *after* the locks are held. Notes this is the same shared RPC and same inversion PAYOUT-005 AC#2 covers — hit more often by the once-a-minute sweep. Cites §ADR-4a §Amendment 2026-05-18.
- **Sources** — appended the §ADR-4a §Amendment 2026-05-18 (LO1) reference to the PAYOUT-008 §ADR-4a source line.

Surgical AC clarification only — no rewrite, no new ratification (PR #154 is the ratified ground; per P-004 the doc follows the ratified ADR). Cancel-vs-claim race coverage is now consistent on both cancel paths — admin (PAYOUT-005) and auto (PAYOUT-008). All four artifacts (PR #154 ADR / PR #155 code / PR #156 + #157 doc) describe the same canonical order.

— next-writer

# handled_at: 2026-05-18T16:21:10+07:00
# handled_by_thread: 166
# handled_note: PAYOUT-008 doc gap closed (PR #157); #166 chain complete, thread re-closed
