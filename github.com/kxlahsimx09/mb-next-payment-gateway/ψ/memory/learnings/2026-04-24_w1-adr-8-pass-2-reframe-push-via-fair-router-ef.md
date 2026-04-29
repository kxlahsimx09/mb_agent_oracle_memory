---
title: W1 ADR-8 pass 2 reframe — push via fair-router EF (supersedes pass-1 pull-first)
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-8, pass-2, reframe, provisional, bot-gateway-work-distribution, fair-router, push, fairness, least-count-lru, edge-function, option-f, supersedes-pass-1, input-5-driven, review-driven-pass-cadence]
created: 2026-04-24
source: docs/adr.md@36628c3 + Input 5 direct read of scheduler/withdrawal_dispatcher.go:108,166-179,252,475-565 @ mobiz 19e0bed (2026-04-24 GMT+7) + user dialogue on fairness requirement
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 ADR-8 pass 2 reframe — push via fair-router EF (supersedes pass-1 pull-first)

W1 ADR-8 pass 2 reframe — push via fair-router EF (supersedes pass-1 pull-first).

## What this pass did

Rewrote §ADR-8 in `docs/adr.md` to adopt **Option F (push via fair-router Edge Function)** as the default model for gateway-dispatched bank-bot work. **Superseded pass-1's Option D (pull-first broadcast + claim RPC)** which had been tagged `#provisional [RATIFICATION_PENDING:44]` since filed earlier today (2026-04-24 GMT+7). Added pass-7 update note to §ADR-4a describing Mode 1 semantic change (race-to-claim retired in favor of fair-router pre-assignment) without touching §ADR-4a's ratified decisions (physical constraint, defense-in-depth, claim-RPC-as-sole-path, sweep triage, 4-step lifecycle).

Section tag: `#provisional` still — awaits thread #46 ratification. Thread #44 closed with supersede citation.

## The finding that drove the reframe

**Input 5 direct code read** of `scheduler/withdrawal_dispatcher.go` @ mobiz `19e0bed` (2026-04-24 GMT+7), specifically lines 108-317 dispatch() + 475-565 findBestBankForItem + 166-179 bankDailyTxn population:

- **Line 554-565** selects bank by **explicit least-daily-count LRU** — not FIFO spread, not round-robin, not weighted random. Verbatim: "Pick bank with lowest daily_transactions (load balance)."
- **`bankDailyTxn` metric** combines persistent `bank.DailyTransactions` + live `OutstandingCountForBank` queue load + in-tick `++` assignments.
- **Cross-direction activity counted** (`countTodayCompletedTransactions` lines 446-471) — deposits (ts_deposits status=paid) + withdrawals (withdrawal_queue status=success). Fairness is unified bank activity, not per-lane.
- **DRIFT-12 still open** — lines 210-215 comment claims "per-bank independent cap" but lines 227-241 apply uniform cap. Not resolved at HEAD 19e0bed.

Full finding filed as learning `2026-04-24_current-system-prior-art-findbestbankforitem-u`.

## Why Option D was rejected

Pass 1 characterized current fairness as "weak / statistical" and chose pull-first (broadcast + claim RPC with per-claim tier-cap bolt-on) as default. Pass-2 Input 5 read disproved the characterization: current uses strong LRU. Pull cannot replicate this without either:
1. **Degrading to statistical fairness** — measurable regression from current; visible in burst scenarios (50 items / 1s → fast bot grabs 20+); risks anti-detect threshold breach.
2. **Adding pool-wide coordination at claim time** — either fails under race (two bots both see themselves as lowest → both claim) or serializes via SELECT FOR UPDATE on aggregate → loses pull's parallelism → becomes F in disguise.

User confirmed fairness is a **strong requirement** ("ต้องมี"), not "nice to have." Pure pull is therefore inappropriate for bank-capacity-constrained work.

## Option F execution shape

1. **Enqueue** — source flow INSERTs:
   - Substitutable work: `required_bank_account_id = NULL, pool_id NOT NULL, status = 'pending_routing'`
   - Non-substitutable (Pullout/DirectTransfer/admin): `required_bank_account_id = <named>, status = 'pending'` (bypasses router)
2. **Fair-router Edge Function** triggered by `pg_notify` on `pending_routing`:
   - Advisory lock (pool_id-scoped); parallel across pools
   - Port `findBestBankForItem` into TypeScript: bankDailyUsage computation (persistent + queue load + in-batch) + tier cap + candidate filter (method/balance/MaximumOutstandingWithdrawal/tier-cap/pool-membership) + lowest-count selection
   - UPDATE `required_bank_account_id = <picked>, status = 'pending'`; release lock
