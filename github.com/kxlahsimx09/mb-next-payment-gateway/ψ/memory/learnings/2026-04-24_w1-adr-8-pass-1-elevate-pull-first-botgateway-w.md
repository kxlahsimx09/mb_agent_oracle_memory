---
title: W1 ADR-8 pass 1 — elevate pull-first bot↔gateway work distribution to a general 
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-8, pass-1, provisional, bot-gateway-work-distribution, pull-first, broadcast, claim-rpc, defense-in-depth, trade-off, cross-cutting, realtime, option-evaluation, ratification-pending]
created: 2026-04-24
source: docs/adr.md@3337d4e + §ADR-4a pass-2 + bank-bot DRIFT-1/5/6/7 + pg-writer nil-pool follow-up + session-closeout retro 2026-04-23 11.09 + pass-2 retro 2026-04-22 19.37
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 ADR-8 pass 1 — elevate pull-first bot↔gateway work distribution to a general 

W1 ADR-8 pass 1 — elevate pull-first bot↔gateway work distribution to a general architectural principle (provisional).

## What this pass did

Added §ADR-8 to `docs/adr.md` inserting between §ADR-7 and §Revision log. The section surfaces the pull-first pattern §ADR-4a applied lane-locally (Realtime Postgres-Changes broadcast + `claim_withdrawal_items`-style RPC with defense-in-depth pool re-derivation) as a **cross-cutting architectural principle** governing all gateway → bot work distribution in the next system.

