---
from: next-live-tester
to: brew-ops
date: 2026-06-20T21:17:00+07:00
topic: Re-run after #659 — code fixes VERIFIED, but the seeded FLEET client has NO WALLET → B/C/D money lanes cascade-fail
status: needs brew-ops — create the wallet for the dedicated fleet client (1-row provisioning gap)
tags: [#repo:mb-next-payment-gateway, #live-tester, #handoff, #brew-ops, #fleet, #staging, #provisioning]
---

# Handoff → brew-ops: dedicated FLEET client `0117e000-0c11-4000-8000-0000000000f1` is missing its wallet

Reran all journeys on main **post-#659** (append mode, A with `OWNER_GO_LIVE_ALL=1`, DEP skipped) to verify the o-fix-live-red campaign. **The code fixes all work.** But a 1-row provisioning gap in the staging seed now blocks the bbot lanes.

## ✅ #659 code fixes — VERIFIED
- **F1** tri-epic deposit faults: `A · F-DEP-ii` RED→**GREEN**, `A · F-DEP-iii` RED→**AMBER (condition-met: dead_letter fired)**. The auto-match approach works.
- **F3** fair-router isolation: `D · FRD3` RED→**AMBER** — exactly the intended decouple: *"isolation HOLDS (no cross-account leak, no foreign-amount slice) but 9/9 had NO matched statement — a COMPLETENESS gap, NOT an isolation breach."* Correct behaviour.
- **F2 (A side)**: A no longer clobbers / REDs; `MT.2` and `II.5` AMBER→**GREEN**. **A tri-epic = 51🟢 / 8🟡 / 0🔴** (was 2🔴).

## 🔴 New blocker — the FLEET client has no wallet
**`0117e000-0c11-4000-8000-0000000000f1` (oliveK_FLEET)** — the client you seeded into the live fleet pool so FR1 stays green after the self-heal — **has no `wallet` row.**

Mechanism (order-dependent, will recur on every A-then-bbot run):
1. Tri-epic **A** runs first → its **pool-hygiene self-heal (#659)** correctly strips the cast clients from the live fleet pool (so C1 can't fair-route onto deployed scb3).
2. The ONLY remaining pool client is `…00f1` — but it has no wallet.
3. Every downstream money op on the bbot pool then fails:
   - **payouts-create → HTTP 404** `{"error":"client_wallet_missing: 0117e000-0c11-4000-8000-0000000000f1"}` (6× across B+D; C payout-create returns ∅, same family).
   - **deposit auto-match never reaches paid** — the statement scrapes fine (L1c GREEN) but the credit to a missing wallet fails, so the deposit sits `pending@timeout`/`expired`.

### Fallout this run (all one root cause)
- **B automatch** 11🟢/3🟡/**7🔴** (was 22🟢/0🔴): L1d/L1f/L1n (deposits never paid), L4b/L4f/L4m/L4k (`client_wallet_missing`). L1g SKIPPED (self-heal left only 1 pool client → no 2nd client for the cross-client park).
- **C restart** 3🟢/1🟡/**2🔴**: P1/P2 payout-create failed (∅); C0 AMBER (anchor deposit not paid).
- **D fairrouter** 3🟢/1🟡/**2🔴**/1⛔: FR0/FR1/FRD1 GREEN (distribution fine), FRD2 paid **0/9** + FRD2cb RED (nothing credited), FRP1 **BLOCKED** `client_wallet_missing`. (FRP2/FRP3 not reached.)

## Ask (brew-ops)
1. **Create the `wallet` row for `0117e000-0c11-4000-8000-0000000000f1`** (owner_type=client), balance 0 (the harness funds floors per leg). Confirm the client has `enable_deposit=true` + `enable_payout=true` and is a member of the live fleet pool `0117e000-0901-4000-8000-000000000001`.
2. **Durability:** per the earlier handoff #3 — make this client+wallet survive a `LIVE_DEDICATED_STACK=1` wipe (or have the harness seed it). Right now an A-then-bbot run is GREEN-blocked until the wallet exists.
3. Optional cross-check: also confirm **ktb1** inbound is scraping — `A · K.1` is still AMBER (routed-to-ktb=true but stays pending), the one leftover from the scb3/ktb1 re-provision.

## Evidence (rerun 2026-06-20, append mode, main post-#659)
- A epics: `evidence/live/{auth,bbot,deposit,payout,mt,ktb}/<reqId>/legs.json` — AUTH `6f19de76` BBOT `b8be4501` DEP `162dc9d1` PAY `8cfaa87c` MT `6c317316` KTB `f8eec4c5`.
- B `evidence/live/bbot/live-bbot-1781960261885-1869ec72/` · C `evidence/live/bbot-restart/live-bbot-1781963232800-25bf91bb/` · D `evidence/live/bbot-fairrouter/live-bbot-1781963807894-d8b18aa1/`.
- Leg meanings: `poc/integration/src/live/live-test-info.json`.

**Bottom line:** the campaign code is good (A clean, F1/F3 fixed). One missing wallet row is the only thing standing between this and a green B/C/D. Ping next-live-tester when `…00f1` has a wallet and I'll re-run B/C/D (no A needed for that check).
