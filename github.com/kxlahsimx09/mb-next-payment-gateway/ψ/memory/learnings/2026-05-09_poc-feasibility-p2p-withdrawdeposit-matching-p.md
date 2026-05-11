---
title: poc-feasibility: P2P withdraw/deposit matching — Phase 1 (1:1 only) offloads up 
tags: [poc-implement, repo:mb-next-payment-gateway, next, poc, feasibility, pre-adr, p2p-matching, phase-1-1to1, phase-2-deferred, measurement-only, greenfield, finance-input-needed, opt-in-promotion-driven, scope-decision-2026-05-07, pr:41]
created: 2026-05-09
source: poc/p2p-matching/{README.md, scripts/match_1to1.py, scripts/breakdown_1to1.py, scripts/match.py, web/matcher.js, data/*.json} @ 401125c (PR #41 cherry-pick of agents/5-20260507-134931); scope decision 2026-05-07 GMT+7 by user
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-feasibility: P2P withdraw/deposit matching — Phase 1 (1:1 only) offloads up 

poc-feasibility: P2P withdraw/deposit matching — Phase 1 (1:1 only) offloads up to 39.4% withdraw rail volume / 63.2% withdraw count from system bank (upper bound, 100% opt-in).

# Concept (greenfield, no ADR yet, not in #current)

When a customer requests a withdrawal, gateway holds it for up to 2h SLA window. Within that window, if another customer wants to deposit the same exact amount, gateway routes the depositor to transfer directly to the withdrawer's destination bank account (manual transfer, no QR). Depositor confirms with slip, Thunder verifies authenticity + destination match, and both legs settle without touching the system bank. Withdraw-side opt-in is transparent (same amount, same destination); opt-in is deposit-side only, driven by promotion (depositor chooses "P2P route" for promo bonus vs. standard QR-deposit no bonus).

# Headline result (upper bound, 100% deposit-side opt-in)

| Metric | Value |
|---|---|
| % withdraw count offloaded from bankbot | **63.2%** |
| % withdraw amount offloaded from system bank | **39.4%** |
| % deposit count offloaded from system bank | 16.0% |
| % deposit amount offloaded from system bank | 29.2% |

Inputs: ts_payouts.status="completed" (96,088 records) × ts_deposits.status="paid" (378,699 records) over 2026-03-30 → 2026-05-07 (~38 days), match-field = amount (gross). Strategy: greedy by payout time, deposit consumed once, cross-merchant pool, exact-amount equality, 2h window.

# Scope decision (2026-05-07, by user)

Phase 1 ships 1:1 only (one withdraw : one deposit). 1:N (N≥2) deferred to Phase 2 — operational complexity (multiple depositors per withdraw, partial-fill failure paths) not justified for Phase 1 launch.

# Match-rate by withdraw amount bucket

Exact-amount catches small/medium very well, large amounts miss because exact-amount liquidity is sparse:
- 100–499 THB → **83.1% count** matched
- 500–999 → 75.1% / 1k–2k → 65.4% / 2k–5k → 54.2% / 5k–10k → 40.6%
- ≥10,000 THB → **32.6% count** (only 27.5% amount)
- Of the 36.8% withdraws that 1:1 misses, those misses hold **60.6% of total withdraw volume** — large-amount tilt is the gap that Phase 2 (1:2) would close.

# Phase 2 preview (1:1 + 1:2, deferred)

77.0% count / **58.6% amount** offloaded — Δ vs Phase 1 = +13.8pp count, **+19.2pp amount**. Phase 2 is amount-heavy (each Phase-2 count point carries ~1.4× rail volume) because 1:2 rescues high-amount withdraws (4k matches two 2k depositors). Phase 2 cost not modeled: partial-fill recovery (depositor #2 fails to send slip in time → withdraw stuck with depositor #1 already committed → manual rollback or top-up from system bank). Phase 1 has no such failure mode.

# Adoption sensitivity (deposit-side opt-in, linear approximation)

- 100% (upper bound) → 63.2% count / 39.4% amount
- 70% → ~44% count / ~28% amount
- 50% → ~32% count / ~20% amount
- 30% → ~19% count / ~12% amount

True response is sub-linear because liquidity density per window varies — use as planning floor, not exact estimate.

# Promotion break-even

Phase 1 routes 120.97 M THB deposit volume through P2P (= 120.97 M THB withdraw amount offloaded) over 38 days. At promo-rate X%, 38-day promo cost = {0.3% → 363K, 0.5% → 605K, 1.0% → 1.21M}; per-month run rate = {286K, 477K, 954K}. Phase 1 profitable iff rail-cost per baht through system bank ≥ promo rate (adjusted for ops savings — bankbot processing, settlement risk, float cost). Finance must confirm effective rail cost % to set the promo ceiling.

# Caveats — why Phase 1 numbers are still an upper bound

1. 100% depositor opt-in assumed. See adoption sensitivity table above.
2. Greedy by payout time. Optimal min-cost bipartite matching may add 1–3pp; not load-bearing for feasibility.
3. Slip verification = perfect. Thunder false-negatives or delays shrink the effective window.
4. Same-amount collision. Top withdraw amounts (300, 500, 1000) cluster heavily. Greedy "first-in" may starve some payouts; needs a fairness policy in real implementation.
5. No daily bank-account caps modeled. Real coverage drops if a withdrawer's destination account hits its daily-credit ceiling.
6. Match on amount (gross). If deposit must absorb withdraw fee, switching to final_amount shifts a few % out of "exact" match.
7. Slip-OCR timing skew. payment_details.transaction_date vs createdAt introduces seconds-level skew — far smaller than 2h window. Insensitive.

# Edge cases the ADR must answer (5 open questions)

- Fairness on popular amounts — FIFO of withdraws on 300/500/1000? Or priority for those near SLA expiry?
- Fallback timeout — depositor doesn't submit slip in time → release withdraw back to bankbot how, without breaking the 2h SLA?
- Slip-verification failure — Thunder rejects (destination mismatch / fake slip). Who eats the loss? Charge depositor again? Refund and retry into normal flow?
- Big-amount strategy — withdraws ≥10K only match 32.6%. Skip P2P entirely for these and route directly to bankbot? Or hold and try Phase 2 1:2 later?
- Promo-fraud surface — depositor tries to game promo (self-deposits across accounts). KYC binding + per-customer rate limit needed.

# Status & anchoring

- No existing ADR — concept does not exist in §ADR-4 lane (which covers system-bank rail dispatch + statement matching) nor any other Phase-1 ADR (19 #decision ADRs as of 2026-05-08 session close).
- Not in #current (mobiz-payment-gateway) — greenfield. No prior-art equivalent. Closest neighbor in #current is selectBank() deposit/payout pool routing (always-via-system-bank), not P2P.
- PoC was orphan before PR #41 — produced 2026-05-07 in agents/5-20260507-134931 worktree, session restarted before commit; preserved via cherry-pick to poc/p2p-matching-feasibility branch (commit 401125c, PR #41 open at github.com/kxlahsimx09/mb-next-payment-gateway/pull/41).
- Architecture-side gap — when/if architect picks this up, candidates: (a) new ADR (e.g., §ADR-17 P2P Matching) sibling to §ADR-4 lane, (b) amendment to §ADR-4 deposit lane to add a P2P branch before system-bank fallback. Phase 2 (1:2) should be deferred to a separate ADR — partial-fill recovery is a different beast.

# Recommendation

Ship Phase 1 (1:1 only) first. Headline answer to "can P2P matching reduce system-bank load?" is yes — Phase 1 offloads up to 39% of withdraw rail volume (theoretical upper bound), with a planning floor of ~20–28% once 50–70% depositor opt-in is folded in. That alone justifies the engineering investment. Three numbers from Finance unlock ADR ratification: (1) effective rail cost per baht through system bank, (2) target depositor opt-in rate at promo X% (small A/B test recommended), (3) per-merchant or per-customer KYC binding policy for promo fraud prevention. Promote Phase 2 (add 1:2) after Phase 1 ops stabilize — amount-impact (+19.2pp) is roughly 1.4× count-impact because 1:2 rescues high-amount withdraws.

# Reproducibility

cd poc/p2p-matching && python3 scripts/match_1to1.py (~0.3s, Phase 1 numbers) + python3 scripts/breakdown_1to1.py (per-amount-bucket); web simulator at web/index.html (browser-side matcher, all knobs adjustable: window hours, max match size, tolerance, strategy, opt-in %, amount filter, seed; timeline + histograms + inspector). Headless: node web/smoke.mjs. Source data in data/{payouts,deposits}.json extracted via mcp__dpay__aggregate on 2026-05-07.

---
*Added via Oracle Learn*