Tag: `#provisional` + `[RATIFICATION_PENDING:44]` (thread #44). §ADR-4a remains the single `#decision` record for its own lane; ADR-8 does not supersede or weaken it — ADR-8 is the general rule §ADR-4a already obeys.

## Load-bearing decisions (all pending thread #44 ratification)

1. **Pull-first (Option D) is the default for substitutable work** (Payout, Settlement; matches `pool_id` + method). Broadcast = Layer 1 performance; RPC = Layer 2 security (pool re-derived from JWT-bound `bank_account_id`, unforgeable).

2. **Non-substitutable work uses broadcast-of-one on the same substrate** (Pullout, Direct Transfer; admin-cancel/admin-reconcile of specific batch). Subscribe filter = `required_bank_account_id = <this bot's bank_account_id>`; RPC path unchanged (Mode 2 in §ADR-4a). No separate push channel.

3. **Pure polling (Option C) is the degrade target under Realtime outage** — correctness-equivalent to Option D; only latency changes (30 s vs ~100 ms). RPC body unchanged.

4. **Pure push (Option A) is structurally rejected.** Browser-hosted bot is not a durable push target; bank-bot DRIFT-1 evidence — `core/sse.js` exists but is never instantiated because SSE endpoint requires JWT, bot uses Bot Secret. Any push-to-browser-client inherits this platform tax.

5. **Hybrid pre-assign + poll (Option B, current production) is explicitly rejected for next system.** Four grounded reasons: (i) pool isolation conditional on ops-config completeness — nil-poolBankIDs gap at `scheduler/withdrawal_dispatcher.go:596-598` (thread #43 Hypothesis 3 + pg-writer follow-up drift learning); (ii) cold-start reconciliation problem — items pre-stamped to dead bot must be triaged; (iii) central dispatcher SPOF — `WithdrawalDispatcher` goroutine is sole assigner; (iv) ADR-1/3/5 platform mismatch.

6. **Emergency fleet commands out of scope.** Deferred to future fleet-control ADR (`[AWAITING_THREAD:45]`, thread #45).

7. **Bot-initiated work (statement submit, OTP retrieval, keepalive per C-001) scoped out.** ADR-8 governs gateway → bot direction only.

## Why elevate now (not reactive to a concrete request)

Two signals from the ADR-4a → ADR-6 session:

- Pass-2 retro flagged "pool-aware broadcast + claim-RPC defense-in-depth" as a general pattern insight, stronger than its lane-local surface.
- Session-closeout retro identified the "review-driven pass cadence" — each pass surfaces a class-of-smell the previous pass integrated silently. Waiting for admin-review or reconcile to independently re-derive the pattern would be exactly that failure mode.

Elevating pre-emptively is a design-hygiene pre-emption, not a post-hoc rationalization.

## Revisit triggers codified in §ADR-8

(a) Supabase Realtime pricing/reliability shifts materially → degrade to Option C, re-evaluate.
(b) Browser-hosted bots replaced by server-hosted workers (bank-native REST / API adapters vs Playwright) → re-open Option A (push target becomes durable).
(c) Fleet > 50 bots → §ADR-4a revisit trigger applies + partition broadcast substrate by pool.
(d) Imperative command pattern surfaces that cannot fit queue-work abstraction → spawn fleet-control ADR (Exception 2).
(e) §ADR-6 Phase 2 Smart Disconnect adoption → cold-start race re-opens; re-examine broadcast-of-one filter contract.

## Threads opened this pass

- **#44** — "design: ADR-8 — ratify pull-first bot↔gateway work distribution as the general default?" (4 sub-questions: scope elevation; broadcast-of-one correctness; fleet-control deferral; bot-initiated scoping). Ratification class.
- **#45** — "design: ADR-8 — fleet-control substrate (force-logout / maintenance-override / halt-pool) — defer or decide now?" Anchored at Exception 2. Scope-disambiguation class.

## Threads closed

None — pass 1 is a provisional-proposal pass; no prior architect threads resolved.

## Sources cited (full evidence bundle)

- learning:`2026-04-22_w1-refine-pass-2-withdrawal-dispatch-claim-ra` — §ADR-4a ratified record (the lane instance ADR-8 generalizes).
- learning:`2026-04-17_name-drift-sse-intake-is-disabled-at-runtim` (bank-bot DRIFT-1 @ 95dbb70).
- learning:`2026-04-17_name-drift-pollloop-has-three-hardened-pre` (bank-bot DRIFT-5/6/7 @ 95dbb70).
- learning:`2026-04-22_drift-resolvepoolbankids-nil-fallback-silentl` (pg-writer follow-up to thread #43).
- retro:`ψ/memory/retrospectives/2026-04/23/11.09_w1-session-closeout-adr-4a-adr-6.md` — session-wide retro, ADR-vs-design-doc convention, review-driven pass cadence.
- retro:`ψ/memory/retrospectives/2026-04/22/19.37_w1-refine-pass-2-withdrawal-dispatch-ratified.md` — physical-constraint reframe + defense-in-depth narrative.
- §ADR-4a + §ADR-5 + §ADR-6 cross-references.

## Commit + PR

- Commit: `3337d4e` on branch `claude/relaxed-brown-12cebb` (106 insertions, surgical single-file change).
- PR: https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/2 (open, not merged).

## Relationship to §ADR-4a

ADR-8 does not supersede, re-ratify, or weaken §ADR-4a. §ADR-4a's `#decision` tag carries through (threads #41/#42/#43 closed 2026-04-22). ADR-8 is a meta-layer: general rule §ADR-4a already obeys. If thread #44 resolves with scope changes (e.g. user prefers pull-first to stay lane-local), §ADR-4a is unaffected — only ADR-8's scope narrows.

## Next-pass candidates

Short-term (dependency-driven):
- When thread #44 answers → pass 2 integrates answers, strips `[RATIFICATION_PENDING:44]`, promotes `#provisional` → `#decision`, closes thread #44 with citation. Similar shape to §ADR-4a pass 2.
- When thread #45 answers → pass-on-demand: either defer stays (update anchor to "deferred per thread #45") or spawn ADR-9 on fleet-control.

Deferred (no dependency):
- Deposit auto-match lane (ADR-4 other half) — still the logical next ADR refinement per §ADR-4a pass-2 retro's "next-pass candidate".
- Admin-review workflow refine pass — resolves mobiz thread #14 carryover + connects to `docs/design/withdrawal-lane/open-questions.md` §3.

---
*Added via Oracle Learn*
