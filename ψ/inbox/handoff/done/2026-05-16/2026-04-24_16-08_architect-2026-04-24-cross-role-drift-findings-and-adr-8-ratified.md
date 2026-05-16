# Handoff — architect session 2026-04-24 GMT+7

**From:** `system-architect` (mb-next-payment-gateway)
**Branch:** `claude/relaxed-brown-12cebb` → PR [#2](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/2) (14 commits, not merged)

## TL;DR for next sessions

1. **§ADR-8 ratified `#decision` 2026-04-24** via thread #46 — push via fair-router Edge Function is now the default for gateway → bot work distribution. Implementation spec extracted to `docs/design/bot-gateway-dispatch/` (4 files, ~654 lines).

2. **2 current-system drift findings** surfaced during architect Input 5 sweep — for `pg-writer` W4 disposition.

3. **Fair-router has bot-side contract implications** — for `bot-writer` to integrate into bank-bot's design thinking.

4. **§ADR-4a Mode 1 semantic change** (race-to-claim retired; fair-router pre-assigns) ratified inline via pass-7 update note. `docs/design/withdrawal-lane/*.md` files need follow-up pass to match fair-router model.

## For `pg-writer` (drift learnings filed today)

Both tagged `#cross-role-handoff #pg-writer #w4-candidate`; should surface via your Step 0 search:

### Drift 1 — `SelectBankForPayout` is dead code + sort-metric drift
- **Learning:** `learning_2026-04-24_drift-selectbankforpayout-is-dead-code-sort`
- **File:** `services/bankRotation.go:61-64, 240-241, 276-287 @ mobiz 19e0bed`
- **Finding:** function defined + tests reference, **zero production callers**. Within the dead branch, comment at `:240-241` claims payout uses `daily_transactions/balance` but code sorts by `deposit_count_date + deposit_count` (wrong metric). Safe because never called; but re-introducing a caller would inherit the bug.
- **Disposition options:** delete (safe) / revive with metric fix / mark `// DEPRECATED`.

### Drift 2 — `countTodayCompletedTransactions` is dead code
- **Surfaced inline** in `learning_2026-04-24_correction-to-findbestbankforitem-prior-art-ban` (process-lesson section)
- **File:** `scheduler/withdrawal_dispatcher.go:444-471 @ mobiz 19e0bed`
- **Finding:** function defined with cross-direction counting intent (deposit + withdrawal), **zero production callers**. Function body's presence deceived my pass-1 architect analysis into claiming `bankDailyTxn` counts cross-direction. That was wrong — `bankDailyTxn` is withdrawal-only. Caught via user review; corrected ADR.
- **Meta-lesson captured in learning:** before citing function body/comment as evidence for system behavior, grep call-sites. Zero callers → dead code → don't use as evidence.
- **Disposition options:** delete (safe) / revive with caller that needs cross-direction counting / mark `// DEPRECATED`.

**Both findings are low-urgency** (don't affect production) but suggest this area had an architectural refactor that didn't clean up orphans. Worth an archaeology pass.

## For `bot-writer` (fair-router implications)

§ADR-8 (now ratified `#decision`) introduces a **fair-router Edge Function** that sits between source flow's INSERT and the Realtime broadcast. Full spec: `docs/design/bot-gateway-dispatch/fair-router.md`.

Key contract changes for bank-bot:

### 1. Subscribe filter is **always Mode-2 shape post-routing**
Bot subscribes with `required_bank_account_id = <this bot's bank_account_id>` — no more pool-broadcast race-to-claim. Exactly one bot wakes per broadcast. §ADR-4a Mode 1 retired.

### 2. Bot heartbeat is **load-bearing**
Fair-router filters out banks with stale heartbeat (`> 60s`). If bot fails to heartbeat, items skip it silently (not routed). Port of current-system `findIdleBanks` + PR #206 stale-bot skip. Bot should heartbeat every ~30s to stay within the 60s window with margin.

### 3. One-batch invariant enforced at **routing time**, not just claim time
Fair-router only considers banks with zero in-flight batches (`OutstandingCountForBank(bank) == 0`). So bot won't get a second batch broadcast while it's still processing current batch. Claim RPC's existing one-batch check is defense-in-depth.

### 4. Pre-claim session health check (already §ADR-4a Decision 5) unchanged
Bot must verify browser session is live *before* calling claim RPC. Port of current bank-bot `pollLoop` 3-gate pattern.

### 5. Phase-1.5 degrade path: polling fallback
If Realtime is unavailable, bot should fall back to polling `WHERE required_bank_account_id = <self>` — fair-router runs on gateway side independently.

## For `technical-writer` instances (mobiz + bank-bot)

Neither has direct action items from this session, but:

- **mobiz**: flow `withdrawal-queue-dispatch-and-claim` should be annotated (eventually) that next-system retires Mode 1 race-to-claim in favor of fair-router pre-assignment. Not urgent; §ADR-4a pass-7 update note documents this for next-system agents.
- **bank-bot**: flow `queue-claim-to-processing-state-machine` inherits the broadcast filter change; worth noting when next W8 revision pass runs.

## For next `system-architect` session

**Immediate candidates:**
- `docs/design/withdrawal-lane/*.md` follow-up pass — update `claim-rpc.md` (remove Mode-1 racing references), `realtime-filter.md` (Mode-2-only), `sweep-and-lifecycle.md` (add case 2 reference). Estimated ~60 min.
- **Deposit auto-match lane** (§ADR-4 other half). Business constraint ratified → deposit lane is truly independent from withdrawal lane. Prior art: `flow:deposit-auto-match-from-statement` ratified S2 via mobiz thread #17.
- **Admin-review workflow refine pass** — mobiz thread #14 carryover for `waiting_to_review` resolution mechanism.

**Long-term:**
- Thread #45 fleet-control ADR (when concrete driver emerges).
- Revisit trigger (h) if business policy shifts to allow mixed-method bank accounts (would reopen unified-metric question in ADR-8).

## Full session artifact list

**Oracle learnings filed (10 total; 5 in supersede chain + 5 standalone):**

Supersede chain (ADR-8 passes):
```
pass-1 pull-first → pass-2 reframe → amendment (Trigger B) → correction pack → completeness sub-amendment → pass-3 ratification
```
- `learning_2026-04-24_w1-adr-8-pass-1-elevate-pull-first-botgateway-w` [superseded]
- `learning_2026-04-24_w1-adr-8-pass-2-reframe-push-via-fair-router-ef` [superseded]
- `learning_2026-04-24_w1-adr-8-pass-2-pre-ratification-amendment-fair` [superseded]
- `learning_2026-04-24_w1-adr-8-pass-2-amendment-correction-pack-w` [superseded]
- `learning_2026-04-24_w1-adr-8-pass-2-completeness-sub-amendment-x` [superseded]
- **`learning_2026-04-24_w1-adr-8-pass-3-ratification-provisional`** [ACTIVE — current `#decision` record]
- **`learning_2026-04-24_w1-adr-8-pass-4-doc-organization-refactor-extra`** [ACTIVE standalone — refactor note]

Standalone active learnings (not in supersede chain; durable facts):
- **`learning_2026-04-24_business-constraint-bank-accounts-separated-betw`** — business policy invariant (bank_accounts role-separated)
- **`learning_2026-04-24_correction-to-findbestbankforitem-prior-art-ban`** — corrected prior-art (supersedes `...findbestbankforitem-u`); process lesson on grep-verify-call-sites
- `learning_2026-04-24_current-system-prior-art-findbestbankforitem-u` [superseded by corrected version]
- **`learning_2026-04-24_current-system-prior-art-deposit-routing-via-se`** — deposit routing full body
- **`learning_2026-04-24_drift-selectbankforpayout-is-dead-code-sort`** — drift finding for pg-writer

**Threads:**
- #44 (pass-1 pull-first ratification) — closed via pass-2 supersede
- #45 (fleet-control substrate) — still pending; deferred to future fleet-control ADR
- **#46 (pass-2 + pass-3 ratification)** — resolved + closed 2026-04-24 GMT+7 (messages 86-94)

**Commit chain (14 commits):**
```
3337d4e  pass-1 pull-first (provisional)
5b4996e  pass-1 id backfill
36628c3  pass-2 reframe
2518e72  pass-2 id backfill
b87fc1a  pass-2 amendment (Trigger B + sweep reframe)
665d209  amendment id backfill
9fe73c8  pass-2 correction (withdrawal-only metric)
eeaab31  correction id backfill
330c116  correction cleanup (body + prior art)
8228c05  pass-2 completeness sub-amendment (X4 + heartbeat + base deps)
9478d1f  sub-amendment id backfill
4d6e93d  business-constraint ratification
5215ecb  pass-3 ratification (#decision)
e367e92  pass-4 doc-organization refactor (extract to design dir)
2789673  pass-4 id backfill
```

**Design directory created:**
- `docs/design/bot-gateway-dispatch/` with 4 files (README, fair-router, trigger-coalescing, sweep-extensions) — ~654 lines total

**§ADR-8 body size:** 118 lines (pre-refactor) → 66 lines (post-refactor; -44%).

**Retrospective:** `ψ/memory/retrospectives/2026-04/24/18.00_w1-adr-8-pass-3-4-ratification-and-extraction.md` — marathon session retro covering passes 3 + 4.

## Audit findings (this post-session sweep)

Verified supersede chain integrity ✓. All learning IDs cited in `docs/adr.md` + `docs/design/bot-gateway-dispatch/*.md` resolve to valid Oracle entries ✓. No broken links.

Minor drift (acceptable; supersede chain handles gracefully):
- `business-constraint` learning cross-refs pass-2 completeness-sub-amendment (now superseded by pass-3). Reader following chain sees current via `superseded_by` pointer.
- `deposit-routing` learning cross-refs `findbestbankforitem-u` (now superseded by correction version). Same; graceful.

Neither requires action — P-001's "Nothing is Deleted" + supersede chain makes historical refs walkable.

Real fix applied this sweep:
- §ADR-8 pass-3 revision log: predicted id `...pass-3-ratification` → actual `...pass-3-ratification-provisional` + commit `5215ecb` backfill (bundled into this audit commit).
