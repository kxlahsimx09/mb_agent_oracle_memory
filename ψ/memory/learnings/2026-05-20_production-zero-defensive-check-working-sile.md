---
title: **Production-zero ≠ defensive check working — silent mis-tune detection.**
tags: [fraud-detection, verify-before-act, production-data, silent-mis-tune, defensive-checks, diagnostic-pattern]
created: 2026-05-20
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Production-zero ≠ defensive check working — silent mis-tune detection.**

**Production-zero ≠ defensive check working — silent mis-tune detection.**

When a defensive check returns zero hits over a meaningful production window AND the suspect-population is non-trivial, treat the silence as a signal to investigate the check, not as confirmation that the class doesn't occur.

**Concrete example (mobiz `checkRetroactiveSlipFraud`, 2026-05-20):** the scan returned 0 hits across ~9 months of production. Suspect-population predicate (`paid` + `slip_uploaded_at` exists + `bank_transaction_id IS NULL`) matched **18,141 deposits**, and `(system_bank, amount, BKK-day)` aggregation found **4,584 collision cells** containing both slip-paid and statement-paid deposits. Yet the scan flagged zero. Root cause: blocking clause read `sus.PaidAt` which is the Go zero-value `time.Time` for all 18,141 slip-paid suspects (admin slip-approve path never writes `paid_at`). Every suspect was filtered out at `paidMin < timeMin`. **Scan was structurally inert by data shape, not by logic.**

**Investigation pattern that works:**
1. Confirm the suspect-population is large enough to be expected to fire (not "rare class").
2. Confirm collision-pair (or whatever the scan looks for) actually exists in production data via independent query.
3. Walk the predicate field-by-field against a known-collision sample and identify which clause filters everything out.
4. Distinguish "rare class" (a) from "silent mis-tune" (b).

**Operational corollary:** zero hits + non-trivial suspect population + collision-pair existence = bug, not safety. Port-and-improve loses to drop-and-redesign when the source mechanism is structurally broken (companion learning: [[drop-broken-source-over-port-broken-source]]).

---
*Added via Oracle Learn*
