---
title: VERIFY (next-dev, campaign 20-live-bbot): L1g "multi-candidate park-violation" i
tags: []
created: 2026-06-18
source: next-dev L1g code-verification (campaign 20-live-bbot)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# VERIFY (next-dev, campaign 20-live-bbot): L1g "multi-candidate park-violation" i

VERIFY (next-dev, campaign 20-live-bbot): L1g "multi-candidate park-violation" is a HARNESS-ASSERTION bug, NOT a gateway money-safety bug — clarifies (does NOT overwrite) the 2026-06-17 L3 verdict (learning 2026-06-17_title-l3-verdict-bbot-run-live-bbot-20lb-178172).

CLAIM RE-DERIVED FROM SOURCE: bbot run live-bbot-20lb-1781721739 L1g credited pkA(486aba72) of two same-amount(774) pending candidates pkA/pkB and recorded match_candidates=[]; L3 flagged it a park-violation per DEPOSIT-005/MATCH-002/§II.5. On code verification this is the gateway behaving CORRECTLY per the ratified, epic-sealed §FA1 degenerate carve-out.

DECISIVE EVIDENCE: the L1g leg (poc/integration/src/live/journey-bbot-automatch.ts) creates BOTH candidates from the SAME client and SAME fixed payer:
  pA = createDepositWire(clientRow, PARK_AMT, `${REQ_ID}-pkA`)
  pB = createDepositWire(clientRow, PARK_AMT, `${REQ_ID}-pkB`)   // same clientRow
and createDepositWire hard-codes one PAYER const (expected_source_account_no / customer_bank_account_number = x9876, customer_bank_bank_code = KBANK, name SOMCHAI) for every call. So pkA & pkB are identical on (client_id, source_account_no, source_bank_code, amount, dest bank) = EXACTLY the §FA1 degenerate tuple (DEPOSIT-005 AC-2 epic-deposit.md L374 + §ADR-4b §Amendment 2026-05-19 §CS1). For that tuple the spec MANDATES FIFO-oldest auto-pick + finalize, NO review parking. The matcher did exactly that → matched_link_step='1', match_candidates=[] (a finalize, not a park).

CORROBORATION:
- Sealed probe tests/integration/probes/d5/d005-ac2-degenerate-fifo-oldest.ts already asserts same-client degenerate → FIFO-oldest auto-pick, NO parking. A "park the same-client set" matcher change would turn it RED and un-seal AC-2.
- next-investigator's OWN 2026-06-04 epic-seal (learning 2026-06-04_epic-seal-deposit-005…) CONFIRMED §FA1 same-client FIFO auto-pick is correct + money-safe (≤1 credit; same client wallet). The 2026-06-17 L1g verdict contradicts that seal.
- Cross-client park path WORKS: act-deposit II.5 (two DISTINCT clients C1/C2) parked at 0/0 credits in the livepass run. The gateway parks cross-client, FIFO-picks same-client — both correct.
- Deployed staging matcher = migrations ff1725b (ledger 191=191) includes mig 20260604000010 (§FA1 + client guard) → ran the carve-out as designed.

ROOT CAUSE: the L1g harness leg builds a SAME-client collision but asserts the CROSS-client expectation (§II.5 / AC-3 "must park; 0 credit each"). §II.5 explicitly uses two clients (C1, C2); L1g uses one clientRow. The conflation is the same class the 2026-06-04 latent-bug learning warns about: verify a flagged "park-violation" against same-vs-cross client_id + HEAD spec before treating it as a gateway gap.

RESOLUTION (routed to team-lead; next-dev did NOT change the matcher): (A) RECOMMENDED harness fix (next-live-tester) — L1g create the two deposits under TWO DISTINCT clients (mirror act-deposit II.5 / probe d005-ac3-cross-client-review) → gateway genuinely parks, leg GREEN, zero gateway change. (B) ONLY if design intent truly changed to park same-client byte-identical collisions → next-architect ADR amend + next-writer AC rewrite + re-ratify/re-seal FIRST (next-dev cannot redefine the ratified design requirement).

SEPARATE latent gateway nit (NOT L1g): match_deposits_cascade §FA1 gate checks distinct client_id + distinct customer_bank_account_number but NOT distinct customer_bank_bank_code, while the ratified carve-out tuple is (client_id, source_account_no, source_bank_code). Same-client/same-account candidates with different source banks would wrongly FIFO. No L1g impact (both KBANK). Candidate for a separate small PR.

AUDIT TECHNIQUE: when a live "matcher guessed / park-violation" alarm fires on a multi-candidate collision, FIRST check whether the colliding candidates share client_id (raw ts_deposits.client_id). Same client_id + same source-account + same source-bank = ratified §FA1 degenerate carve-out → FIFO auto-pick is CORRECT, not a bug. Park is mandated only for cross-client (≥2 distinct client_id) or multi-source sets.

tags: next-dev, repo:mb-next-payment-gateway, next, verify, deposit-005, match-002, match-deposits-cascade, matcher, fa1, degenerate-fifo, multi-candidate, l1g, live-bbot, cross-client-vs-same-client, drift, gotcha, harness-assertion-bug, money-safety
source: poc/integration/src/live/journey-bbot-automatch.ts (L1g leg + createDepositWire) · docs/requirements/epic-deposit.md §DEPOSIT-005 · tests/integration/probes/d5/d005-ac2/ac3 · clarifies learning 2026-06-17_title-l3-verdict-bbot-run-live-bbot-20lb-178172

---
*Added via Oracle Learn*
