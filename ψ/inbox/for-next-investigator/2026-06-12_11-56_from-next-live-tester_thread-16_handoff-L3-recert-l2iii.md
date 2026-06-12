---
from: next-live-tester
from_role: next-live-tester
to: next-investigator
to_role: next-investigator
type: handoff
thread: 16
parent_thread: 16
parent_oracle: orchestrator-buildteam
supersedes: 2026-06-11_23-52_from-next-live-tester_thread-13_handoff-SP3-recert.md
subject: "L3 RE-CERT handoff — fresh clean gate run live-bbot-1781239422648-b5f2b6e1 (complete L2, NOW incl. L2-iii P2.12 must-page dead-letter). SUPERSEDES the stale SP3-recert handoff. sinuw frozen for your recompute."
priority: high
needs_response: true
created: 2026-06-12T11:56:00+07:00
---

# L3 re-cert — the complete-L2 gate run (incl. the new must-page leg)

**⚠️ This SUPERSEDES `2026-06-11_23-52_from-next-live-tester_thread-13_handoff-SP3-recert.md`** in your inbox — that one is stale (pre-L2-iii, pre-GW4-fix). Recompute against THIS run only.

**X-Request-Id (correlation key):** `live-bbot-1781239422648-b5f2b6e1`
**Stack:** `sinuwgsqqyqzlpaavimf` (LIVE). Orchestrator has **frozen the sinuw surface** for your recompute (Wave 2 SV8/SV9 held until you're done) — read now via `investigator_ro` ($SINUW_RO_DB_URL).
**Run mode:** M1-SIM, portal=remote `https://18-136-227-108.sslip.io`, bot=remote Fargate. AR6 PASS template (#419 merged). Harness RAN; verdict is yours (AR2 raw-table recompute), not my flags.

## Leg ledger (this run) — NO RED, NO BLOCKED
| Leg | Status |
|---|---|
| L0 readiness | GREEN |
| L1a bot witness | GREEN |
| **L1b client wire** | **GREEN (real wire — GW4 fix #409 cleared the #404 RED)** |
| L1c scrape+push | GREEN (match_hash present) |
| L1d auto-match | GREEN (paid + credited + callback) |
| L1e cursor | GREEN |
| L2b clawback (SP6) | GREEN |
| L2a-steady dedup | AMBER (count held =1; explicit skip-line not captured this tick — corroboration leg) |
| **L2a-dup-fault (SP3)** | **GREEN** (R survived bot-only restart; "0 inserted, 1 skipped"; dup-credit=0) |
| **L2c dead-letter (L2-iii)** | **AMBER-by-design** (P2.12 condition MET + fingerprint; no KEEP_ALERTS_API lever → physical page is the owner L5 surface) |
| L3 rotate | SKIPPED (remote opt-in) |

## Correlation keys for your recompute

- **Deposit #1 (golden auto-match):** `d9b23b66-7979-4448-9f2b-cbd28ba35780` — amount **771**, fee 13.88, final 757.12, client `2222…0001`, SCB acct `7777…0001`, request_id = the run id.
- **Deposit #2 (L2-iii inductor — a REAL paid deposit whose CALLBACK was driven to dead-letter):** `b6529f9e-086b-4f7f-b7a7-138c458935dc` — amount **772**, request_id `live-bbot-1781239422648-b5f2b6e1-dl`, status paid.
- **P2.12 dead-letter `callback_queue` row:** `5c8cd829-2b14-47a1-b78d-323bd8017a13` — `source_id=b6529f9e…`, event `deposit.paid`, `status=dead_letter`, `attempt_count=3`, `last_response_code=500`, `delivered_at=NULL`, `dead_lettered_at=2026-06-12T04:55:00Z` (created 04:53:03 → ≈2 min exhaustion), `dedup_key=deposit:b6529f9e…:deposit.paid`. Fingerprint `p2.12-5c8cd829-2b14-47a1-b78d-323bd8017a13`.

## Invariants to recompute (the prior 4 + the new 5th)

1. **Exactly one credit, no double-credit (deposit #1):** `wallets_change_logs` for `reference_id=d9b23b66…` = the single-finalize set (1 `deposit_credit` to client + N `mdr_distribute` + 1 `mdr_residual`); credit = final_amount 757.12; Σ conserved to 771.
2. **dup-credit=0 through the bot (SP3):** `bank_statements WHERE amount=771 AND direction=in` count stays **1** (one matched to the run); exactly one credit; `match_hash` recomputes byte-exact for the 771 in-row.
3. **Clawback unmatched-by-design (SP6):** the 771 out-row `match_status != matched`, `matched_request_id NULL`, อ้างอิง marker present; zero `wallets_change_logs` reference the out-row; deposit #1 untouched.
4. **Callback delivered exactly once (deposit #1):** `callback_queue` for `d9b23b66…` `deposit.paid` `status=delivered`, one delivery.
5. **NEW — L2-iii P2.12 must-page (deposit #2):** confirm (a) the dead-letter row `5c8cd829…` is genuinely terminal `dead_letter` (3 attempts, last 500, never a 2xx, `delivered_at` NULL) — the P2.12 source condition; **and** (b) deposit #2 is itself **money-correct** — exactly **one** `deposit_credit` for `b6529f9e…` (a failed *callback* must not affect the *credit*); Σ conserved to 772. (The physical Keep→Telegram page to `#mb-alerts-p2` is the owner's L5 confirmation — not yours to recompute; the *source condition* is.)

## Evidence (text trail, append-only; 24 frames)
`poc/integration/evidence/live/bbot/live-bbot-1781239422648-b5f2b6e1/` — `manifest.json`, per-beat `*.json` (incl. `024_l2c-p2-12-callback-dead-letter…json`), `legs.json`, `log_*.txt`. Binaries (png/video/trace) git-ignored. I'll also commit the text trail to `campaign/livegate`.

Reply with your L3 verdict (PASS/FAIL) → the gate package goes back to orchestrator for the owner **L5 ACCEPT**. Flag immediately if any row is mutated (the freeze should hold until you're done).

— next-live-tester, 2026-06-12 11:56 +07
