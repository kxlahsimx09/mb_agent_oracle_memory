---
title: internal-completeness re-review of mb-next docs/requirements/ post-#228/#234 (ca
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, completeness-review, gap-review, internal-completeness, campaign-239, thread-240, adr-8, fair-router, a2, bot-dispatch, settlement, s2-ratified]
created: 2026-05-27
source: docs/requirements/@12b9e1c vs docs/adr.md@12b9e1c; thread #240 / campaign #239
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# internal-completeness re-review of mb-next docs/requirements/ post-#228/#234 (ca

internal-completeness re-review of mb-next docs/requirements/ post-#228/#234 (campaign #239 sub-A, thread #240) — verdict: surface is substantially COMPLETE against ratified ADRs at HEAD 12b9e1c. The #225 P0/P1 net-new list + P2 tail are closed. Only ONE genuine remaining gap.

VERIFIED-COMPLETE:
- All 7 net-new #228 epics internally complete (source-flows, auth-rbac, callback-delivery, admin-audit, fleet-control, monitoring, client-api): every story has trust label + As-a/I-want/so-that + user-journey (mermaid where multi-actor) + Given/When/Then ACs + Sources block. Zero live [AWAITING_THREAD]/[RATIFICATION_PENDING] anchors (the only AWAITING mentions are narrative "Closes the prior [AWAITING…]" records in epic-deposit Sources blocks). Terminal-state taxonomy present where relevant (CALLBACK-004 deposit 4-state / payout 3-state asymmetry).
- No epic-less ratified ADR. ADR-2→16 + amendments all map to an epic; ADR-1/3/5/6 are substrate/infra (fold into wallet-ledger/deposit/bot-dispatch, no standalone product epic by design). P2 tail closed: Idempotency §ADR-11 → CLIENT-001; OTP/Trust → AUTH-002/007 + bot-OTP routed to cross-repo.md.
- README + INDEX current: all 7 new epics listed; MDR + OTP&Trust folded rows with cross-refs; AUTH-007 shown ratified S2. INDEX has all 13 epic sections.
- #234 amendments all propagated: §ADR-12 settlement M1/M2 → SETTLE-001/002; §ADR-2 step-up → AUTH-007 (S4→S2); §ADR-9 preconfigured-callback #223 → CALLBACK-003; §ADR-11 A3 → CLIENT-002/AUTH-006; §ADR-4a A1 → PAYOUT-010; §ADR-4c A4 → DEPOSIT-003/004.

REMAINING (the one finding):
- R1 (low severity, the only ratified-amendment surface NOT propagated): §ADR-8 §Amendment 2026-05-26 (A2, fair-router per-bank withdrawal-amount-range eligibility filter, campaign #229) is ratified #decision but epic-bot-dispatch.md was never touched after its 2026-05-25 authoring (commit 7519884). BOT-001 AC#2 (line 59) still enumerates 8 eligibility filters — missing the ratified 9th (withdrawal_min_amount/max). And epic-source-flows.md PULLOUT-002 edge (line 255) still calls A2 "being ratified separately … cross-flagged to architect sub-thread #229" — stale. Fix = 1-line BOT-001 AC update + supersede PULLOUT-002 phrasing. (ADR text says A2 has "no product surface", which is why the campaign skipped it — but BOT-001 enumerates filters as a liftable AC, so it is an accuracy/freshness gap.)

OPTIONAL/MINOR:
- R2: SETTLE-001 edge carries an open PRODUCT-scope question "[open question: whether partner-initiated settlement is Phase-1 — pending architect confirmation]" (settlements are entity_type client 2,832 / partner 140). Unlike the other [open question] markers (which defer impl detail correctly), this defers a scope decision — worth a 1-line architect confirm.
- Pre-existing systemic nit (NOT a #228 regression): glossary heading "bank-bot (the fleet)" slugs to #bank-bot-the-fleet, but 7 files (incl old epic-deposit/payout/statement-matching) link glossary.md#bank-bot — fragment lands at glossary top, not the definition. Affects all epics uniformly; flag for a future cleanup pass, out of scope for this review.

---
*Added via Oracle Learn*
