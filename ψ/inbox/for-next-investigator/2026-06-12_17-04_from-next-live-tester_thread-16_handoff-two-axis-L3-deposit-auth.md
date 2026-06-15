---
from: next-live-tester
from_role: next-live-tester
to: next-investigator
to_role: next-investigator
type: handoff
thread: 16
parent_thread: 16
parent_oracle: orchestrator-buildteam
in_reply_to: 2026-06-12_15-52_from-next-live-tester_thread-16_PRERUN-brief-deposit-two-axis-L3.md
subject: "TWO-AXIS L3 handoff — composed DEPOSIT+AUTH signing run 57bd31e7 (full ladder GREEN + F-iii AMBER-by-design). Deposit money axis + auth axis keys inside. REMINDER: V2 receiver was SEAM-SUPPLIED."
priority: high
needs_response: true
created: 2026-06-12T17:04:00+07:00
---

# L3 re-cert — the composed DEPOSIT+AUTH signing run

**X-Request-Id:** `57bd31e7-f40e-40e1-850b-8e35635622a1`
**Stack:** `sinuwgsqqyqzlpaavimf` (LIVE), rev `20260612000050`. Read via `investigator_ro` ($SINUW_RO_DB_URL); sinuw is yours (orchestrator: no other deploys in flight).
**Run:** EC2 stable receiver (`https://18-136-227-108.sslip.io`). Harness RAN + framed; the verdict is yours (AR2). Ledger: **all L0/L1 + F-i + F-ii GREEN; F-iii AMBER-by-design** (no Keep lever → owner L5 page). Evidence: `poc/integration/evidence/live/deposit/57bd31e7-…/` (14 frames; committed `9d5606a`).

## Axis 1 — DEPOSIT money (the 4 invariants)
- **Golden deposit `abd853c2-9d0e-4fba-b15e-37d2e2eed741`** (amount 1000, fee 18, final 982): assert exactly **one `deposit_credit` = 982** (I read 1 row), Σ conserved, `status=paid`, callback `deposit.paid` **delivered once**.
- **F-i dup-credit=0:** a second admin `approve` on the paid golden deposit → **HTTP 400 refused** (finalize/not-pending guard); assert `deposit_credit` rows for `abd853c2` **stays 1**.
- **F-ii dup-egress=0:** deposit **`a0f823b6-1172-4726-96a6-218778fa1839`** (amount 712) bound to `/flaky` (500-once→200) → §ADR-9 retry then delivered: assert **one** `callback_queue` `deposit.paid` row, `status=delivered`, `attempt_count=2` (≥2 = a retry happened), exactly **one** `deposit_credit`.
- **F-iii dead-letter → P2.12:** deposit **`e6367d60-a130-45a6-973e-3e6a65a8f207`** (amount 713) bound to `/fail` → `callback_queue` row **`704f4688-bb1d-48e3-9b1e-96e28873f4a5`** terminal `status=dead_letter`, `attempt_count=3`, `last_response_code=500`, `delivered_at=NULL`; fingerprint **`p2.12-704f4688-…`**. Also confirm deposit #713 is itself money-correct (one `deposit_credit`; a failed *callback* must not affect the *credit*).

## Axis 2 — AUTH (CE2/CE3 auth-axis read)
Run identity (unique per-run admin): **user_id `1671e705-20e5-43a1-814f-db912cbc3fc4`**, **factor_id `a6557269-cb93-4614-aaee-9f1c60f3dd0f`**, **session_id `faeed291-e388-419f-823f-42a43774119a`**. Decoded AAL2 claims: **`aal=aal2`, `amr=[{totp},{password}]`**.
- Read **`auth.mfa_factors`** WHERE `user_id=<above>` → a TOTP factor `status='verified'`.
- Read **`auth.sessions`** WHERE `id=<session_id>` → the AAL2 session for this run.
- The front door was REAL (anon key + live TOTP through `auth-login` → `auth-2fa-verify`); service_role only for SETUP (seeding the user+factor), never as the door — **CE2** holds.

## ⚠️ CARRY-OVER CAVEAT (from the 15:52 pre-brief) — V2 receiver is SEAM-SUPPLIED
The golden approve passed the live **V2 receiver-match** fraud gate because the harness passed an **explicit `slip_receiver_proxy` = the deposit's own `promptpay_id`** (a documented production approve param; the genuine-payer model). **No slip image / OCR** (M2 territory). So **do not read the V2 pass as an OCR-extracted match** — it's an admin-supplied receiver equal to the deposit promptpay by construction. The money path (credit/finalize) is genuine; **footnote V2 as seam-supplied** in your deposit-axis verdict. (The 3 V2 honest-limits are in the gate record: `poc/integration/src/live/README-deposit-journey.md` §Honest limits.) F-ii's "merchant saw 0 POSTs" is the external-receiver-mode limit (`readEvents=[]`); the `attempt_count=2` from `callback_queue` is the real signal.

Your two-axis verdict (PASS/FAIL) → the gate package returns to orchestrator for the **two owner L5 ACCEPTs** (DEPOSIT + AUTH). Flag immediately if any row is mutated.

— next-live-tester, 2026-06-12 17:04 +07
