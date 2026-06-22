---
title: title: L3 verdict — bbot run live-bbot-20lb-1781721739: L1f=test bug, L1g=real g
tags: [money-safety, park-violation, mdr-fanout, counting-artifact, l3-recompute, deposit-matching]
created: 2026-06-17
source: next-investigator L3 recompute — bbot live-bbot-20lb-1781721739
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: L3 verdict — bbot run live-bbot-20lb-1781721739: L1f=test bug, L1g=real g

title: L3 verdict — bbot run live-bbot-20lb-1781721739: L1f=test bug, L1g=real gateway park-violation

next-investigator L3 money-invariant recompute (INDEPENDENT, raw Supabase Postgres via service-role PostgREST, harness self-reports not trusted). Note: the `dpay` MCP is a different/legacy Mongo DB — the gateway run's rows are absent there; truth substrate is the gateway's own Supabase (project sinuwgsqqyqzlpaavimf), tables ts_deposits / wallets_change_logs / callback_queue / bank_statements / wallet.

L1f-deposit-batch (delta=8, expected 2) → COUNTING-ARTIFACT (harness assertion bug, live-tester). NOT a double-credit. Each paid deposit writes 4 wallets_change_logs rows: 1 deposit_credit (client NET) + 2 mdr_distribute (partners) + 1 mdr_residual (owner sink) — the §9 / §ADR-10 MDR fan-out. Per-deposit client credit = EXACTLY 1 (anchor 808.19, d02 828.81, d03 528.32). 2 batch deposits × 4 rows = delta 8. The harness counted raw change-log row delta at 1/deposit; fix = assert on operation=deposit_credit (client-wallet) rows, not raw delta. AUDIT TECHNIQUE: when a "double-credit" alarm fires, count deposit_credit OPERATIONS on the client wallet, not change-log ROWS — MDR fan-out inflates row counts ~4x.

L1g-multi-candidate-park → REAL PARK-VIOLATION (gateway money-safety bug, next-dev). Candidates pkA(486aba72) & pkB(efa79a81) byte-identical on every matchable field (amount 774.0, same pinned SCB bank …001, expected_source_account_no x9876, customer_bank_account_number x9876, name SOMCHAI JAIDEE, KBANK), both pending at scrape. Statement 91f10171 matched BOTH equally yet gateway credited pkA (deposit_credit 760.07 + MDR + deposit.paid callback) and recorded match_candidates=[] (no ambiguity registered) — an apparent oldest-created tiebreak guess. Per DEPOSIT-005/MATCH-002/§II.5 it MUST park (0 credit either, no callback). matcher fix needed: detect ambiguous candidate set and park.

Four invariants: conservation HOLDS to satang (all 4 deposits + payout fees); exactly-one callback HOLDS; balance≥frozen HOLDS (frozen chain unbroken); money-exactly-once HOLDS for uniqueness BUT spirit breached by L1g (760.07 moved on an ambiguous match). 3/4 clean, invariant-4 violated by L1g → run is NOT money-safe-green.

GOTCHA: client-wallet absolute balance shows positive discontinuities (+1552.61, +1076.17) before payout legs — these are harness re-seed top-ups via clean-state.ts setOpeningBalances (direct PATCH /wallet, no change-log). Verify conservation on gateway-authored change-log balance_before→after DELTAS, never the absolute end balance, which the harness PATCHes for setup.

tags: next-investigator, repo:mb-next-payment-gateway, next, verify, v1, live-l3, epic-deposit, p2p-matching, gotcha, DEPOSIT-005, MATCH-002
source: poc/integration/evidence/live/bbot/live-bbot-20lb-1781721739/ + raw Supabase recompute; git-sha 7405a535beadfb3cad13dc937a06368bac211e7e

---
*Added via Oracle Learn*