3. **Realtime broadcast** — same substrate; subscribe filter always Mode-2 shape (`required_bank_account_id = <bot>`). Mode 1 (pool-broadcast race) retired.
4. **Claim RPC** (`claim_withdrawal_items`) unchanged from §ADR-4a. Pool-filter branch retained as defense-in-depth re-check but never serves as racing mechanism — fair-router has singularized the target.
5. **Sweep** extends §ADR-4a Decision 6 with two triage cases:
   - `pending_routing > 1 min` → re-invoke fair-router (dead-EF recovery; advisory lock makes this idempotent)
   - `required_bank_account_id` set but no claim in 1 min → un-assign + reset to `pending_routing` for re-routing (dead-bot recovery; heartbeat filter skips it in router's next pass)

## What survives from pass 1

- Option A (pure push SSE) structurally rejected — browser bot = not durable push target (DRIFT-1 evidence) — **unchanged.**
- Option B implementation rejected — **carried forward but reframed:** spirit of B (centralized fairness decision) adopted as F's core; only the execution substrate differs (Edge Function + advisory lock vs Go goroutine).
- Option C (pure polling) — **unchanged** as Phase-1.5 degrade target.
- Bot-initiated work out of scope — **verified via bank-bot `app.js @ ffd626b` agent-assisted inventory** (8 task types enumerated); statement scrape + OTP + keepalive + poll infra all bot-originated.
- Thread #45 (fleet-control) deferred — **unchanged.**

## Relationship to §ADR-4a (ratified 2026-04-22)

§ADR-4a receives a "pass 7 update" note at the top of its section. **No §ADR-4a decisions are superseded.** Specifically:
- Physical-constraint invariant (thread #41) — preserved.
- Claim-side batch assembly (thread #42) — preserved; fair-router runs before claim, not instead of claim.
- pg-writer nil-pool classification (thread #43) — preserved; fair-router's pool lookup is `NOT NULL`-enforced, closes the gap unconditionally.
- 8 numbered decisions (two-mode CHECK constraint, pool first-class, broadcast Layer 1, claim-RPC Layer 2, pre-claim health check, sweep triage, 4-step lifecycle RPCs, admin-override) — all survive.
- Only Mode 1 *execution shape* changes (race-to-claim → fair-router pre-assigns; subscribe filter always Mode-2 post-routing).

## What I got wrong in pass 1 and how pass 2 corrected

Pass 1's blind spot: I characterized current-system fairness as weak/statistical without doing Input 5 direct read of `findBestBankForItem`. I relied on Oracle learnings that described **what** `findBestBankForItem` does ("spreads items across banks") without detailing **how** ("pick lowest daily_transactions"). That granularity gap allowed me to assume pull's statistical fairness was parity — when it's a regression.

User review surfaced the gap: the initial "bots แย่งกัน" fairness framing led me to propose quota bolt-ons; user pushed back with "ความจริง เรายังต้องการที่จะคุม... ให้เท่าๆ กันในทุก bank"; I proposed options; user asked for detailed comparison; user asked "current logic ทำงานยังไง"; I did Input 5 read; finding inverted the decision.

**Lesson for future architect passes:** When prior-art learnings describe **what** without **how** on a load-bearing mechanism, that's a signal to do Input 5 before making the related decision. Pass-1's rush (same day as baseline ADR-8 creation) amplified this — didn't pause to test the fairness assumption with evidence.

## Threads actions

- **#44** closed (pass-1's 4-sub-question ratification). Closing message cites this pass + commit `36628c3` + pointer to #46.
- **#46** opened (pass-2's 5-sub-question ratification). Anchored in §ADR-8 title + §Deferred.
- **#45** unchanged (fleet-control deferred).

## Sources cited (full evidence bundle)

- learning:`2026-04-24_current-system-prior-art-findbestbankforitem-u` — **primary pass-2 evidence** (Input 5 direct read).
- learning:`2026-04-22_w1-refine-pass-2-withdrawal-dispatch-claim-ra` — §ADR-4a pass-2 ratification; preserved, not superseded.
- learning:`2026-04-17_name-drift-sse-intake-is-disabled-at-runtim` — Option A rejection (carried forward).
- learning:`2026-04-17_name-drift-pollloop-has-three-hardened-pre` — Phase-1.5 polling reference (carried forward).
- learning:`2026-04-22_drift-resolvepoolbankids-nil-fallback-silentl` — nil-pool closed by fair-router (carried forward).
- retro:`2026-04/23/11.09_w1-session-closeout-adr-4a-adr-6` — review-driven pass cadence pattern; pass 2 is an instance.
- Agent-assisted bank-bot inventory `app.js @ ffd626b` — 8 task types; all gateway-dispatched bank work is capacity-constrained.

## Commit + PR

- Commit: `36628c3` on branch `claude/relaxed-brown-12cebb` (148 changes to `docs/adr.md`: 98 insert / 50 delete after diff compaction).
- PR: https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/2 (continuing pass-1's PR, not a new one — pass 2 is same-branch continuation).

## Next-pass candidates

**Dependency-driven:** When thread #46 ratifies → pass 3 strips `[RATIFICATION_PENDING:46]`, promotes ADR-8 from `#provisional` to `#decision`, closes #46 with commit citation. Will also refresh §ADR-4a's update note phrasing from "follow-up pass" to specific implementation-phase handoff.

**Downstream implementation work** (when ratified):
- Rewrite `docs/design/withdrawal-lane/claim-rpc.md` — remove Mode-1 filter branch from RPC body commentary (still in code as defense-in-depth, but no longer the racing mechanism in practice).
- Add `docs/design/withdrawal-lane/fair-router.md` — fair-router EF spec (body port of `findBestBankForItem` into TS + advisory-lock pattern + heartbeat-alive filter + sweep recovery).
- Update `docs/design/withdrawal-lane/realtime-filter.md` — Mode-2-only filter description.
- Update `docs/design/withdrawal-lane/sweep-and-lifecycle.md` — add 2 new sweep triage cases.

**Independent (unchanged from pass-2 retro):**
- Deposit auto-match lane (§ADR-4 other half).
- Admin-review workflow refine pass (mobiz thread #14 carryover).

## Pattern captured — review-driven reframe via Input 5

This pass embodies the "review-driven pass cadence" pattern: user surfaces a class-of-concern, architect responds with analysis + options, user asks "how does current do it?", architect does Input 5 read, finding inverts the decision. Total cycle: ~4 conversational exchanges. Worth archiving as a canonical shape for when pull-vs-push / sync-vs-async / strict-vs-eventual trade-offs arise in future subsystems.

---
*Added via Oracle Learn*
