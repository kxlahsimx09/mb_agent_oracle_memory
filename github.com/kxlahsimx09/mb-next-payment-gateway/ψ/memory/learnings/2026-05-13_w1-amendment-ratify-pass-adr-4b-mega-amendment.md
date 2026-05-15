---
title: W1 amendment ratify pass — §ADR-4b mega-amendment (FA1-FA4 + CB1-CB3) closing th
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, amendment, w1, adr-4b, mega-amendment, degenerate-fifo-carve-out, status-name-canonicalization, customer-bank-rename, v1-hash-source-of-truth, threads-98-99-100-closed, deposit-001-005-awaiting-thread-closed-inline, bundle-fix-in-adjacent-amendment-instance-3-DURABLE, production-audit-corrects-writer-framing-instance-1-NEW, user-prompted-deep-audit-before-ratify-instance-1-NEW, deliberate-divergence-from-mobiz-current-instance-8, verify-via-production-mcp-instance-9, trace-chain-36-links, pr:85]
created: 2026-05-13
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 amendment ratify pass — §ADR-4b mega-amendment (FA1-FA4 + CB1-CB3) closing th

W1 amendment ratify pass — §ADR-4b mega-amendment (FA1-FA4 + CB1-CB3) closing threads #98 + #99 + #100 + DEPOSIT-001/005 AWAITING_THREAD flags in single unified amendment. Bundle pattern instance #3 DURABLE threshold reached.

# Pass shape

Combined baseline + ratify landing — instance #8 (continuing durable).

Bundle-fix-in-adjacent-amendment — instance #3 (DURABLE threshold reached per W1 §Port-from-mobiz protocol rule 2): bundles 3 thread ratifications + 2 epic-deposit AWAITING_THREAD closures into single §ADR-4b amendment. After thread #93 §H3-Fix instance #1 + thread #95 §Bundle taxonomy instance #2.

# 7 ratifications

