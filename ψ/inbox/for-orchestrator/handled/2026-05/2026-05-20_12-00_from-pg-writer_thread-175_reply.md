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
subject: re — #175 — damage assessment on 4,506 collision cells (G3)
in_reply_to: 2026-05-20_11-12_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T12:00:00+07:00
handled_at: 2026-05-20T12:05:00+07:00
handled_by_thread: 175
handled_by_inbox: for-orchestrator
handled_note: "G3 damage assessment surfaced to user: 4,584 collision cells × 47% fraud-likely (matching declared payer) extrapolates to ~534K THB lower bound / 1.0–1.5M THB upper bound risk exposure across mobiz history. Methodology caveats noted (anchor switched to paid_at+slip_uploaded_at due to MCP $date silent fail; first-100-by-order not random). Three anchor-fix options framed for PR #189 amendment (read slip_uploaded_at / widen BKK-day window / write canonical timestamp on slip-approve). Decision still on user."
---

Damage assessment posted to thread #175 (message 647). Report-only.

**Headline numbers (100 cells sampled from 4,584 production collision cells):**

| Category | Cells | % | Cell-amount sum |
|---|---|---|---|
| FRAUD-LIKELY (matching declared payer) | 47 | 47% | 11,650 THB |
| COINCIDENCE (different payers) | 53 | 53% | 14,004 THB |
| AMBIGUOUS (empty payer fields) | 0 | 0% | 0 THB |

**Extrapolation to 4,584 cells:**
- ~2,154 fraud-likely cells × ~248 THB mean = **~534K THB cell-level risk exposure (lower bound)**
- Per-slip extrapolation (busy cells often have multiple fraud-likely slips per cell): **~1.0–1.5M THB upper bound**

**Methodology note:** I had to switch the collision anchor to `paid_at` (stmt) + `slip_uploaded_at` (slip) — both 100%-populated — because the MCP tool's `{"$date": ...}` filter syntax silently fails (any date-range query in $match returns 0 docs regardless of data; verified with a known-positive single-doc test). Repopulated count came out at 4,584 (vs the earlier 4,506 from `updatedAt` grouping — ±2% measurement noise). I used `$limit` instead of `$sample` because `$sample` timed out at this scale, so the 100 cells are the first-100-by-group-order — not strictly random; extrapolation should be treated as order-of-magnitude.

**Damage caveats** (in priority order):
1. Cell-level count is a lower bound — busy cells (e.g. 200 THB on a popular day with 90+ statement-paid deposits) can contain multiple slip-paid suspects each matching a different statement-paid payer; each fraud-likely slip = one fraudulent wallet credit.
2. "Fraud-likely" ≠ confirmed fraud. The matching-payer signal is suspicious but some same-payer (slip, stmt) pairs are legitimately the same customer transferring twice in a day.
3. The anchor proxy misses slips uploaded the morning after a late-night transfer (cross-day boundary).

**Verdict refined: (b) silent mis-tune, with meaningful damage scale.** The collision class is large (4,584 cells, ~25% of the slip-paid population), and nearly half show a matching-payer slip-reuse pattern. The retroactive scan, had it actually fired, would have flagged approximately 2,000+ cells of suspected fraud across mobiz history — all currently passing through V1 because the scan reads `paid_at` and slip-approve never writes it.

**For PR #189:** the inertness ports faithfully unless the next-system fix either (i) reads `slip_uploaded_at` instead of `paid_at`, (ii) widens the BKK-day window for cross-day slip uploads, or (iii) ensures next's slip-approve writes the canonical "real transfer day" timestamp.

— pg-writer
