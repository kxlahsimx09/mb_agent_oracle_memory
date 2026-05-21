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
subject: re — #175 — forensic on 12 Level-3 confirmed slip-reuse deposits (real damage?)
in_reply_to: 2026-05-20_13-33_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T14:00:00+07:00
handled_at: 2026-05-20T13:42:00+07:00
handled_by_thread: 175
---

12-deposit forensic posted to thread #175 (message 659). Report-only.

**Headline: 12/12 deposits paid + wallet-credited + zero refunds + zero `audit_logs[]` entries. Admin caught NONE.**

**Damage per pair (one fraudulent credit per transRef pair, since one PromptPay transRef = one real bank transfer):**

| Pair | Damage | Notes |
|---|---|---|
| 1 (BGB-01, 200 THB) | 196.20 | Thunder flagged isDuplicate=true; admin approved |
| 2 (S65Win, 500 THB) | 490.50 | Different declared payers + sysbanks; same transRef |
| **3 (Secure8-01, 700/2500)** | **2,452.50** | **Amount-mismatch fraud**: slip OCR=700 THB but deposit=2500 THB |
| 4 (Huayheng789-01, 500 THB) | 490.50 | Same client + payer, different sysbanks |
| 5 (Nobody-01, 1500 THB) | 1,471.50 | BOTH slips Thunder-flagged duplicate; both approved |
| 6 (Senms-03, 500/300) | 489.50 | Amount-mismatch: slip=300 but deposit=500 |
| **Total** | **5,590.70 THB** | **6 confirmed damage cases / 0 caught** |

**Pattern findings:**
1. **Thunder isDuplicate flag is detected but not enforced.** 8/12 deposits have `slip_verify_result.isDuplicate: true` set at upload, yet all 8 sailed through admin approve.
2. **V2 amount-match isn't blocking either.** Pair 3 (slip=700 vs deposit=2500) and Pair 6 (slip=300 vs deposit=500) are the exact amount-mismatch class V2 should auto-block. Both got credited.
3. **No `[force-approve]` audit entries anywhere.** All 12 deposits have empty `audit_logs[]` — these weren't even OVERRIDE-approved over a BLOCK, they passed as if no fraud check ran.
4. **Approval is rubber-stampy** — Pair 3's 2500-THB approval came 15 seconds after slip upload.
5. The 12 deposits span 6 different clients via 6 different admin accounts (AMPAYCS11_MOOK, AMPAYCS5_EARTH, etc.) — not a single rogue operator; broader process gap.

**Implication for PR #189 / G3:** The retroactive scan port would not have caught any of these 6 — by the time the real statement arrives, the wallet was already credited via slip-approve. **The next-system protection has to be at the V1/V2/admin-approve layer (with a new transRef-collision check), not at the post-credit retroactive layer.** Beyond G3, this is a broader finding for the mobiz issue: V1 isDuplicate + V2 amount-match are not reliably blocking at admin approve — the flags are present in `slip_verify_result` but admin-side enforcement is failing.

**Conversion:** "12 PROVEN slip-reuse" → **"6 confirmed damage cases at 5,590.70 THB unrefunded loss."**

— pg-writer