## FA1-FA4 (status enum + Decision #3 amendments)
- FA1: Degenerate-multi-candidate FIFO carve-out (Decision #3 amendment)
- FA2: Canonical name `review` (production parity; ghost name `review_required` had 0 production rows)
- FA3: `pending_review` not adopted; semantic via `matched_request_id` cross-reference per D2 amendment Steps 2a/2b "link only"; admin UX SQL contract
- FA4: §ADR-4b D3 inline text correction (bundle pattern)

## CB1-CB3 (ts_deposits schema + V1 cross-amendment)
- CB1: ts_deposits `custom_bank_*` → `customer_bank_*` rename (4 cols; greenfield zero-cost)
- CB2: Inline storage preserved (hot-path-friendly per 609k row scale)
- CB3: §ADR-4b B7 + §ADR-4d V1 cross-amendment — V1 slip-side hash recompute reads ts_deposits.customer_bank_* as canonical source-of-truth

# Production audit grounding

dpay MCP audit revealed:
- ts_deposits: 609,680 rows / 100% custom_bank_* populated (CB1 ratification ground)
- bank_statements review/pending_review/review_required: 2,223 / 2,178 / **0** rows (FA2 production drift)
- pending_review deep-audit: 100% link to terminal deposits (1,288 expired / 883 paid / 7 failed) → FA3 semantic correction

# Critical: FA3 architect-side correction of writer framing

Writer thread #100 framed `pending_review` as "couldn't classify inbound." User prompted deep-audit; architect dpay MCP JOIN classified ALL 2,178 rows as Step 2b race-case admin flip-back (linkPaidDeposit found terminal-status match).

→ Ratification proceeds with **corrected rationale**: `pending_review` semantic moves from match_status (mobiz) to `matched_request_id` cross-reference (next-system per §ADR-4b D2 amendment 2026-05-06 "statement-side link only").

→ Admin UX implementation contract specified:
```sql
SELECT bs.*, td.status FROM bank_statements bs
JOIN ts_deposits td ON td.request_id = bs.matched_request_id
WHERE bs.match_status='unmatched' AND bs.matched_request_id IS NOT NULL
  AND td.status IN ('expired', 'paid', 'failed');
```

# NEW patterns

## Bundle-fix-in-adjacent-amendment — instance #3 DURABLE threshold reached

Pattern is durable architectural rule per W1 §Port-from-mobiz protocol rule 2 (3-instance threshold met).

Trigger conditions:
1. Bundled subject is mechanical OR architecturally-cross-cut affecting current amendment scope
2. Fix/ratification is contained (single amendment block can house it)
3. Explicit traceability preserved (§subblock with full context)
4. User-directed bundle vs separate threads

Brew-ops handoff for W1 workflow doc.

## Production-audit-corrects-writer-framing — instance #1 NEW

Sub-pattern of verify-divergence-via-production-MCP at amendment time (instance #9 of broader pattern).

Trigger conditions:
1. Writer recommendation grounded in small sample (< 1% of population)
2. Sample-based inference about semantic enum/distinction
3. Decision touches architecturally-load-bearing concept (status enum, taxonomy, schema)

When all 3 apply, architect deep-audit before ratify is forensic discipline. Brew-ops handoff candidate at instance #2.

## User-prompted deep-audit before ratify — instance #1 NEW

*"ลองเช็ค เคสนี้บน current prod data ให้ละเอียดอีหน่อย"* triggered FA3 deep-audit. Distinct from "user-mandate-revision-mid-dialogue" (thread #95) which revised architect-rec from external context shift; this pattern is user-requested deeper verification before ratify. Brew-ops handoff candidate at instance #2.

## Continuing-durable
- Deliberate divergence from mobiz current — instance #8 (FA1)
- Verify-divergence-via-production-MCP at amendment time — instance #9
- Writer-flagged unratified surface during user-story authoring — instance #5

# User dialogue trajectory

- Writer gap-analysis pass surfaces 3 DEPOSIT-001/005 AWAITING_THREADs (threads #98/#99/#100)
- Architect verifies via dpay MCP + proposes unified mega-amendment
- User asks for deep audit on #100 Q2 pending_review semantics
- Architect deep-audit corrects writer framing (100% terminal-status linked; not unclassified)
- Architect re-proposes ratify path with corrected FA3 rationale + admin UX implementation contract
- User wholesale-ratifies: "A เลย"

User-pushback-as-design-force pattern instance #35 — user requested deep-audit before ratifying enum-level decision. Pattern: forensic discipline when writer rationale is sample-based.

Pre-Input-5 instance count: 25 → 26.

# Architecture-decision phase status post-pass

**19 ADRs/amendments ratified `#decision`; 0 live `#provisional`.** Bundled amendment closes 7 ratifications across 3 deferred surfaces (DEPOSIT-001 + DEPOSIT-005 × 2) without opening new provisional.

Trace chain: extends 35 → 36 links (continuing longest-in-repo). Sequence: ... → `d98c5222` §ADR-10 amend → `fe017d2d` §ADR-9 wire contract → this pass.

# Same-arc closure progression (2026-05-13 epic-deposit work-pass + poc-implement audit)

Total 7 architect threads closed today via 4 amendments:
- AM #85 (this) — §ADR-4b mega: threads #98+#99+#100 (3 threads + 2 AWAITING_THREADs)
- AM #82 — §ADR-10 wallet: thread #96
- AM #83 — §ADR-9 wire contract + §Bundle terminal-taxonomy: thread #95 + DEPOSIT-004 AWAITING_THREAD
- 2 PoC-bug replies: #94 + #97

Phase-1 epic-deposit AWAITING_THREAD inventory reduction: DEPOSIT-001 (1 flag closed) + DEPOSIT-004 (1 flag closed) + DEPOSIT-005 (2 flags closed) = 4 AWAITING_THREAD closures total.

# Handoffs

## next-writer (consolidated handoff across 3 threads)
- DEPOSIT-001: strip AWAITING_THREAD flag; field references custom_bank_* → customer_bank_*; cite §CB1-CB3
- DEPOSIT-005: strip 2 AWAITING_THREAD flags; consolidate status references to `review`; cite §FA1-FA4
- Optional: DEPOSIT-002 + DEPOSIT-007 cross-references to CB3 V1 source-of-truth

## poc-implement
- Field name port-verbatim customer_bank_* (not custom_bank_*)
- Compound query pattern for race-case admin flip-back queue (FA3 admin UX SQL)
- CB3 V1 hash recompute source-of-truth path
- Step 2b implementation contract: `matched_request_id` cross-reference; `match_status` unchanged from Step 1 state

# Sources

- threads #98 + #99 + #100 (writer-pass gap-analysis 2026-05-13)
- dpay MCP audit 2026-05-13: ts_deposits 609k row scan + bank_statements review/pending_review distribution + pending_review JOIN ts_deposits deep-audit
- mobiz code references: DepositRequestController.go CreateDeposit + transactionMatcher.go Step 2b linkPaidDeposit
- §ADR-4b Decision #2 + #3 (inline text corrected)
- §ADR-4b D2 amendment 2026-05-06 thread #78 (Steps 2a/2b "statement-side link only" — load-bearing for FA3)
- §ADR-4b B7 amendment (match_hash composition; CB3 specifies symmetric slip-side)
- §ADR-4d V1 amendment 2026-05-05 thread #77 (V1 fraud cascade; CB3 closes slip-side source-of-truth gap)
- §ADR-4d D1 amendment H1-H4 (slip-upload 3-actor; CB3 cross-cut)
- vault `learning_2026-05-02_getalldeposits-admin-list-gained-accountnumbe` (CB1 semantic verification)
- DEPOSIT-001 + DEPOSIT-005 writer-pass AWAITING_THREAD flags (closed inline via writer handoff signal)
- Concurrent same-arc amendments: §ADR-4d D8 thread #92 + §ADR-9 thread #95 + §ADR-10 thread #96
- session-arc memory project_session_arc_2026-05-10-to-11.md

# Commit anchor

`7551b0d` (amendment combined-landing on branch `architect/w1-adr4b-mega-amendment-customer-bank-fifo-status-2026-05-13`). PR #85 merged via `42a4d0b`.

---
*Added via Oracle Learn*
