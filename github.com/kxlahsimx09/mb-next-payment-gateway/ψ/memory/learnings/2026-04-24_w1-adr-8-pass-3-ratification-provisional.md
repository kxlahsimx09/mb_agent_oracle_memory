---
title: W1 ADR-8 pass 3 — ratification: `#provisional` → `#decision` via thread #46.
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-8, pass-3, ratification, decision, fair-router, bot-gateway-work-distribution, option-f, thread-46-resolved, business-constraint-honored]
created: 2026-04-24
source: docs/adr.md@5215ecb + thread #46 resolution (user ratification 2026-04-24 GMT+7 messages 86-94)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 ADR-8 pass 3 — ratification: `#provisional` → `#decision` via thread #46.

W1 ADR-8 pass 3 — ratification: `#provisional` → `#decision` via thread #46.

## Supersedes

`learning_2026-04-24_w1-adr-8-pass-2-completeness-sub-amendment-x` — the final pre-ratification design state. Pass 3 ratifies without body changes; this learning records the promotion.

## What this pass did

Thread #46 resolved 2026-04-24 GMT+7. User ratified all 5 core sub-questions + the Phase-2 metric sub-question (handled via business-constraint ratification message 93 earlier in the thread).

### 5 core sub-questions — all YES

1. **Fair-router EF as single dispatch model (Option F)** ✅ — push via `pg_notify`-triggered Edge Function; ports `findBestBankForItem` LRU verbatim.
2. **Mode 1 retirement in §ADR-4a** ✅ — race-to-claim path retired; all broadcasts post-routing use Mode-2 filter. Claim-RPC pool-filter branch kept as defense-in-depth re-check only.
3. **Pull as exception-only, not default** ✅ — future gateway-dispatched bot subsystems default to push-via-fair-router; pull requires justification in subsystem's own ADR.
4. **Latency regression ~100-300ms accepted** ✅ — still ~100x faster than current's 30-60s; trade-off for strong LRU fairness.
5. **Sweep belt-and-suspenders** ✅ — Trigger B (lifecycle-RPC pg_notify) is primary bank-free recovery; sweep 1-min catches edge cases (pg_notify drop, EF crash, advisory-lock timeout).

### Phase-2 metric sub-question (implicit)

✅ **Port verbatim withdrawal-only** — business constraint ratified in message 93: bank_accounts are always role-separated (deposit-purpose vs payout-purpose; never mixed). Under this policy, withdrawal-only LRU is correct-by-design, not just current-system parity. Unified metric would be a category error (adding 0 for payout-only accounts).

## Pass-3 changes (promotion-only; no decisions altered)

- **§ADR-8 title** — stripped `[RATIFICATION_PENDING:46]`; added "ratified `#decision` 2026-04-24 GMT+7 via thread #46".
- **§ADR-4a "Update (pass 7)" note** — forward-looking → past-tense ratified.
- **§Deferred questions** — `[AWAITING_THREAD:46]` removed + ratification summary; `[AWAITING_THREAD:45]` preserved (fleet-control still deferred).
- **§Revision log** — pass-3 ratification entry added.

Commit `5215ecb` on branch `claude/relaxed-brown-12cebb` (PR [#2](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/2)).

## Cumulative pass chain (P-001 preserved)

```
pass-1 pull-first (provisional, early 2026-04-24)
  → pass-2 reframe: push via fair-router (provisional)
  → amendment: Trigger B + sweep reframe + early-bail
  → correction: withdrawal-only metric + dead-code findings
  → cleanup: body + prior art + sources
  → completeness sub-amendment: X4 + heartbeat + base deps
  → business-constraint ratification: Phase-2 metric resolved
  → pass-3 ratification: #decision (late 2026-04-24)  ← current
```

All intermediate states preserved via git history + `arra_supersede` chain.

## Decision summary (now #decision, citable)

**Option F (fair-router push) is the default model for gateway-dispatched work on bank resources.** Source flows INSERT with `pending_routing` status; fair-router Edge Function (triggered by `pg_notify` on INSERT via Trigger A + on lifecycle terminal status via Trigger B) picks bank via least-`bankDailyUsage` LRU within `pool_id`-scoped advisory lock, drain-loops multiple waiting items, UPDATEs `required_bank_account_id`. Realtime Mode-2 broadcast wakes exactly one bot; claim RPC re-verifies pool + invariant as defense-in-depth. Sweep 1-min covers edge cases. X4 NOTIFY coalescing eliminates burst fan-out. §ADR-4a Mode 1 (pool-broadcast race) retired; all broadcasts are Mode-2 shape post-routing.

## Consequences preserved from pass-2

- **Speed:** ~100-300ms normal path vs current 30-60s (100x faster)
- **Fairness:** verbatim port of current's LRU + queueLoad + caps; equivalent
- **Correctness:** 12 failure modes × recovery paths; no new loss scenarios
- **ADR-3 compliance:** policy in TypeScript, atomic boundary in PL/pgSQL RPC
- **No central-dispatcher SPOF:** stateless EF + advisory lock

## Open items

- **Thread #45** (fleet-control substrate) — still pending; deferred to future fleet-control ADR.
- **§ADR-8 body is 118 lines** — close to pass-6-convention threshold (~150 lines). User requested size review; pass-4 doc-organization refactor planned to extract implementation detail to `docs/design/bot-gateway-dispatch/` while preserving decisions inline. Same pattern as §ADR-4a pass-6 extraction.

## Next-pass candidates

**Immediate:** pass-4 (doc-organization refactor) per user request — extract implementation detail into `docs/design/bot-gateway-dispatch/` and shrink §ADR-8 body to decisions + pointers.

**Medium-term** (independent):
- Deposit auto-match lane (§ADR-4 other half). Now with business constraint ratified, deposit rotation is truly independent.
- §ADR-4a follow-up pass — rewrite `docs/design/withdrawal-lane/*.md` to match fair-router model (remove Mode-1 racing references; add fair-router + sweep-case-2 documentation).
- Admin-review workflow refine pass (mobiz thread #14 carryover).

**Long-term triggers:**
- Fleet-control ADR (thread #45 resolution-dependent)
- Revisit trigger (h) if business policy shifts to allow mixed-method bank accounts

## Retrospective

Full session retro will cover pass 1 → pass 3 + pass 4 when complete.

Notable pattern captured: **review-driven pass cadence with aggressive pre-ratification amendment** — pass 2 went through 5 amendments (Trigger B, correction pack, cleanup, completeness sub-amendment, business-constraint) before ratification. Each amendment was triggered by user review surfacing gaps. The `#provisional` + thread-first discipline let us iterate freely without downstream impact. Expensive in attention (many sub-amendments); cheap in outcome (no wrong decision shipped to `#decision` tier).

## Process notes

- User ratification pattern: concise yes/no on each sub-question. No re-negotiation; decisions stable.
- Spec completeness: pre-ratification amendments closed all specification gaps surfaced during review. Implementation-phase agents should have complete spec.
- Size concern: raised at ratification time, not during design — appropriate timing (don't optimize before decisions stable). Pass-4 extraction is the response.

---
*Added via Oracle Learn*
