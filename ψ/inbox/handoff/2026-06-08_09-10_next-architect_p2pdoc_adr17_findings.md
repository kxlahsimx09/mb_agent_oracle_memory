# next-architect — campaign p2pdoc — §ADR-17 P2P Matching authored (`#provisional`)

**Deliverable:** §ADR-17 "P2P Withdraw/Deposit Matching — Phase 1 (1:1 only)" appended to `docs/adr.md` in number order (between §ADR-16 and §ADR-18). Committed to branch `campaign/p2pdoc` (commit 333cdac). PR #346 base `main`, NOT merged (charter §9 — owner merges). Modeled on the §ADR-18/20/21 house style.

## Status: `#provisional` `[RATIFICATION_PENDING:p2pdoc]` — NOT self-ratified. Owner GO pending.

## Grounding (PoC PR #41 @ 401125c; learning 2026-05-09_poc-feasibility-p2p-withdrawdeposit-matching; numbers cited per claim)
- Phase-1 1:1 offloads up to **39.4% withdraw amount / 63.2% withdraw count** from the system bank (100%-opt-in upper bound); **~20–28% amount** at a realistic 50–70% opt-in floor.
- Match-by-bucket: 100–499→83.1% · 500–999→75.1% · 1k–2k→65.4% · 2k–5k→54.2% · 5k–10k→40.6% · ≥10K→32.6% count/27.5% amount. The 36.8% 1:1 misses hold 60.6% of withdraw volume (the Phase-2 gap).
- Promo break-even: 120.97M THB over 38d; monthly run-rate 286K/477K/954K at 0.3/0.5/1.0%.

## Provisional sub-decisions
**Matching contract MC1–MC5:** MC1 NEW ADR, SIBLING to §ADR-4 lane (NOT an §ADR-4d amendment — orthogonal per the §ADR-4d D1 H1 note ~line 1177; P2P is a destination/matching concern, not an actor concern). MC2 Phase-1 1:1 only (1:N → separate future ADR). MC3 exact-amount(gross)/2h SLA/greedy-by-payout-time/deposit-consumed-once/cross-merchant. MC4 deposit-side promo opt-in only; withdraw side transparent. MC5 depositor manual-transfers direct to withdrawer's account (no QR) + slip; Thunder verifies authenticity + NEW destination-match predicate; both legs settle OFF the system bank.

**The 5 PoC-flagged edge resolutions Q1–Q5 (architect lean):**
- Q1 Fairness (300/500/1000 cluster) → EDF-with-FIFO-tiebreak (per-exact-amount FIFO; SLA danger-band escalates to earliest-deadline-first).
- Q2 Fallback timeout → release-to-rail; **invariant P2P-window ⊂ SLA-window** (lean ≤90m P2P / ≥30m rail headroom; ~15m slip sub-deadline); pg_cron release-sweep clears matched_withdraw_id + re-enqueues into withdrawal_queue; idempotent + money-safe (never debited) → can never break the 2h SLA.
- Q3 Verify-failure → the **system bank never eats the loss** (money never flowed through it); withdraw falls back to rail (never debited, still paid within SLA); deposit not credited; destination-mismatch = depositor's own transfer error (zero gateway loss, re-route to QR); forged slip = existing §ADR-4d V1/V2 + V1.5 verbatim; refund-and-retry N/A (gateway custodies no funds).
- Q4 ≥10K (matches 32.6%) → SKIP P2P, route straight to bank-bot via config p2p_max_amount (default 10K, owner-tunable); do NOT hold (nothing to hold for — Phase-2 1:2 is a separate ADR). The threshold is the Phase-2 hand-off seam.
- Q5 Promo-fraud → KYC binding + per-KYC rate-limit (N/day, M/month, Finance-set) + self-match exclusion (no routing to same KYC identity/beneficiary) + conversion-gated bonus (pays only on a Thunder-verified, destination-matched, SETTLED leg).

## Open for owner (NOT resolved — the GO gate + Finance)
- OQ1 the GO (flip MC1–MC5 + Q1–Q5 → #decision).
- OQ2 (Finance, load-bearing): (1) effective system-bank rail-cost/baht (sets promo ceiling); (2) target depositor opt-in @ promo X% (A/B test); (3) per-customer/merchant KYC-binding policy (sets Q5 limits).
- OQ3 timer split; OQ4 10K threshold; OQ5 fairness policy.

## Verify-against-HEAD
ADR-17 confirmed unwritten before authoring (per §ADR-18 + §ADR-19 verify-against-HEAD blocks). Orthogonality to §ADR-4d H1 actor model confirmed (~line 1177). Took the reserved number.

## Downstream
- next-writer authors `docs/requirements/epic-p2p-matching.md` anchored on this ADR (stories stay S3/provisional until owner GO).
- next-pm tracks the ratification gate (OQ1 + OQ2).
- Phase-2 1:N = separate future ADR (deferred, not designed here).
- Out-of-scope/impl-pass: matched_withdraw_id schema, matcher RPC/EF, depositor-claim UI, Thunder destination-match API, promo-bonus ledger entry, pg_cron release-sweep cadence, daily-account-cap predicate, §ADR-15 P2P alert catalog add.