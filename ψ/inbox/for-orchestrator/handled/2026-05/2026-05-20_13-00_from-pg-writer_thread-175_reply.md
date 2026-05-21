---
from: pg-writer
from_role: pg-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: re — #175 — fraud CONFIRMATION (Level 2 backing-statement + Level 3 Thunder OCR)
in_reply_to: 2026-05-20_11-51_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T13:00:00+07:00
handled_at: 2026-05-20T13:05:00+07:00
handled_by_thread: 175
handled_by_inbox: for-orchestrator
handled_note: "G3 L2+L3 fraud confirmation surfaced to user: L3 (Thunder OCR transRef duplication) = 12 deposits definitively confirmed across 18,141 (0.066% floor); L2 (backing-statement payer-match) = 20.8% PROBABLE on 100-cell sample, ~250-350K THB extrapolated; methodology caveat noted (source_account_no empty 100%, last-4 in mis-named dest_account_last4). Key design implication: slip_verify_result.rawSlip.transRef is structurally-better signal — unique per real transfer, OCR'd at upload, already persisted — V1.5 fraud check using transRef catches L3 with zero false positives. Refined G3 options expanded (drop+V1.5 / merge+follow-up / hold-and-amend-to-transRef anchor). Decision still on user."
---

Confirmed fraud results posted to thread #175 (message 657). Report-only.

**Step 0 — Thunder OCR fields confirmed feasible.** `slip_verify_result.rawSlip.transRef` is populated on slip-paid suspects (PromptPay transaction reference OCR'd from the slip), alongside `rawSlip.date`, `rawSlip.sender` (masked account), `rawSlip.amount`, `payload`, etc.

**Level 3 (definitive) — Thunder OCR transRef duplication across entire 18,141 slip-paid pool:**
- **6 distinct transRef values × 2 deposits = 12 deposits** with structurally-unambiguous slip-reuse (one PromptPay transRef cannot legitimately appear on two slips).
- Production rate: **12 / 18,141 = 0.066%** definitively-confirmed.

**Level 2 (backing-statement check on 100-cell sample, 125 fraud-likely slips, 30,750 THB):**

| Verdict | Slips | THB | Meaning |
|---|---|---|---|
| CONFIRMED FRAUD | **0** | 0 | sampling artifact — cells were selected to contain ≥1 statement, so strict-0 is structurally unreachable |
| **PROBABLE FRAUD** | **26 (20.8%)** | **6,600** | ≥1 payer-matching statement exists, but ALL claimed by other deposits; 0 spare to back this slip |
| UNCONFIRMED | 99 (79.2%) | 24,150 | ≥1 unclaimed payer-matching statement exists OR slip's own rid is already linked by matcher Step 2b (legitimately backed) |
| OUT_OF_SCOPE | 0 | 0 | All 125 slips fell within sysbank 0170681475 |

**Multi-claim payer signal:** 6 distinct `(custom_bank_account, custom_bank_bank_code)` tuples each claimed across 2-3 slip-paid deposits → 16 deposits with reused-payer-identity (heavy overlap with the 26 PROBABLE).

**Conversion verdict — "47% fraud-likely" → confirmed:**
- 0% strictly-confirmed by Level 2 (sampling artifact)
- **20.8% PROBABLE-confirmed** by Level 2 → ~250-350K THB extrapolated slip-level loss across all 4,584 collision cells
- **12 deposits** definitively confirmed by Level 3 (Thunder OCR transRef duplication) across all of mobiz history — this is the floor

**Key data caveat surfaced during the work:** `bank_statements.source_account_no` is empty on 100% of rows at this sysbank (68,302/68,302). The payer's last-4 lives in `dest_account_last4` (misnamed — actually source last-4) and the full account appears only in `description` via `TR fr <bank3>-<acct>`. My Level 2 join had to parse both. A re-run on a different sysbank with different bot fill behavior would need different field extraction.

**Design implication for PR #189:** `slip_verify_result.rawSlip.transRef` is a structurally-better fraud signal than payer-matching heuristics — unique per real transfer, OCR'd at upload, already persisted. A next-system V1.5 fraud check that looks up `transRef` against prior slip-paid deposits would catch the definitive Level 3 class with zero false positives. Worth flagging in the G3 + mobiz issue path.

— pg-writer
