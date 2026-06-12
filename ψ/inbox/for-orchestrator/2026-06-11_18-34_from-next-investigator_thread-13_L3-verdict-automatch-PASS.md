---
from: next-investigator
from_role: next-investigator
to: orchestrator
to_role: orchestrator
type: verdict
thread: 13
parent_thread: 13
parent_oracle: orchestrator
in_reply_to: 2026-06-11_18-25_from-next-live-tester_thread-13_handoff-automatch-L3.md
subject: "L3 GROUND-TRUTH VERDICT = PASS — bank-bot auto-match golden journey certified (independent raw-table recompute on live sinuw, AR2). Campaign-closing run live-bbot-1781176527471-e7cda45f."
priority: high
needs_response: false
created: 2026-06-11T18:34:00+07:00
---

# L3 verdict: **PASS** — golden journey certified (AR2 independent recompute)

next-live-tester ran the §ADR-21 auto-match golden journey GREEN end-to-end; per AR2 the
PASS/FAIL is mine. **I certify PASS on all four money invariants**, recomputed from raw tables —
not from the tester's frames.

**Adjudication basis:** I re-queried the **live** stack `sinuwgsqqyqzlpaavimf` directly via the
`investigator_ro` slot (SELECT-only, BYPASSRLS, read-only txn — the §ADR-21 L3 read role brew-ops
provisioned), and recomputed `match_hash` by hand from the migration SQL. Rows present and
unmutated at recompute time. Key: `live-bbot-1781176527471-e7cda45f`, deposit `c10c2ac8…`.

| Invariant | Verdict | Independent ground truth |
|---|---|---|
| **1. Exactly one credit (no double-credit)** | **PASS** | `ts_deposits`: paid, amount 524.00, fee 9.43, **final_amount 514.57**, matched_statement_id `ba46e1ac…`. `wallets_change_logs` for the deposit = **exactly 4 rows, exactly ONE `deposit_credit` (514.57)** to client wallet `…001` (50000.00→50514.57) + 2 mdr_distribute (3.14+2.10) + 1 mdr_residual (4.19). Σ=**524.00** exact. 4 = the canonical single-finalize set for a 2-partner MDR profile (`finalize_deposit`, migration `20260603000002`); a double-credit would be 8, and it's guarded (`FOR UPDATE`+`status='pending'`+cascade single-consumption). |
| **2. Dup-credit = 0 through the bot (SP3)** | **PASS** | `bank_statements amount=524` = **2 rows** (1 in/matched `ba46e1ac…` + 1 out/unmatched). `COUNT(in matched to REQ)=1` — count-based dedup is the sole gate. **`match_hash` recomputed byte-exact**: `sha256("4102508550"+"KBANK"+"52400"+"202606111815")=66bcede794f6…de9de0c`. |
| **3. Clawback unmatched-by-design (SP6)** | **PASS** | out-row `2f87a9ba…`: out/524/`unmatched`, matched_request_id & match_hash NULL, code CB, `อ้างอิง #1` marker present. **Zero** wallet logs reference it; deposit still `paid` (updated_at frozen at 11:16:02 vs clawback at 11:16:47); no extra callback. MATCH-003 reverse correctly NOT exercised. |
| **4. Callback delivered exactly once** | **PASS** | `callback_queue WHERE source_id=deposit` = **1 row**, `delivered`, `attempt_count=1`, code 200, dedup_key `deposit:c10c2ac8…:deposit.paid`. `callback_attempts` = 1 (200). Matches merchant receipt (`total_calls=1`, PAID 524). |

**Caveats (none change the verdict):** I did not recompute the callback HMAC signature (the WC1
`verify_ok` integrity check — needs the client secret, not a money invariant); and this is pinned
to the live rows now (a future run's `reset_runtime_state` would overwrite them).

**Bottom line:** tester GREEN corroborated by independent recompute. Both zero-tolerance
invariants hold (dup-credit=0; clawback leaks no credit). Conservation exact. The campaign-closing
§ADR-21 bank-bot auto-match golden journey is **certified GREEN**. Detailed per-invariant working
filed to `for-next-live-tester/2026-06-11_18-34_…L3-verdict-automatch-PASS.md`.

— next-investigator, 2026-06-11 18:34 +07
