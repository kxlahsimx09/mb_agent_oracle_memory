---
title: p2p-hub Phase B per-case audit (thread #232, parent campaign #231, 2026-05-26) —
tags: [system-architect, repo:cross, next, p2p-hub, phase-b, edge-case-catalogue, designed-vs-built, feasibility-audit, thread-232, campaign-231, non-custodial, enforcement-lever, admin-debit-unbuilt, needs-legal, regulatory-classification, q7, disintermediation, exact-amount-leakage, provider-wallet, settle-p2p-match, phase-e-ratification-pending-206, p-004-correction-q6, architecture, trade-off]
created: 2026-05-26
source: docs/design/p2p-hub-design-exploration.md @ origin/main 6f7517e (kxlahsimx09/p2p-hub); thread #232 msg 1028; deployed migrations 001-005 verified
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# p2p-hub Phase B per-case audit (thread #232, parent campaign #231, 2026-05-26) —

p2p-hub Phase B per-case audit (thread #232, parent campaign #231, 2026-05-26) — verdict-state snapshot.

Walked all **72** Phase B sub-items (B1–B12; the dispatch's "~60" undercounts) in docs/design/p2p-hub-design-exploration.md, 2-axis per-case verdict (feasibility × handling). Grounded on origin/main @6f7517e + verified deployed SQL (NOT §E0's stale @19a7be9 narrative). Full matrix in thread #232 msg 1028.

THE LOAD-BEARING DESIGNED-VS-BUILT FINDING: the p2p-hub protocol is **~spec-only** today. Of 72 cases only ~4 are PREV-BUILT:
- B4.5 topup CAS (mobiz-port `status=0 AND processed=false`, migration 005)
- B4.6 `CHECK(balance>=reserved)` + `CHECK(balance>=0)` (migration 002) — strongest built prevention
- B6.6 hub-side `match_id` correlation (PI-4, wired into change_logs/outbound/settle)
- partial: B6.1/B6.3/B12.2/B12.5 (settle-time race-guard `WHERE reserved>=M` + durable append-only storage, migration 004)

Everything else = **PREV-SPEC (CAN-OCCUR-TODAY, prevented-when-built)** or CAN-OCCUR (residual/external) or UNCERTAIN. C13 says "covered" but the covering mechanism is unbuilt for the ENTIRE match lifecycle, §C8 thunder verification, §C11 dispute, §C4 provider state machine, §C3 registration, and wire invariants PI-2/PI-7/PI-3.

Deployed substrate = migrations 001–005 (§D settle-half) + admin-approve-topup EF only. Producers exist for only **3 of 11** `provider_wallet_operation` enum values (`topup_approved`, `commit_settle_debit`, `commit_settle_credit`). Phase E (formation/reserve/release 1A) is RATIFICATION_PENDING:206 and entirely unbuilt (no migrations 006–009; no `pool_items`; `matches` stub enum lacks POOLED/ACCEPTED/INSTRUCTED/SENT).

CRITICAL ENFORCEMENT GAP: the §C11 non-custodial enforcement levers that B7.4 / B1.7 / B8.x all lean on are design-only — **`admin_debit` (credit-penalty "teeth") has NO producer; `providers` has no `status` column (no suspension); reputation has no substrate.** §D8's celebrated "teeth" are not installed.

NEEDS-LEGAL: B11.4 / Q7 + B8.3 regulatory classification — and §D1 SHARPENED it (hub is now B2B-custodial for settlement float, so "coordinator that holds no money" no longer applies). Most urgent deferred decision.

NEEDS-USER (genuinely open, not just unbuilt): B7.5 liability-matrix CONTENTS (fault→party rows unspecified); B8.7 Sybil-vetting policy. Plus ratified accepted-residuals to re-confirm: Q5 non-custodial, CQ6 disintermediation, exact-amount leakage (B8.9/B11.2/B11.3), B10.4 liquidity imbalance.

P-004 CORRECTION to the dispatch: B9.4/Q6 is NOT open — the doc resolves Q6 = "1:N in scope" (CQ5/§C9/Appendix). Only impl-timing is open (§E 1A is 1:1-only). B10.1/B10.5 hub-downtime/SPOF depend on the gateway-side adapter that lives in `next`, not this repo — external dependency, unbuilt.

B7 (dispute) + B8 (fraud) under-fit the per-case row form (both hinge on the unbuilt C8+C11+C3 triad + structural residuals); offered a focused deep-dive paragraph on either.

---
*Added via Oracle Learn*
