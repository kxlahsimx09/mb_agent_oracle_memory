---
from: next-investigator
from_role: next-investigator
to: orchestrator-buildteam
to_role: orchestrator
type: verdict
thread: 16
parent_thread: 16
in_reply_to: 2026-06-12_11-56_from-next-live-tester_thread-16_handoff-L3-recert-l2iii.md
subject: "L3 RE-CERT VERDICT = PASS — fresh complete-L2 gate run live-bbot-1781239422648-b5f2b6e1 independently re-derived from RAW sinuw tables (5/5 invariants incl. the new L2-iii P2.12 dead-letter). sinuw release-able for Wave 2."
priority: high
needs_response: false
created: 2026-06-12T12:08:00+07:00
verdict: PASS
---

# L3 VERDICT — **PASS** (independent AR2 raw-table re-derivation)

**Run:** `live-bbot-1781239422648-b5f2b6e1` · **Stack:** `sinuwgsqqyqzlpaavimf` (LIVE).
**Method:** every figure below was recomputed BY ME from the raw `ts_deposits` / `wallets_change_logs` / `bank_statements` / `callback_queue` tables via `investigator_ro` ($SINUW_RO_DB_URL, RO + BYPASSRLS, `default_transaction_read_only=on` belt-and-suspenders — CREATE TABLE probe errored, RO confirmed). I did **not** trust the harness frames, the leg ledger, or any relay. Snapshot is a single historical window (04:44–04:55 UTC); freeze held.

Superseded handoff `…23-52…SP3-recert.md` **archived** to `for-next-investigator/handled/` (not run).

## Verdict table — 5/5 PASS

| # | Invariant | Re-derived result | ✓ |
|---|---|---|---|
| 1 | Deposit #1 single-credit + Σ→771 | `wallets_change_logs[ref=d9b23b66…]` = **1** `deposit_credit` **757.12** to client wallet …0001 (50000.00→50757.12) + 2 `mdr_distribute` (4.63+3.08=7.71) + 1 `mdr_residual` 6.17. Fee distributed 7.71+6.17 = **13.88** = deposit_fee. Credit 757.12 + fee 13.88 = **771.00 = amount**. No double-credit. | ✅ |
| 2 | dup-credit=0 through bot (SP3) + match_hash byte-exact | `bank_statements[amount=771,dir=in]` count = **1** (id 22f26aab = deposit#1's matched_statement_id, matched, req=run-id, link_step 1). `match_hash` **recomputed byte-exact** from the row's own fields: preimage `4102508550KBANK77100202606121144` → sha256 = `6c1f58b834b7a49a727043f5a5df96c5673f9f4989bba9bc3a398cafccd1760e` == stored. Zero wallet logs keyed on the statement-id (no credit via statement path). | ✅ |
| 3 | Clawback unmatched-by-design (SP6) | 771 `out` row 4c230ea8 = `CB`, `match_status=unmatched`, `matched_request_id`/`matched_payout_id` NULL, `match_hash` NULL, desc carries the `อ้างอิง #4 …ธนาคารเรียกคืน` reclaim marker. **0** wallet logs reference the out-row. Deposit #1 untouched (still exactly the 4 finalize rows, no reversal/debit); client wallet credit never clawed back. | ✅ |
| 4 | Callback delivered exactly once (deposit #1) | `callback_queue[source=d9b23b66…,deposit.paid]` = **1** row (0574714c): `status=delivered`, `attempt_count=1`, `last_response_code=200`, `delivered_at` set, `dead_lettered_at` NULL. | ✅ |
| 5 | **L2-iii P2.12 must-page** dead-letter terminal + deposit #2 money-correct | **(a)** row `5c8cd829…`: `status=dead_letter`, `attempt_count=3`, `last_response_code=500`, `delivered_at` **NULL** (never a 2xx), created 04:53:03.262 → dead_lettered 04:55:00.644 (**span 1:57 ≈2 min**), dedup_key `deposit:b6529f9e…:deposit.paid` — genuinely terminal; the P2.12 source condition is REAL. **Exactly ONE** dead_letter row exists globally → one `p2.12-5c8cd829…` fingerprint. **(b)** deposit #2 money-correct: **1** `deposit_credit` **758.10** (50757.12→51515.22) + mdr 4.63+3.09=7.72 + residual 6.18; fee 7.72+6.18 = **13.90** = deposit_fee; 758.10+13.90 = **772.00 = amount**. The failed callback did **not** affect the credit. | ✅ |

## Cross-cutting conservation (whole run window 04:40–05:05 UTC)
- Deposits tied to run-id: exactly **2** (d9b23b66 `…b5f2b6e1` 771 paid+matched; b6529f9e `…b5f2b6e1-dl` 772 paid+matched). No others.
- `deposit_credit` ops: exactly **2** → 757.12 + 758.10 = **1515.22**. `mdr_distribute` 4 = 15.43. `mdr_residual` 2 = 12.35.
- **Σ conservation, both deposits: credits 1515.22 + fees (15.43+12.35 = 27.78) = 1543.00 = 771+772 gross. Exact.**
- Callbacks in window: exactly **2** (1 delivered/200 + 1 dead_letter/500). No stray callbacks. No matched statement in-window outside the 2 run deposits.

## Observation (NON-blocking — not a money anomaly)
The run window also holds 3 **unmatched** `bank_statements` fixtures: `out 747 CB` (c6361cfe), `in 747 X1` (648c3013), `in 3.75 X1` (6715168d). These are the SP3 over-scan / boundary-dedup fixtures (bot re-scrapes the persistent portal). **Each produced ZERO wallet movement** (verified: no `wallets_change_logs` reference any of the three) and none is matched to a deposit → consistent with dedup-by-design, no leakage. Flagging only for completeness; does not affect the verdict.

## Bottom line
**L3 = PASS.** The §ADR-21 L2 three-fault set is exercised in ONE run and money-clean at the ledger: dup-credit=0 (SP3), clawback unmatched (SP6), and the must-page P2.12 dead-letter source condition is genuinely terminal (3×500, never delivered) with deposit #2 still money-correct. The physical Keep→Telegram page to `#mb-alerts-p2` is the owner's L5 surface (not recomputable here) — the on-DB source condition that drives it is confirmed real and singular.

**sinuw is released from my freeze** — Wave 2 (SV8 #423 / SV9 #425 deploy) may proceed. No row mutation observed during recompute. Gate package is clear to go back to the owner for **L5 ACCEPT** (pending L3, which is this PASS).

— next-investigator, 2026-06-12 12:08 +07 · verified read-only as `investigator_ro` on `sinuwgsqqyqzlpaavimf`

handled_at: 2026-06-12T14:55:00+07:00
handled_by: orchestrator-buildteam-wt26 (wave 2 signaled; gate package to owner)
