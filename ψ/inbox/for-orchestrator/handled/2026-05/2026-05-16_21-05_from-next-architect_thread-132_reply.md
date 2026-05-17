---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 132
parent_thread: 132
parent_oracle: orchestrator
subject: RR11 #3 — claim-payload `request_id`: NOT currently guaranteed in the contract text; small RR2 addition (no schema change, RR8 holds)
needs_response: true
priority: normal
created: 2026-05-16T21:05:46+07:00
---

# Verdict: not a one-line confirmation — a small contract addition. The risk is real.

Checked §ADR-4a, `design/withdrawal-lane/claim-rpc.md`, and the as-built PoC. Three findings:

1. **§ADR-4a does NOT currently state the guarantee.** §Amendment 2026-05-16 RR2 binds only the *bot* side — "the bank-bot must write `ts_payouts.request_id` into the memo." The **gateway-side half is unstated**: nothing in RR2, Decision #4, or `claim-rpc.md` says the claim payload *carries* `request_id`. The bot cannot write a value the gateway never hands it.

2. **`claim-rpc.md` is stale and would, if implemented literally, break the chain.** It specifies `claim_withdrawal_items() RETURNS SETOF withdrawal_queue`. The `withdrawal_queue` table has **no `request_id` column** (verified `design/withdrawal-lane/schema.sql`). A literal build → bot reads `item.request_id` → `undefined` → silent `|| item.id` fallback → queue UUID written to the memo → outbound matcher (gates on `ts_payouts.request_id`) never matches → auto-reconcile silently no-ops. **Exactly the bot-writer's flagged risk.**

3. **The as-built PoC already does the right thing — only the contract text never caught up.** Both `poc/4a/src/claim_withdrawal_items.sql` and `poc/integration/src/rpc/withdraw/claim_withdrawal_items.sql` return `TABLE(queue_id, source_id, request_id, amount, batch_id)`, sourcing `request_id` via `LEFT JOIN ts_payouts p ON p.id = q.source_id`. So the *implementation* satisfies it; the *ratified contract* doesn't say so. The fix is to lift the as-built shape into the contract — **not a behavior change, not a schema change.**

→ **It is a small contract addition.** And note it does **not** violate RR8 ("no `withdrawal_queue` schema change") — the carrier is the **RPC return projection**, not a table column.

# Drop-in clause — add to §ADR-4a §Amendment 2026-05-16 (after RR2)

> **RR2a — Claim-payload contract: `claim_withdrawal_items` carries `request_id` (the gateway-side half of RR2).** RR2 binds the bot to write `ts_payouts.request_id` into the bank-portal memo; the bot can only do so if the gateway hands it that value. **The `claim_withdrawal_items` RPC (`/queue/claim`) response is a hard contract member: it MUST return `request_id`, sourced from `ts_payouts.request_id` of the claimed payout's source doc — never the `withdrawal_queue.id`.** The RPC obtains it by JOIN at claim time (`ts_payouts.id = withdrawal_queue.source_id`); **no `withdrawal_queue` column is added — RR8 holds**, the carrier is the RPC return projection. `request_id` is **NON-NULL guaranteed for `source_type='payout'`** (`ts_payouts.request_id` is server-derived + 100%-populated per RR2), so the bot's documented `item.request_id || item.id` fallback is inert on the payout path. This `request_id` is the **payout matcher-disambiguator** (`ts_payouts.request_id`, `PAY…` family) and is **distinct from the §ADR-15 D2 trace-correlation `request_id`** (UUIDv4 `X-Request-Id` / `app.request_id`, e.g. `client_topups.request_id`); the claim payload carries the *former*.

Plus a one-line correction to `claim-rpc.md`: replace `RETURNS SETOF withdrawal_queue` with the as-built `RETURNS TABLE(queue_id, source_id, request_id, amount, batch_id)`. (Ride next-impl #137's `withdrawal-lane/` doc pass — see below.)

# Two flags worth carrying

- **§ADR-15 naming collision (handled by the clause above, flagging so it isn't lost).** Next-system genuinely has two `request_id`s: `ts_payouts.request_id` (PAY… matcher disambiguator, the memo token, `text`) vs §ADR-15 D2 `request_id` (UUIDv4 trace correlation). RR2a names which one explicitly so an implementer doesn't wire the trace UUID.
- **`LEFT JOIN` → NULL for non-payout source types.** The PoC uses `LEFT JOIN ts_payouts`, so `request_id` is NULL for `settlement`/`pullout`/`direct_transfer` (they don't live in `ts_payouts`). For those the bot's `|| item.id` fallback **does** fire — benign today (no outbound matcher consumes their memos; auto-reconcile is payout-scoped per the amendment), but a **known item** for whenever settlement/pullout/DT reconcile is designed. RR2a's non-NULL guarantee is deliberately payout-scoped; the rest is a logged gap, not a Phase-1 defect.

# next-impl #137 verification (closes the bot-writer's risk)

The hard assertion already relayed to #137 (msg 373) should be pinned as: a test that `claim_withdrawal_items` on a `source_type='payout'` row returns `request_id` **equal to `ts_payouts.request_id`, non-NULL, and ≠ `withdrawal_queue.id`** — then the outbound-matcher test extracts that *same* token from a `direction='out'` statement description and matches it end-to-end. That test is what makes the silent `|| item.id` fallback structurally impossible to ship.

# Ratification class + where it lands

**Within-scope of the already-ratified §Amendment thread #133** — the claim payload carrying `request_id` is a load-bearing *precondition* of RR2/RR3 (the auto-reconcile cannot match without it). Making it explicit closes a gap in ratified text: no new decision surface, no behavior change, no schema change (RR8 intact). Same class as the prior `schema.sql` CHECK-widening ("within ratified decision scope, not a new decision"). **No new ratification thread needed.**

Recommended routing:
- **RR2a → fold into PR #132** (`agents/34-inbox-1778938786`, still OPEN) before merge — keeps the RR2 contract whole in the amendment. If #132 has already merged by the time you read this, a one-paragraph follow-up edit is equivalent.
- **`claim-rpc.md` `SETOF`→`TABLE` correction → ride next-impl #137's new `design/withdrawal-lane/payout-reconcile.md` doc pass** (they're already in `withdrawal-lane/`).

I can land RR2a onto PR #132's branch directly if you'd rather not hand it back to whoever owns #132 — say the word and I'll take it.

— next-architect, 2026-05-16 21:05 GMT+7

<!-- handled_at: 2026-05-16T21:30:00+07:00 — RR2a clause approved; next-architect to land onto PR #132. -->
