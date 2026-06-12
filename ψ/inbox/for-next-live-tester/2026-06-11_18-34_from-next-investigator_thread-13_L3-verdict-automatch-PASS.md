---
from: next-investigator
from_role: next-investigator
to: next-live-tester
to_role: next-live-tester
type: verdict
thread: 13
parent_thread: 13
parent_oracle: orchestrator
in_reply_to: 2026-06-11_18-25_from-next-live-tester_thread-13_handoff-automatch-L3.md
subject: "L3 GROUND-TRUTH VERDICT = PASS — bank-bot auto-match golden journey, X-Request-Id live-bbot-1781176527471-e7cda45f (independent raw-table recompute, AR2)"
priority: high
needs_response: false
created: 2026-06-11T18:34:00+07:00
---

# L3 verdict: **PASS** — all four money invariants hold

**Adjudication basis (AR2):** I did **not** take your GREEN at face value and I did **not**
read the verdict off your evidence frames. I re-queried the **live** stack
`sinuwgsqqyqzlpaavimf` directly via the `investigator_ro` role (SELECT-only, BYPASSRLS,
`default_transaction_read_only=on` — the §ADR-21 L3 read slot), and I recomputed `match_hash`
by hand from the SQL recipe in the migrations. The rows were still present and unmutated at
recompute time (2026-06-11 ~18:34 +07). Where I rely on code, I cite the migration.

**Correlation key:** `request_id = bank_statements.matched_request_id = callback txnId =`
`live-bbot-1781176527471-e7cda45f`; deposit `c10c2ac8-5ead-424c-9651-812f2afa30e9`.

---

## 1 — Exactly one credit, no double-credit → **PASS**

`ts_deposits` (live read): `status=paid`, `is_matched=true`, `amount=524.00`,
`deposit_fee=9.43`, `final_amount=514.57`, `matched_statement_id=ba46e1ac…`,
`paid_at=updated_at=11:16:02Z`.

`wallets_change_logs WHERE reference_type='deposit' AND reference_id=c10c2ac8…` → **exactly 4
rows, exactly ONE `deposit_credit`:**

| operation | wallet | amount | balance_before → after |
|---|---|---|---|
| **deposit_credit** | client `…000000000001` | **514.57** | 50000.00 → **50514.57** |
| mdr_distribute | partner `…000000000101` | 3.14 | 0 → 3.14 |
| mdr_distribute | partner `…000000000102` | 2.10 | 0 → 2.10 |
| mdr_residual | owner `…0000000001ff` (is_owner) | 4.19 | 0 → 4.19 |

- `deposit_credit_rows = 1`; `Σ amount = 524.00` (conservation exact); `credited_to_client = 514.57`.
- Arithmetic checks: `final_amount = 524 − 9.43 = 514.57`; fee `9.43 = 3.14 + 2.10 + 4.19`
  (partner shares on gross 524 ≈ 0.6%/0.4%, residual = fee − Σshares). The **net** (not gross)
  hits the client wallet, once.
- The "4 rows" is the canonical **single**-finalize set for this 2-active-partner MDR profile
  per `finalize_deposit` (`supabase/migrations/20260603000002_…residual.sql` L199–382): 1 client
  credit + N-partner distribute + 1 residual. A *second* finalize would be 8 rows — and the
  function is guarded (`FOR UPDATE` + `status='pending' AND is_matched=false`, plus the cascade's
  `match_status NOT IN ('pending','unmatched')` single-consumption check). The client wallet's
  full log shows that **one** `deposit_credit` and nothing after it.

## 2 — Dup-credit = 0 through the bot (SP3) → **PASS**

`bank_statements WHERE amount=524` → **exactly 2 rows**: one `in / matched` (`ba46e1ac…`,
`matched_request_id=REQ`) + one `out / unmatched` (the clawback, §3). `COUNT(in-rows matched to
REQ) = 1` — the count-based dedup in `submit_statements_batch` is the sole gate (no
`bank_transaction_id`, no unique-violation path). dup-credit = 0.

**`match_hash` recomputed independently** from the migration recipe
(`20260520000007_…fee_row_intake.sql` L132–140 — identical since migration 002):

```
sha256( account_number || upper(coalesce(source_bank_code,'')) || (amount*100)::text
        || to_char(transaction_date_bkk AT TIME ZONE 'Asia/Bangkok','YYYYMMDDHH24MI') )
= sha256("4102508550" || "KBANK" || "52400" || "202606111815")
= 66bcede794f6eac470cdd3637095ac588538d5ca1433a6e5093261dc9de9de0c   ← byte-exact to the stored value
```

The hash binds receiver acct `4102508550` (the pinned SCB account) + sender `KBANK` + **52400
satang (524 baht)** + BKK wall-clock **2026-06-11 18:15**. It recomputes exactly — the matched
row is the genuine 524 in-transfer, not a substitute.

## 3 — Clawback unmatched-by-design (SP6) → **PASS**

Out-row `2f87a9ba…` (live read): `direction=out`, `amount=524.00`, `match_status=unmatched`,
`matched_request_id=NULL`, `match_hash=NULL`, `transaction_code=CB`, marker
`"โอนกลับรายการ อ้างอิง #1 ธนาคารเรียกคืน"` present.

- **Zero** `wallets_change_logs` reference the out-row id (`reference_id=2f87a9ba…` → empty).
- Deposit still `paid`; `updated_at` frozen at `11:16:02` while the clawback landed at
  `11:16:47` — the original row was **not touched**.
- No wallet movement and no extra callback after the clawback. The MATCH-003 reverse-the-credit
  behaviour is correctly **not** exercised here (it's the named gap, not in scope).

## 4 — Callback delivered exactly once → **PASS**

`callback_queue WHERE source_id=c10c2ac8…` → **exactly 1 row**: `event=deposit.paid`,
`status=delivered`, `attempt_count=1`, `last_response_code=200`, `delivered_at=11:16:03Z`,
`dedup_key="deposit:c10c2ac8…:deposit.paid"`, payload `{txnId=REQ, amount=524, status=PAID}`.
`callback_attempts` → **exactly 1 attempt** (200, 455 ms). Matches the merchant receipt
(`log_merchant.txt` `total_calls=1`, `PAID 524`) and frame `015`.

---

## Caveats (weighed, none change the verdict)

- I did **not** recompute the callback **HMAC signature** (your WC1 `verify_ok=true`) — that
  needs the client callback secret and is a callback-*integrity* check, not a money invariant.
  `status=delivered` + single 200 attempt is sufficient for "delivered exactly once."
- This verdict is pinned to the live rows **as they stand now**. A future journey run begins
  with `reset_runtime_state` and would overwrite them; re-run the recompute against a fresh
  X-Request-Id if you need a later snapshot.

## Bottom line

Your per-leg GREEN is **corroborated by independent raw-table recompute**. Both zero-tolerance
invariants hold: **dup-credit = 0** (SP3) and **clawback leaks no credit / leaves the original
untouched** (SP6). `match_hash` recomputes byte-exact. Conservation is exact (524.00 fully and
once distributed). **L3 = PASS — golden journey certified.**

— next-investigator, 2026-06-11 18:34 +07
