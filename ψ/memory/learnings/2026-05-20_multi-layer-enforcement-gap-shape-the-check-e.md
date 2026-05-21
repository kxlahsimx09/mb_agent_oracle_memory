---
title: **Multi-layer enforcement-gap shape — "the check exists in code" is not "the che
tags: [fraud-detection, enforcement-gap, audit-trail, code-verify, deployed-vs-coded, verify-before-act]
created: 2026-05-20
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Multi-layer enforcement-gap shape — "the check exists in code" is not "the che

**Multi-layer enforcement-gap shape — "the check exists in code" is not "the check enforces in production." Audit all three layers: read+act, bypass path, audit trail.**

A fraud-detection (or any check) system can fail in three independent ways simultaneously, each at a different layer. When auditing a deployed check, don't stop at "the predicate exists in source."

**Three layers, three failure modes (worked example: mobiz slip-fraud, 2026-05-20):**

1. **Read+act layer.** Source code reads detection signals but doesn't enforce/block on them. mobiz Thunder writes `slip_verify_result.{isDuplicate,isAmountMatched,amountInOrder,amountInSlip}` — repo-wide grep across `*.go` deposit handlers returns **zero matches** for any of these fields. **Pure dead data.** Thunder produces, mobiz ignores. Verify by: grep all signal field names across the consumer code; if zero reads → code-level gap.

2. **Bypass path layer.** Even where the check fires (e.g. mobiz's slip-upload-time `transRef`-duplicate check at `DepositController.go:2178-2245`), the bypass path was silent: admin role alone suffices to skip, no `[force-approve]` in notes, no audit trail. Of the 12 L3-confirmed slip-reuse cases, 6 had `slip_duplicate_of` populated (= upload check DID fire) but all were silently bypassed. Verify by: trace the bypass branch from the check — does it require an explicit marker (justification, second-factor, escalation), or just a role check?

3. **Audit-trail layer.** Where BLOCK/OVERRIDE events DO occur (the 2 of 12 `[force-approve]` cases), mobiz logs via `log.Printf` to console only — **no `audit_logs[]` write**. Production query reads "0 audit_log entries" and looks like "no admin intervention happened" even when override was used. Verify by: search for the BLOCK/OVERRIDE code path → check what it persists (DB write, audit table, vs just stdout/file).

**Audit template (run all three for any deployed check):**
- `grep <signal_field_name> <consumer>/*.{go,ts,py}` → confirm code reads it
- trace the bypass branch → require explicit marker, not role-only
- trace the BLOCK/OVERRIDE log → confirm DB-persisted, not just stdout

When even one layer is broken, "the check exists" gives false comfort. The mobiz forensic exhibited all three failures simultaneously; a single layer fix would not close the hole.

**For next-system design:** mirror good patterns (the predicate logic, the field shapes), but **don't inherit the bypass-or-audit shape from a broken source**. Make BLOCK structural, OVERRIDE explicit + audit-persisted, READ tied to ACT.

---
*Added via Oracle Learn*
