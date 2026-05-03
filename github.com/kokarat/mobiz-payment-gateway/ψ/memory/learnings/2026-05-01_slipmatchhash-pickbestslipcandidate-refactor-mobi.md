---
title: SlipMatchHash pickBestSlipCandidate refactor (mobiz #366, 78a2dc3, 2026-05-02). 
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, slip-fraud, v1-hash, false-positive-fix, scoring-pattern]
created: 2026-05-01
source: services/slipMatchHash.go:208-363@78a2dc3
project: github.com/kokarat/mobiz-payment-gateway
---

# SlipMatchHash pickBestSlipCandidate refactor (mobiz #366, 78a2dc3, 2026-05-02). 

SlipMatchHash pickBestSlipCandidate refactor (mobiz #366, 78a2dc3, 2026-05-02). The original V1 fraud lookup iterated bank_statements candidates and returned AlreadyMatchedTo on the first ownership conflict, which produced the production false-positive on DEP17776655127CL4Q0 (S65Win, 2 พ.ค. 2026): the slip's real KBANK→4372199555 transfer existed unmatched in the DB, but the auto-matcher hadn't linked it because the registered account_number didn't end in "0002"; the structured-fallback query (legacy rows lack match_hash) returned 8 same-day candidates for a busy account, the 7 already-credited ones surfaced first, and the legitimate unmatched candidate (whose sender-account overlap pointed at the slip's actual sender) was never reached. Fix: services.pickBestSlipCandidate (extracted as a pure function so unit tests don't need MongoDB) scores every candidate via (score, ownedByOther, minuteDelta) where score=3 is 4-digit sender-account overlap, score=2 is 3-digit overlap (cross-bank-mask "same account"), score=1 is hash-only; sorts so highest score wins; within same score, unmatched candidates beat owned ones; within same score+ownership, smaller minute-delta wins. Block fires only when the chosen best candidate is owned-by-other AND (lookup was via hash OR sender-overlap score >= 2); score-1 fallback hits on busy accounts no longer block. The "score, then decide" pattern is the durable lesson — first-iteration decisions on multi-candidate sets are ambiguous when ownership signals can land on the legitimate target.

---
*Added via Oracle Learn*
