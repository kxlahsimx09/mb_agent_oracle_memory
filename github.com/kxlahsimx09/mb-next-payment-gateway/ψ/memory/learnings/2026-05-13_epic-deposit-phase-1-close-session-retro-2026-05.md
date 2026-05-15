---
title: Epic-deposit Phase-1 close — session retro 2026-05-12 → 2026-05-13.
tags: [next-product-writer, repo:mb-next-payment-gateway, next, retro, session-arc, epic-deposit, phase-1-close, writer-discipline, production-audit-corrects-writer-framing, writer-flagged-unratified-surface-instance-7, bundle-fix-in-adjacent-amendment-durable, production-grounded-promotion, production-grounded-sync-default, user-prompted-deep-audit-before-ratify, zero-awaiting-thread-flags, 9-stories-final-state]
created: 2026-05-13
source: docs/requirements/epic-deposit.md + arra threads 91/92/93/94/95/96/97/98/99/100 + PRs 63/64/74/75/76/77/82/83/84/85/86 + docs/adr.md
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Epic-deposit Phase-1 close — session retro 2026-05-12 → 2026-05-13.

Epic-deposit Phase-1 close — session retro 2026-05-12 → 2026-05-13.

## Session arc

2-day intensive writer pass to "make epic-deposit as complete as possible before moving to the next epic". Started with 8 candidate gaps from a current-system endpoint survey; ended with 8 S2-ratified stories, 1 deferred Phase-2 (DEPOSIT-006), and **zero active AWAITING_THREAD flags**.

## Threads closed (10 total over 2 days)

**2026-05-12 (3 threads):**
- #91 — §ADR-4b D6 admin manual re-match → DEFER Phase-2 (zero production matches over 27 days)
- #92 — §ADR-4d D8 verify-slip-now call shape → SYNC default Phase-1 + Phase-2 async triggers (p50 ≈ 600ms grounded)
- #93 — §ADR-9 admin manual resend-callback → PROMOTE Phase-1 (17,797 calls / 27 days grounded)

**2026-05-13 (7 threads, in one mega-amendment arc):**
- #94 — §ADR-4b D2 matcher cascade (PoC bug, no ADR amendment)
- #95 — §ADR-9 wire contract + §Bundle terminal taxonomy → Stripe-style header sig + camelCase ISO8601-Z payload + `failureCode` enum + `paid/rejected/expired/failed` split
- #96 — §ADR-10 wallet schema → `{balance, frozen}` + freeze-settle mutation + snapshot-per-row audit
- #97 — §ADR-4d D5 admin-in-loop (PoC bug, no ADR amendment)
- #98 — DEPOSIT-001 customer-source-bank → §CB1 rename + §CB2 inline + §CB3 V1 source-of-truth
- #99 — §ADR-4b D3 degenerate-FIFO carve-out → §FA1 ratified
- #100 — §ADR-4b status-name canonicalization → §FA2 `review` canonical + §FA3 `pending_review` semantic correction + §FA4 D3 text fix

## Architect amendment PRs merged

- #63 (§ADR-4b D6 defer) · #75 (§ADR-4d D8 sync) · #76 (§ADR-9 admin resend) · #82 (§ADR-10 frozen) · #83 (§ADR-9 wire contract + §Bundle taxonomy) · #85 (§ADR-4b mega CB1-CB3 + FA1-FA4 + §H3-Fix bundle)

## Writer PRs merged

- #64 (DEPOSIT-006 removal) · #74 (DEPOSIT-008 sync handoff) · #77 (DEPOSIT-012 authored) · #84 (DEPOSIT-004 + DEPOSIT-012 wire-contract handoff) · #86 (DEPOSIT-001 + DEPOSIT-005 mega-amendment handoff — pending merge at session close)

## Final story state

