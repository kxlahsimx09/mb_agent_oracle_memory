---
from: orchestrator (campaign 41-o-business-gap)
to: [next-live-tester]
date: 2026-06-21T00:00:00+07:00
topic: New LIVE journey to author — withdrawal over-draw under stale/absent bank balance (GW-X-02)
status: journey spec ready; build of the fix (Model B reserve-at-claim) is being ADR-authored now — write the test against the spec, run RED-first today, GREEN after build lands
tags: [#repo:mb-next-payment-gateway, #live-tester, #gw-x-02, #over-draw, #withdrawal, #reservation, #money-safety, #cross-repo]
---

# Handoff → next-live-tester: GW-X-02 over-draw journey

A good money-safety LIVE journey surfaced by the business-gap review. Author it as a standing journey; it RED-fails today and should GREEN after the Model-B fix lands.

## The gap (GW-X-02, HIGH money-safety)
Withdrawal claim guard `claim_withdrawal_items`: `EXIT WHEN running_total + amount > balance`, reading `bank_account.balance`. That column is sourced ONLY by the bot via `bot_update_balance`, now **Phase-2-stubbed (BBOT-013)**. No gateway settle-decrement, no freshness guard, no in-flight accounting across batches → **over-draw on stale/absent balance**.

## Owner-decided fix to test against (Model B = reserve-at-claim)
- `available = balance − reserved`. claim: guard `reserved+amt > balance` → reject, else `reserved += amt`. settle: no-op. fail/sweep/cancel: `reserved -= amt`.
- (b) bot scrape `bot_update_balance` writes ABSOLUTE value → overwrites `balance` + sets `balance_updated_at`, resets `reserved` to post-scrape claims only.
- **Freshness guard:** `balance_updated_at` older than threshold → REJECT claim + fire monitoring alert.

## Journey to author (tests/http or live harness — mirror existing withdrawal journeys)
**J1 — cross-batch over-commit (core):**
1. Seed a bank_account with balance B; ensure bot balance-push is OFF/stale (simulate the stub).
2. Enqueue payouts so each single claim batch ≤ B, but two batches summed > B.
3. Fire fair-router assign + `claim_withdrawal_items` for two banks/batches within one scrape interval.
- **Expected post-fix:** total claimed across batches ≤ available; the batch that pushes `reserved` over `balance` is rejected. **Today (RED):** both claim → over-draw.

**J2 — freshness reject + alert:**
1. Stop bot balance push; advance virtual clock (§ADR-20 `app_now()`) past the staleness threshold.
2. Attempt a claim.
- **Expected post-fix:** claim REJECTED + monitoring alert row/event emitted. **Today (RED):** claim proceeds on stale balance.

**J3 — scrape overwrite + reset (no double-count):**
1. After some settles, push a fresh `bot_update_balance` absolute value.
2. Assert `balance` overwritten to ground truth, `reserved` reset to post-scrape claims, and no double subtraction (cf. §ADR PD3 pullout pattern).

**J4 — fail/sweep release:** claim then force a `failed`/stale-sweep; assert `reserved` released and headroom restored.

## Pre-run gate to confirm (item 0)
Confirm whether the DEPLOYED bankbot still calls `bot_update_balance`. If fully stubbed, J2's stale path is the *default* prod state, not an edge case — raise its priority. Code: `mb-next-bank-bot` `core/api.js:265` (stub), `core/statement-push.js` (dropped post-scrape balance push).

## Pointers
- Source findings: `…/arra-oracle-v3/ψ/inbox/handoff/2026-06-20_bizgap-review/gateway-bizgap-findings.md` §7, §13(2), OPEN-Q X2.
- Parked design: `mb-next-payment-gateway/docs/design/withdrawal-lane/open-questions.md §2`.
- Parity row: `docs/audit/parity/gateway-parity-money.md` GW-X-02.
- ADR amendment (in progress): §ADR-4a §Amendment 2026-06-21 (reserve-at-claim) — owner-gated PR pending.
