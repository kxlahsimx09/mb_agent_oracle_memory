---
title: **Forensic confidence ladder — Level 1/2/3/4 for fraud or coverage-gap analysis.
tags: [forensic-analysis, fraud-detection, confidence-levels, evidence-methodology, data-analysis, diagnostic-pattern]
created: 2026-05-20
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Forensic confidence ladder — Level 1/2/3/4 for fraud or coverage-gap analysis.

**Forensic confidence ladder — Level 1/2/3/4 for fraud or coverage-gap analysis. Each level requires a different evidence shape; do not conflate.**

Concrete progression from this session (G3 slip-reuse investigation, 2026-05-20):

- **L1 — likely-by-heuristic** — 47% of 4,584 collision cells where slip-paid + statement-paid declared the same payer (`customer_bank_account_number` match). Extrapolation: ~534K–1.5M THB risk exposure. **Strength: weak.** Same-payer can be legitimately the same customer transferring twice.

- **L2 — probable-from-data-join** — backing-statement check: 20.8% of fraud-likely slips (26/125 in 100-cell sample) have ≥1 payer-matching statement that is ALL claimed by other deposits, 0 spare to back this slip. Extrapolation: ~250–350K THB. **Strength: moderate.** Excludes the multi-transfer-same-payer false positive class.

- **L3 — proven-by-semantic-unique-signal** — Thunder OCR `transRef` duplication: 6 distinct transRef values × 2 deposits = 12 deposits across the entire 18,141-row slip-paid pool. PromptPay transRef is structurally unique per real bank transfer; two slips with the same transRef = slip-reuse, no other interpretation. **Strength: definitive.** Floor.

- **L4 — confirmed-unrefunded-damage** — per-deposit forensic on the 12: status, wallet credit, audit_logs, refund/rollback. 6 of 12 had no backing statement matched to self → real wallet credit unrefunded. **5,590 → 7,749 THB confirmed loss** (revised up after cross-checking bank_statements). **Strength: damage quantified.**

**Template for future analysis:** L1 surfaces the class. L2 narrows by data-join evidence. L3 nails by semantic-unique signal. L4 quantifies damage in the actual ledger. Each step removes a different false-positive class; each step needs its own query shape. Don't claim L3 strength from L1 evidence (47% "fraud-likely" is not "47% fraud-confirmed").

---
*Added via Oracle Learn*