| # | Story | Status |
|---|---|---|
| DEPOSIT-001 | QR-based deposit | S2 ratified |
| DEPOSIT-002 | Statement matched + wallet credited | S2 ratified |
| DEPOSIT-003 | Auto-expire | S2 ratified |
| DEPOSIT-004 | Slip upload + admin approve | S2 ratified (terminal taxonomy ratified) |
| DEPOSIT-005 | Multi-candidate review parking | S2 ratified (FIFO carve-out ratified; status-name canonicalized) |
| DEPOSIT-006 | Admin manual re-match | DEFERRED Phase-2 (production-grounded zero-evidence) |
| DEPOSIT-007 | Slip-fraud V1+V2 + two-layer defense | S2 ratified |
| DEPOSIT-008 | Admin verify-slip-now | S2 ratified (sync default Phase-1) |
| DEPOSIT-012 | Manual resend-callback | S2 ratified (promoted from Phase-2 deferral) |

**Zero active AWAITING_THREAD flags.**

## Patterns reached durable threshold this session

| Pattern | Instances | Durable? |
|---|---|---|
| Writer-flagged unratified surface during user-story authoring | #91, #92, #93, #95 (DEPOSIT-004 inline), #98, #99, #100 = **7 instances** | YES — durable rule promoted to W1 workflow doc (AM8 in §ADR-9 amendment 2026-05-12) |
| Bundle-fix-in-adjacent-amendment | §H3-Fix (#93), §Bundle terminal-state (#95), §ADR-4b mega-amendment (#98+#99+#100 in one PR) = **3 instances** | YES — durable threshold reached |

## Patterns NEW this session

| Pattern | Origin | Note |
|---|---|---|
| Production-grounded promotion | #93 (#76) | Mirror of D6 deferral (#91); production-volume signal promotes vs defers |
| Production-grounded sync default | #92 (#75) | Production latency p50 < perceptible threshold → sync UX acceptable |
| Production-audit-corrects-writer-framing | #100 (FA3) | Architect's exhaustive deep-audit corrects writer's sample-based inference (sub-pattern of verify-divergence-via-production-MCP) |
| User-prompted-deep-audit-before-ratify | #100 | User triggered architect's deep-audit via *"ลองเช็ค เคสนี้บน current prod data ให้ละเอียดอีหน่อย"* — forensic discipline for enum/semantic ratification |

## Writer-discipline instances surfaced (self-correction record)

**Three instances of writer-framing errors in 2 days. All same root cause:** plausible-sounding rationale/framing without exhaustive verification of the underlying artifact.

| Instance | Surface | Caught by | What I should have done |
|---|---|---|---|
| **#1 day-bound window** (2026-05-12) | Rationale-vs-algorithm — I wrote "physical settlement / false-positive control" reasons for the BKK day filter without checking the hash composition | User reading the doc + asking "ใน HASH algorithm มันเอาวันที่มา hash ด้วยไม่ใช่หรอ แล้วมันจะชนได้ยังไง" | Read `services/slipMatchHash.go::ComputeSlipMatchHash` before writing the rationale — would have seen `YYYYMMDDHHMM` minute-level in the hash → cross-day collision structurally impossible |
| **#2 call-shape framing** (2026-05-12) | Framing-vs-production-latency — I wrote "sync = 2-30s blocking every call" as the dominant case in the option matrix without checking actual latency distribution | Architect running dpay MCP audit on `/api/v1/deposits/:id/upload-slip` | Run the audit_trail aggregate myself — p50 600ms, 88% < 2s, only 1.6% slow tail → sync UX is fine for the typical case |
| **#3 pending_review semantic** (2026-05-13) | Sample-vs-deep-audit — I framed `pending_review` as "stuck-inbound / unclassified" based on 2 sample rows | Architect's exhaustive deep-audit — 100% of 2,178 rows linked to terminal deposits | Run `GROUP BY status` aggregate on the `matched_request_id` JOIN — would have seen 100% link to terminal-status deposits → race-case admin flip-back surface, not unclassified |

## Distilled writer-discipline rule (new, durable)

**Before framing an option matrix that touches any of {latency, rate, volume, enum semantic, classification, taxonomy, deferral-vs-promotion} — verify the relevant production-data signal on the closest analog with an exhaustive query, not a sample.** Specifically:

- For **latency / rate / volume** questions: run an `aggregate` with avg/p50/p99 grouped by the dimension that matters (caller tier, endpoint, time window). One bad framing example: "sync = blocking every call" — verifying revealed sync is only blocking for the 1.6% slow tail.
- For **enum / classification / semantic** questions: run a `GROUP BY` on the suspect field WITH a JOIN to the related entity, and sample a representative row from each cell. One bad framing example: "pending_review = unclassified" — verifying would have revealed 100% link to terminal-status deposits = race-case, not unclassified.
- For **rationale / "why is the boundary here"** questions: read the actual algorithm or contract that implements the boundary, not just the ADR text. One bad framing example: "day-bound prevents cross-day false positives" — reading the hash would have revealed cross-day is structurally impossible regardless of the day boundary.

The 3-instance threshold is reached today; this is now durable writer discipline.

## Next-session candidates

(Per user direction: "ทำ epic-deposit ครบ ก่อนไป epic ถัดไป" — now complete.)

| Epic | Priority signal | Effort |
|---|---|---|
| **Payout** | Today's amendments (§ADR-9 wire contract, §Bundle taxonomy, §ADR-9 amendment 2026-05-12, §ADR-10 frozen) all have payout-side symmetric ratifications — mirror authoring is high-leverage; substrate is hottest immediately after this session | medium-large |
| Client Self-Topup | §ADR-16 ratified 2026-05-09; smaller surface; admin-only Phase-1; well-bounded epic | small |
| Wallet & Ledger | §ADR-3 + §ADR-10 + §ADR-10 amendment 2026-05-13 (PR #82) freeze-settle — substrate epic, less user-flow-narrative | medium |
| Auth & RBAC | §ADR-2 + §ADR-7 + §ADR-13 + recent amendments — cross-cutting | large |

Writer-side recommendation: **Payout next.** It maximizes leverage from today's amendment wins (payout-side amendments were all ratified inline in the same threads) and the Phase-1 surface naturally pairs with deposit's symmetry.

## Open carry-over (none blocking)

- DEPOSIT-009 / DEPOSIT-010 / DEPOSIT-011 candidates surveyed but not authored; production verification + architect threads required before promotion (DEPOSIT-011 refund especially — no ADR coverage). Optional future passes.
- §H3-Fix architect-side bundle landed in PR #85 — no writer-side updates needed (RBAC prefix-format strings only lived in ADR text, not in any story body).

## arra trace

- Trace chain extended 30 → 36 links across 2 days (longest in repo per architect's tally)
- Phase-1 architectural surface: 19 ADRs/amendments `#decision`; 0 live `#provisional` (preserved throughout the 10-thread closure arc)
- Architect-side learnings filed: `learning_2026-05-12_w1-amendment-ratify-adr-4b-d6-defer-phase-2-thread-91-closed` · `learning_2026-05-12_w1-sub-amendment-ratify-adr-4d-d8-call-shape-sync-default-thread-92-closed` · `learning_2026-05-12_w1-amendment-ratify-adr-9-admin-resend-callback-phase-1-thread-93-closed` · `learning_2026-05-13_w1-amendment-ratify-adr-10-frozen-column-thread-96-closed` (estimated) · `learning_2026-05-13_w1-amendment-ratify-adr-9-wire-contract-bundle-thread-95-closed` (estimated) · `learning_2026-05-13_w1-mega-amendment-ratify-adr-4b-cb1-cb3-fa1-fa4-threads-98-99-100-closed` (estimated)
- Writer-side learnings filed: `learning_2026-05-11_epic-authored-deposit-deposit-006-007-008` · `learning_2026-05-12_writer-handoff-completion-deposit-006-removed-pe` · `learning_2026-05-12_writer-reasoning-error-caught-by-user-plausible-s` · `learning_2026-05-12_writer-reasoning-error-instance-2-framing-vs-pr` · `learning_2026-05-12_deposit-012-authored-admin-manual-resend-callbac` · this entry

## Closing note

The session demonstrated the writer-architect coordination loop at scale: 10 threads, 6 architect amendments, 5 writer PRs, zero AWAITING_THREAD remaining. The discipline gap (sample-vs-exhaustive verification) was caught publicly three times and is now durable. The next epic (likely Payout) inherits a mature substrate + mature writer discipline.

---
*Added via Oracle Learn*
