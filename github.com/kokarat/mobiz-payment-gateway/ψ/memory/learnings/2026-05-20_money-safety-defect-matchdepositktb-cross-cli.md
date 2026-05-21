---
title: **money-safety defect: `matchDepositKTB` cross-client wrong-credit — `matchByCli
tags: [money-safety, matcher, cross-client, wrong-credit, regression-guard, verify-before-write, transactionMatcher, matchByClientScope, matchByFIFO, KTB, deferred-fix]
created: 2026-05-20
source: Oracle Learn
project: github.com/kokarat/mobiz-payment-gateway
---

# **money-safety defect: `matchDepositKTB` cross-client wrong-credit — `matchByCli

**money-safety defect: `matchDepositKTB` cross-client wrong-credit — `matchByClientScope` is a partial guard, FIFO fallback defeats it. NOT FIXED — recorded only (user 2026-05-20).**

In current mobiz (`services/transactionMatcher.go:193-197`), `matchDepositKTB` calls `matchByClientScope` first, then **falls through to `matchByFIFO`** when more than one client is eligible. `matchByClientScope` only short-circuits the *single-eligible-client* case; for ≥2 eligible clients (the cross-client collision — the dangerous case) it returns false, and `matchByFIFO` then blind-picks the oldest **with no client scoping** — a wrong-client-credit path.

**Scenario.** Client A and Client B both have pending KTB deposits with the same amount + same source account (a payer can fund multiple clients into the same KTB system bank account). A KTB statement arrives → `matchByClientScope` sees 2 eligible clients → returns false → `matchByFIFO` picks the oldest → may credit Client B's wallet with money that was Client A's deposit (or vice versa). Wrong-client-credit = the highest-stakes error class.

**Asymmetry.** The SCB path parks for review on a multi-client collision (correct). Only the KTB path falls through to blind FIFO.

**Why test-deposit-collision-dual.sh missed it pre-PR-#452.** Step 8 checked only terminal status. The symmetric 3 KTB clients × (1 statement + 1 deposit) scenario *nets out per client* — even if matched wrong, everyone ends up credited exactly once. PR #452 adds Step 9 (wallet+pairing assertion) and a direct unit test `TestMatchDepositKTB_CrossClientCollisionShouldParkForReview` that asserts park-for-review behaviour and **fails on current code** — `t.Skip`-ped with the gap reason as the ready regression guard.

**Fix options (NOT IMPLEMENTED):**
(a) extend the client-scope guard into the FIFO tier — `matchByFIFO` scopes per client; or
(b) make the KTB multi-client path park-for-review, mirroring SCB.
Either lands → the skipped unit test unfreezes into a permanent regression guard.

**Discovery.** pg-tester `#176` regression-test build (verify-before-write discipline — confirmed against `transactionMatcher.go` before freezing assertions). Tracked in mobiz GH issue (filed 2026-05-20) and PR #452 (skipped guard ready). Carry-forward when the matcher gets its next coordinated touch.

---
*Added via Oracle Learn*
