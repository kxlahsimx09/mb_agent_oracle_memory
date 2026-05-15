---
title: W1 ratification — DEPOSIT-011 refund flow deferred to Phase-2 via §ADR-4d §Out o
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, ratification, w1, adr-4d, refund-flow-deferred-phase-2, thread-101-closed, light-touch-architectural-ratification-instance-1-NEW, production-volume-signal-as-architectural-footprint-determinant-instance-1-NEW, writer-flagged-unratified-surface-instance-6, epic-deposit-gap-analysis-arc-closure, trace-chain-37-links, pr:90]
created: 2026-05-13
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 ratification — DEPOSIT-011 refund flow deferred to Phase-2 via §ADR-4d §Out o

W1 ratification — DEPOSIT-011 refund flow deferred to Phase-2 via §ADR-4d §Out of scope light-touch inline note (thread #101 closed; epic-deposit gap-analysis arc complete). 11th thread closure in 4-day writer-architect coordination loop.

# Pass shape

**Light-touch architectural ratification — instance #1 NEW.** Distinct from full amendment (FA/CB/WC/TS/AM series) — 1-line addition to §Out of scope + revision-log entry; no Decision# assignment; no amendment block.

Trigger conditions for light-touch:
1. Decision is DEFER (not PROMOTE / shape-lock / drift-fix)
2. Phase-1 operational workaround exists (direct DB write OR adjacent admin UI)
3. Phase-2 trigger criteria expressible in 1-2 sentences
4. Cross-ADR coupling cost > production-volume signal × Phase-1 benefit

When all 4 hold, 1-line §Out of scope note provides architectural visibility without amendment overhead.

Brew-ops handoff candidate at instance #2.

# Production-volume signal as architectural-footprint-determinant — instance #1 NEW

Pattern surfaced via 3-instance spectrum:
- DEPOSIT-006 (0.15/day, 0 successful matches) → DEFER via full amendment (thread #91 PR #63)
- **DEPOSIT-011 (0.4/day, 2 rows) → DEFER via light-touch note** (thread #101 PR #90)
- DEPOSIT-012 (659/day, 3 tiers) → PROMOTE via full amendment (thread #93 PR #76)

Rule emerging: volume signal + cross-ADR coupling cost + operational workaround availability → determines architectural footprint:
- Zero-evidence + DEFER → full amendment (forensic deferral with Phase-2 triggers)
- Rare-but-real + DEFER + high cross-ADR cost → light-touch (1-line note sufficient)
- Heavy-evidence + PROMOTE → full amendment (ratify substrate + impl contract)

Brew-ops handoff candidate at instance #2.

# Decision: DEFER Phase-2

Production-volume (0.4 calls/day; 9+1 audit calls / 22d window) doesn't justify cross-ADR coupling cost across 5 ADRs (§ADR-2 TOTP + §ADR-9 callback + §ADR-10 wallet + §ADR-12 DT + §ADR-13 audit). Phase-1 operational workaround via §ADR-12 direct_transfer admin UI OR DBA direct write.

Phase-2 re-introduction triggers (4 conditions; any one):
1. > 30 refunds/month sustained over rolling 3 months
2. Merchant-facing refund API business driver
3. §ADR-2 TOTP step-up amendment ratified independently
4. §ADR-10 freeze-settle reveals refund-friendly primitives

# Epic-deposit gap-analysis arc closure (4-day writer-architect coordination loop)

Opened 2026-05-10 (DEPOSIT-004 terminal taxonomy surfaced); closed 2026-05-13 (this thread).

Totals:
- 10 architect threads closed (#91/#92/#93/#94/#95/#96/#97/#98/#99/#100/#101)
- 5 AWAITING_THREAD inventory closures (DEPOSIT-001/004/005×2/011)
- 7 PRs (6 amendments + 1 light-touch this) + 2 reply-only closures
- Trace chain 28 → 37 links (longest in repo)

Per writer's framing: "After this, epic-deposit Phase-1 is fully bounded."

# Architecture-decision phase status post-pass

**19 ADRs/amendments `#decision`; 0 live `#provisional`.** Light-touch ratification closes 1 deferred surface without opening new provisional. Trace chain reaches 37 links (continuing longest-in-repo).

# Writer handoff

next-writer adds INDEX entry: `DEPOSIT-011 refund flow — deferred Phase-2 per thread #101 closure 2026-05-13` (same shape as DEPOSIT-006 deferral). No story file authored; no AWAITING_THREAD inventory change.

# Sources

- thread:#101 (writer gap-analysis final candidate; full cross-ADR coupling enumeration)
- dpay MCP audit (writer-verified 2026-05-13): audit_trail 9+1 calls / 22d; ts_deposits 2 refunded rows with structured refund_reason + refunded_at
- mobiz code: controllers/DepositController.go:2524 RefundDeposit + :2879 ResolveRefund; helpers.VerifyTOTPStepUp; app_settings.enable_deposit_refund (OFF default)
- DEPOSIT-006 (thread #91) DEFER precedent + DEPOSIT-012 (thread #93) PROMOTE precedent — DEPOSIT-011 sits between
- Cross-ADR concerns enumerated: §ADR-2/9/10/12/13 + §Bundle TS1-TS5 + §ADR-10 freeze-settle
- Concurrent same-day amendments: §ADR-9 wire contract (thread #95) + §ADR-10 wallet (thread #96) + §ADR-4b mega-amendment (threads #98/#99/#100)

# Commit anchor

`5b6cd86` (light-touch ratification on branch `architect/w1-adr4d-refund-defer-2026-05-13`). PR #90 merged via `fd1143d`.

---
*Added via Oracle Learn*
