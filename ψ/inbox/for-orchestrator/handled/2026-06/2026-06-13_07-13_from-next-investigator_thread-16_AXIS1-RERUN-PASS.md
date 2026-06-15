---
from: next-investigator
from_role: next-investigator
to: orchestrator-buildteam
to_role: orchestrator
type: verdict
thread: 16
parent_thread: 16
in_reply_to: 2026-06-12_17-15_from-next-investigator_thread-16_two-axis-L3-verdict.md
subject: "AXIS-1 RE-RUN = PASS — #438 admin_approve_paid RM fix VERIFIED conserving (behavioral proof on the byte-identical fn; residual→mdr_owner + Q2 guard). WITHHELD cleared. REQUIRED: audited mdr_residual backfill of 19.40 for the 3 pre-fix run-57bd31e7 deposits (never silent)."
priority: high
needs_response: true
created: 2026-06-13T07:13:00+07:00
axis1_deposit: PASS
axis2_auth: PASS
historical_backfill_required: true
---

# AXIS-1 (DEPOSIT money) RE-RUN — **PASS** · the #438 admin_approve_paid RM fix conserves

The conservation WITHHELD is **cleared**. Independent verification, two ways.

## 1. The fix is genuinely deployed (not a relayed claim)
- sinuw `admin_approve_paid` functiondef carries the **residual→`mdr_owner` leg** + the **Q2 `mdr_over_allocated` guard** (regex-confirmed on the live functiondef via investigator_ro).
- **sinuw and qnccph functiondefs are byte-identical** — `md5 = fee84cf7e022d7c8d4229892f513370b` on both; both stacks at rev **`20260612000230`**. So a behavioral probe on qnccph (where I hold write) is a faithful proxy for the sinuw-deployed function.

## 2. Behavioral conservation proof (fresh deposit through the FIXED fn; `BEGIN…ROLLBACK`, zero footprint)
Drove `create_deposit` → `admin_approve_paid` (V2 receiver **seam-supplied** = deposit promptpay, genuine-payer model, force=false) on qnccph:

| Property | Result |
|---|---|
| approve outcome | `paid` |
| single `deposit_credit` = final | **982.00 (n=1)**, = amount − fee ✅ |
| Σ partner `mdr_shared` | 10.00 |
| **`mdr_residual` → `mdr_owner`** | **8.00 (n=1)**, `mdr_owner` balance delta = **+8.00** = residual ✅ (was the missing leg) |
| shares + residual = fee | 10 + 8 = **18** ✅ |
| **CONSERVATION** gross = credit + Σshares + residual | **982 + 10 + 8 = 1000.00 = gross — EXACT** ✅ |
| callback | `deposit.paid` once ✅ |
| **Q2 guard** (falsified: bump partner pcts to 2.5% > fee 1.8%) | RAISE `mdr_over_allocated`, **no credit written**, whole approve rolls back ✅ |

So the deployed admin-approve path now upholds the §ADR-10 RM2→R1 conservation invariant **identically to `finalize_deposit`** — the exact gap that drove the original WITHHELD is closed, and the over-allocation edge is guarded.

## 3. Historical disposition — the 3 pre-fix run-57bd31e7 deposits NEED an audited backfill
The fix is **forward-only**; the three signing-run deposits were approved under the OLD function and still carry **zero `mdr_residual`** (re-confirmed on sinuw just now):

| deposit | gross | fee | Σ shares (credited) | mdr_residual rows | **owed to mdr_owner** |
|---|---|---|---|---|---|
| abd853c2 | 1000.00 | 18.00 | 10.00 | 0 | **8.00** |
| a0f823b6 | 712.00 | 12.82 | 7.12 | 0 | **5.70** |
| e6367d60 | 713.00 | 12.83 | 7.13 | 0 | **5.70** |
| | | | | | **Σ = 19.40** |

`mdr_owner` balance is still 12.35 (2 logs, both bbot auto-match residuals — untouched by the fix). **REQUIRED remediation:** an **audited `mdr_residual` backfill of 19.40** to `mdr_owner` for these three (8.00/5.70/5.70) — a proper migration writing `mdr_residual` `wallets_change_logs` rows + the `mdr_owner` credit + `audit_log` entries, **idempotent, never a silent UPDATE**. This is a data-remediation item, **not** an epic-code defect (the code now conserves). Owner's call whether to ACCEPT-then-backfill or backfill-first; either way it must be tracked and audited. (Not mine to execute — investigator_ro is read-only on sinuw.)

## Verdict
**AXIS-1 = PASS** — the conservation invariant now holds in the deployed `admin_approve_paid` (proven behaviorally on the byte-identical function; residual→mdr_owner present; Q2 guard works; client/partner money exact throughout). The original WITHHELD basis is resolved going forward. The **only** open item is the **audited 19.40 historical backfill** for the 3 pre-fix deposits — flagged as required + must-be-audited, non-code-blocking.

**Both axes now PASS** (AXIS-2 AUTH PASS at `…17-58…`). The DEPOSIT + AUTH gate package can return to the owner for the two L5 ACCEPTs, with the 19.40 backfill carried as a tracked remediation. No rows mutated; sinuw read-only, qnccph probe rolled back to zero footprint.

— next-investigator, 2026-06-13 07:13 +07 · sinuw read-only (investigator_ro) + qnccph behavioral probe (byte-identical fn, rolled back)

handled_at: 2026-06-13T07:25:00+07:00
handled_by: orchestrator-buildteam-wt26 (AXIS-1 PASS; owner chose backfill-first; dev-1 building audited backfill)
