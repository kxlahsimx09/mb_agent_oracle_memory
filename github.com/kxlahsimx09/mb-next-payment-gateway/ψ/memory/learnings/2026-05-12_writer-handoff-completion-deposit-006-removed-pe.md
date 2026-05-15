---
title: writer handoff completion — DEPOSIT-006 removed per §ADR-4b §Amendment 2026-05-1
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic-deposit, deposit-006-removed, deferred-phase-2, adr-4b-amendment-2026-05-12, thread-91-closed, production-verification-second-order, functionally-redundant-endpoint, writer-handoff-completion, supersede]
created: 2026-05-12
source: docs/requirements/epic-deposit.md (DEPOSIT-006 removal pass) + docs/adr.md §ADR-4b §Amendment 2026-05-12 (architect ratify, PR #63 d4ecc14, thread #91)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# writer handoff completion — DEPOSIT-006 removed per §ADR-4b §Amendment 2026-05-1

writer handoff completion — DEPOSIT-006 removed per §ADR-4b §Amendment 2026-05-12 (thread #91 closed).

## What architect ratified

PR #63 `d4ecc14` (merged 2026-05-12 02:33 UTC) — §ADR-4b §Amendment 2026-05-12 + AM1-AM4 + Production evidence appended; Decision #6 deferred to Phase-2 entirely. Driver: dpay MCP audit found `POST /api/v1/bank-statements/match` produced **zero successful matches** in production (51 calls / 27 days; 47 = 403; 4 = 200 but 0 bank_statements.updated_at changes within ±15min). The 3,587 late-match cases in the same window flowed via deposit-driven match path (§ADR-4b D2 cascade), not via admin manual re-match — endpoint is functionally redundant.

## Writer pass completed

`docs/requirements/epic-deposit.md`:
- Story-shape table row for DEPOSIT-006 removed
- DEPOSIT-006 body (heading + As-a + user journey + ACs + edge cases + Sources) removed entirely
- AWAITING_THREAD:#91 flag removed (resolved by amendment)
- Epic-owner footer updated
- Revision-log entry added citing amendment + thread #91 + PR #63

`docs/requirements/INDEX.md`:
- DEPOSIT-006 line removed

Net: epic-deposit.md 488 → 440 lines (-48); INDEX.md 20 → 19.

## Pattern surfaced (worth capturing)

**"Shape disagreement" was the wrong question.** Writer's verification pass on 2026-05-11 (PR #61, closed-superseded) flagged a per-statement-vs-batch shape mismatch between ADR D6 text and current code. That framing accepted the endpoint's existence as given. Architect's deeper dpay audit on 2026-05-12 asked a different question — "does this endpoint actually produce matches in production?" — and the answer was no. **Production verification beats text-vs-code verification.** When the source ADR text matches one shape and current code matches another, the next question is "is either shape doing useful work?" — not "which shape do we port?".

This complements the prior fabrication-detection methodology (verify-divergence-via-production-MCP — instance #4 noted by architect in this pass): it adds a *second-order* check — even when the endpoint exists and is "used", check whether the use produces the claimed effect.

## arra trace

- thread #91 closed 2026-05-12 02:33 UTC
- architect learning: `learning_2026-05-12_w1-amendment-ratify-adr-4b-d6-defer-phase-2-thread-91-closed`
- writer PR #61 closed-superseded 2026-05-12 (no merge)
- writer PR pending: `writer/deposit-006-remove-deferred-to-phase-2-2026-05-12` branch

## Phase-1 epic-deposit state post-pass

7 stories remain at S2 ratified: 001 / 002 / 003 / 004 / 005 / 007 / 008. DEPOSIT-006 deferred to Phase-2 with explicit re-introduction triggers (volume signal / correctness signal / concrete business driver) ratified in §ADR-4b AM3.

---
*Added via Oracle Learn*
