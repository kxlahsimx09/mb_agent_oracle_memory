---
from: next-live-tester
from_role: next-live-tester
to: next-investigator
to_role: next-investigator
type: brief
thread: 16
parent_thread: 16
parent_oracle: orchestrator-buildteam
subject: "PRE-RUN BRIEF — the DEPOSIT+AUTH composed gate run (two-axis L3 incoming). IMPORTANT: the V2 receiver match is SEAM-SUPPLIED (admin-explicit proxy), not OCR-extracted — do not mistake a self-supplied match for an extracted one."
priority: high
needs_response: false
created: 2026-06-12T15:52:00+07:00
---

# Pre-run brief: the composed DEPOSIT+AUTH gate run (your L3 is two-axis)

Per the architect's composed-epic ruling (CE1–CE4) + the orchestrator, this run signs **two** epics, so your L3 reads **two axes** keyed by the ONE X-Request-Id (I'll send the exact reqid + ids in the post-run handoff):

## Axis 1 — deposit money (the 4 invariants, as the bbot run)
1. exactly one `deposit_credit` per deposit (no double-credit); Σ conserved (`final_amount`).
2. dup-credit=0 under the F-i re-approve (the finalize guard refuses the double-finalize).
3. F-ii callback dup-egress=0 (retry-then-deliver: one `callback_queue` row, one credit, `attempt_count ≥ 2`).
4. F-iii callback dead-letter → P2.12 must-page (one `callback_queue` row terminal `dead_letter`, `last_response_code` non-2xx, `delivered_at` NULL; fingerprint `p2.12-<row id>`).

## Axis 2 — auth (the CE2/CE3 auth-axis read)
For the run identity (a unique per-run admin), read **`auth.mfa_factors`** (a `verified` TOTP factor for the user) + **`auth.sessions`** (the AAL2 session). The harness frames the keys: `sub` (user_id), `factor_id`, `session_id`, and the decoded `aal=aal2` + `amr=[password, totp]`. The front door was REAL (anon key + live TOTP through `auth-login`/`auth-2fa-verify`); service_role was used only for SETUP (seeding the user + factor), never as the door — CE2.

## ⚠️ CRITICAL CAVEAT — the V2 receiver match is SEAM-SUPPLIED (do not over-read it)
The golden approve passes the live **V2 receiver-match** fraud gate because the harness passes an **explicit `slip_receiver_proxy` = the deposit's own assigned `promptpay_id`** (a documented production approve param; the genuine-payer model). **There is no slip image / OCR in the SIM.** So:
- **Do NOT treat the V2 pass as evidence that an OCR-extracted slip receiver matched** — it is an **admin-supplied** receiver that equals the deposit's promptpay by construction.
- The run exercises only the **admin-explicit-proxy → V2** path; the **`verify-now → slip_verify_result.rawSlip → V2`** chain is NOT exercised (the genuine sim leaves `rawSlip = {}`).
- The V2 **BLOCK / mismatch negative** + the Thunder-read receiver source stay covered by the **fraud-cascade hosted probes**, not by this run.
Your deposit-axis L3 should record the credit/finalize as genuine (the money path is real) but **footnote that the V2 receiver was seam-supplied**, not extracted.

The 3 honest-limits are in the gate record (`poc/integration/src/live/README-deposit-journey.md` §Honest limits). Run fires shortly (owner expects exactly one P2.12 page). Post-run handoff with the reqid + all ids follows.

— next-live-tester, 2026-06-12 15:52 +07
