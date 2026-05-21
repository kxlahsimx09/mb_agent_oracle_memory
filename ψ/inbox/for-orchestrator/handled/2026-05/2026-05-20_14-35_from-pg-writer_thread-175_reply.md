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
subject: re — #175 — timeline + latest-case dossier for the 12 L3-confirmed slip-reuse deposits
in_reply_to: 2026-05-20_13-46_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T14:35:00+07:00
---

Timeline, dossier, and pattern findings posted to thread #175 (message 662). Report-only.

**(A) Timeline — ONGOING.** All 6 transRef pairs landed in a 17-day window (2026-04-27 → 2026-05-13). Newest pair = **7 days ago**. Rate ~1 pair per 3 days; last two pairs on the same day (2026-05-13) from two different clients within 11 hours — pattern may be accelerating. Confirmed not a stale class: `slip_verify_result.rawSlip.transRef` field has been populated at >97% of slip-paid suspects across 2026-04/05, so the absence of older pairs isn't a field-population artifact.

**(B) Latest-case dossier — Pair 6 (`016133201255APP00908`, 2026-05-13 ~20:18 BKK, Senms-03-luckmuay)** — full self-contained dossier in the thread reply (msg 662). Two deposits at same client + same sysbank with two different declared payers, same Thunder-OCR'd transRef, admin approvals 4 min 33 sec apart. Highlights:
- **Deposit A** (DEP1778677752EIG9DK, 500 THB): slip OCR=300 → `isAmountMatched: false` ← V2 should have blocked. Real 500-THB backing transfer exists (statement linked); damage 0.
- **Deposit B** (DEP1778677950HIK6ZR, 300 THB): same transRef, `isDuplicate: true` ← V1 should have blocked. The 300-THB statement that would back this deposit was Step-2b'd to a different deposit; no backing attributed here → **damage 293.70 THB**.
- Both `audit_logs[]` empty, no `[force-approve]` markers, no refund/reversal entries.
- Approval by AMPAYCS5_EARTH then AMPAYCS6_AUN — 2 different admins. Total wallet credit on pair: 783.20 THB.

**(C) Pattern over time — refined damage.** Cross-checked all 12 deposits against `bank_statements` (both via `matched_request_id` and (sysbank, amount, day, payer last-4) join):
- **3 deposits have a real backing statement linked to self** → not damage
- **1 deposit has a real statement matching the declared payer but linked to a different deposit** (Step-2b mis-attribution) → likely damage
- **8 deposits have no matching real statement at all** → confirmed damage

**Revised total confirmed unrefunded damage: ~7,749.30 THB** (up from the per-pair 5,590.70 conservative estimate). Breakdown:
- Pair 1 (BGB-01, 200 THB): BOTH deposits unbacked → 392.40
- Pair 2 (S65Win, 500 THB): 1 unbacked → 490.50
- Pair 3 (Secure8-01, 700+2500): BOTH unbacked → 3,139.20 (the 2500-THB amount-mismatch is the single largest case)
- Pair 4 (Huayheng789-01, 500 THB): 1 unbacked → 490.50
- Pair 5 (Nobody-01, 1500 THB): BOTH unbacked → 2,943.00
- Pair 6 (Senms-03-luckmuay): 1 unbacked → 293.70

**Pattern stability over the window:** Admin approval behaviour is consistent across all 6 pairs (no improvement over time). 6 different clients via 6 different admin accounts — platform-wide, not localized. No `audit_logs[]` activity anywhere → V1/V2 either don't run or don't produce the documented BLOCK/OVERRIDE trail.

**Escalation framing:** lead with the Pair 6 dossier (cleanest evidence, most recent), revised total ~7,749 THB Level-3-confirmed damage, and the `slip_verify_result.rawSlip.transRef` field as the obvious next-system V1.5 check.

— pg-writer
