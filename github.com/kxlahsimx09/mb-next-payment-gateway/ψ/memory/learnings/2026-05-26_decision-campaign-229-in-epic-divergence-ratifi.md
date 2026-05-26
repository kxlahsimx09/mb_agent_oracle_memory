---
title: decision — Campaign #229 in-epic divergence ratification: A2 + A3 ratified ADD (
tags: [system-architect, repo:mb-next-payment-gateway, next, decision, adr, fair-router, withdrawal-queue, api-design, rate-limit, reliability, campaign-229]
created: 2026-05-26
source: docs/adr.md §ADR-8 §Amendment 2026-05-26 (A2) + §ADR-11 §Amendment 2026-05-26 (A3); thread #229 / campaign #228
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# decision — Campaign #229 in-epic divergence ratification: A2 + A3 ratified ADD (

decision — Campaign #229 in-epic divergence ratification: A2 + A3 ratified ADD (architect authority).

Sub-task 1 of parent campaign #228 (orchestrator), resolving 2 of the 4 in-epic divergences pg-writer found in the #current-lens gap analysis (campaign #225, thread #227 msg 1017). Both are within architect authority (no product/cost/compliance trade-off) and are ratified as `#decision` §ADR amendments dated 2026-05-26. The other two (A1, A4) are product/money-safety material and were escalated to the user — see companion provisional learning.

## A2 — Fair-router per-bank withdrawal amount-range eligibility filter (§ADR-8 §Amendment 2026-05-26)
VERDICT: ADD. Class = port-fidelity restoration (not a new decision surface).
- §ADR-8 Decision-2 promised "port findBestBankForItem LRU verbatim" (ratified thread #46) but its enumerated 8-filter stack (method / heartbeat / idle / balance / MaximumOutstandingWithdrawal / MaxDailyTransactions / tier-cap / pool-membership) DROPPED the per-bank withdrawal amount-range band that current actually applies. BOT-001 AC (epic-bot-dispatch.md:59) mirrors the same 8 and omits it.
- AF1: amount-range becomes the 9th eligibility filter — skip a candidate bank_account when item.amount < bank.withdrawal_min_amount OR > withdrawal_max_amount (0 = no limit that side); applies to ALL withdrawal source_types (payout/settlement/direct_transfer/pullout); distinct from `balance` (sufficient funds) and `MaximumOutstandingWithdrawal` (in-flight cap) — it is a per-item amount band gate before LRU least-count selection.
- AF2: consequence preserved from current — an item below every active bank's min (or above every max) is unroutable, stays pending_routing until a bank is reconfigured or PAYOUT-008 auto-cancel / maintenance backstop fires.
- P-004 evidence: scheduler/withdrawal_dispatcher.go:499-525@ae6f523 + services/bankRotation.go:61-72@ae6f523 (learning 2026-04-30_withdrawaldispatcher-honors-per-bank-withdrawalmi); original port evidence 2026-04-24_current-system-prior-art-findbestbankforitem-u.
- Writer handoff: BOT-001 AC gains a 9th filter + an edge case mirroring AF2.

## A3 — Per-client request-rate limit on client-facing creates (§ADR-11 §Amendment 2026-05-26)
VERDICT: ADD as a ratified client-API-contract NFR; mechanism + exact values impl-level. Class = parity-preservation of an existing production safeguard (not a new money-flow/cost choice).
- Current applies per-client, per-scope (deposit vs payout), dual-window (per-min + per-day) caps on the two client-facing creates; next-system DEPOSIT-001/PAYOUT-001 ACs cover auth + Idempotency-Key + amount-range + callback-endpoint but NO request-rate cap. §ADR-11 is replay-dedup (idempotency), orthogonal to rate-limiting.
- RL1: rate-limiting is realized at the edge/auth layer (alongside §ADR-7 API-key middleware + §ADR-11 idempotency middleware), before any payment logic / atomic RPC; no PL/pgSQL surface.
- RL2: per-client/per-scope/dual-window; current caps (deposit ~1000/min+600k/day, payout ~1000/min+300k/day) cited as Phase-1 BASELINE, not ratified literals.
- RL3: fail-open (transient counter-store outage must not block legitimate payments); mechanism diverges from current (mobiz Redis; next removed Redis per §ADR-1) — counter substrate is impl choice; only fail-open + per-client/per-scope/dual-window shape is ratified.
- RL4 out of scope (impl): exact values, counter substrate, over-limit HTTP status/body (likely 429), bucket algorithm, per-client overrides. Admin endpoints exempt (per §ADR-13/§ADR-12 D1).
- Consistent with §ADR-4d Decision #8 sub-amendment ATC2 "rate-limit stays impl-level."
- P-004 evidence: helpers/ratelimit.go:36-242@33664cd (#443) + DepositRequestController.go:161-167@c7b2232 + PayoutRequestController.go:170-176@c7b2232 (#444) — learnings 2026-05-16_per-client-api-rate-limit-caps-at-mobiz-head-c7b + 2026-05-16_per-client-api-rate-limiter-helpersratelimitgo.
- Writer handoff: record as NFR in the planned Client-API/Auth epic (campaign #228 noted A3 may fold there); else a one-line NFR pointer on DEPOSIT-001 + PAYOUT-001.

Verified against source per P-004: next-system side by reading the live docs/adr.md + docs/requirements/ at b8facce; current side by code-grounded current-system vault learnings. Links: [[feedback_poc_load_bearing_realism]]. Companion provisional: A1+A4 escalation.

---
*Added via Oracle Learn*
