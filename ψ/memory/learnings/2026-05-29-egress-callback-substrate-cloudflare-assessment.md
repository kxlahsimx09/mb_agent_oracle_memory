# Egress / Callback-Dispatch Substrate — Cloudflare Feasibility Assessment

> **Status: design-exploration — NOT ratified. Consult only.**
> Produced 2026-05-29 in response to ADR-gap query (thread #254 follow-up).
> Human ratification required before any ADR amendment is opened.

---

## Context

The inbound CF Worker (`gateway/cf-worker/`, §ADR-2 §Amendment 2026-05-28 GW5) handles
HMAC verify → rate-limit → GW4 EdDSA mint → EF forward. It is **inbound only**.

The outbound/callback-dispatch substrate is fully specified in **§ADR-9** (ratified):
`callback_queue` outbox → `pg_notify` trigger (with `pg_try_advisory_lock` coalescing per
§ADR-8 X4) → dispatcher Edge Function → `fetch()` to client endpoint → `pg_cron` 1-min
safety-net sweep. Retry state + `callback_attempts` append-only log = 100% Postgres.

**Volume baseline:** ~45k callbacks/day (deposits ~35k + payouts ~10k) + retries.

**Question:** Is it feasible to use Cloudflare for the outbound callback-sending substrate?

---

## Primitive-by-primitive assessment

### 1. Workers outbound `fetch()`

**Feasible.** `crypto.subtle` HMAC is sub-ms (proven in inbound Worker). Network I/O
does not count against CPU budget. One dispatch cycle ≈ 3 subrequests:
Hyperdrive secret-lookup + external `fetch()` + Hyperdrive `callback_attempts` write-back.

Limits that constrain drain-loop batching:
- Free tier: 50 subrequests/invocation → ~15 callbacks per cron invocation
- Paid (Bundled): 1000 subrequests/invocation → ~300 callbacks per invocation
- Wall-clock: Bundled = 30s. A drain of 100 callbacks × 300ms each = 30s — at the limit.
  Workers Unbound removes the wall-clock cap but costs more.

### 2. Cloudflare Queues

**Technically viable for delivery semantics; structurally awkward for state.**

What maps well to §ADR-9:
- At-least-once delivery (§ADR-9 C2) ✅
- No strict FIFO (§ADR-9 C2: no ordering guarantee) ✅
- Configurable retry delay + dead-letter queue (§ADR-9 C4/C5) ✅

What does not map cleanly:

| Problem | Detail |
|---|---|
| **Producer bridge gap** | Postgres has no native path to CF Queue. Need either (a) `pg_net` fire-and-forget HTTP call (non-transactional with the status flip — atomicity broken) or (b) thin Supabase bridge EF (pg_notify → EF → CF Queue enqueue). Option (b) means the Supabase EF never goes away. |
| **Dual-state** | CF Queue owns retry count/backoff; Postgres owns `callback_queue.attempt_count` + `callback_attempts` (§ADR-9 C6). Diverge under Hyperdrive write-back failure. Admin dead-letter recovery (§ADR-9 AM1–AM8) sees stale picture. |
| **Admin resend coupling** | `POST /admin/deposits/:id/resend-callback` (§ADR-9 AM4) must also re-enqueue to CF Queue — couples admin API to a CF primitive. |
| **Free tier** | 1M messages/month = ~33k/day. Baseline ~45k/day exhausts free in ~3 weeks. Paid: ~$0.54/month. |

### 3. Durable Objects

**Reject for Phase-1.** Per-merchant DO alarms give precise retry scheduling but:
- 100k free DO requests/day — consumed quickly at ~45k callbacks/day + retries
- Retry state in DO, not Postgres → `callback_attempts` forensic log (§ADR-9 C6)
  incomplete without Hyperdrive write-back on every alarm fire
- Dead-letter in DO = not recoverable via the ratified admin-API surface without a DO-side API
- Overkill: only justified if per-merchant retry schedules become a hard SLA requirement
  (§ADR-9 D4 Phase-2 trigger)

### 4. Cron Triggers (CF Cron Worker)

**Cleanest failure mode; loses the fast push path.**

A CF Cron Worker polling `callback_queue` via Hyperdrive every 60s is a direct port of the
dispatcher EF. Failure mode is clean: crashed Worker → pending rows stay pending in Postgres
→ next cron invocation resumes. No dual-state.

**Critical flaw:** loses the `pg_notify` fast path. §ADR-9 already evaluated this as
Trade-off A and rejected it: *"Pure pg_cron sweep → 60s tail latency on happy path is
unnecessary."* The ratified happy-path target is ~100–300ms. A Cron Worker variant must
either (a) accept 60s tail latency (reverting a ratified decision) or (b) add a
`pg_notify` → bridge EF → CF Worker HTTP endpoint to preserve the push path — which again
does not eliminate the Supabase EF.

---

## Failure modes + dead-letter comparison

| Variant | Mid-dispatch failure | Dead-letter |
|---|---|---|
| **CF Queue Consumer** | CF Queue acks before Hyperdrive write-back → attempt log gap; dual-state | CF Queue DLQ → must flip `callback_queue.status='dead_letter'` in Postgres |
| **CF Cron Worker** | Crash → pending rows stay pending → next sweep resumes (clean) | Postgres `dead_letter` → §ADR-9 AM admin resend surface unchanged |
| **Current EF (§ADR-9)** | EF crash → pg_notify miss caught by 1-min pg_cron sweep (clean) | Postgres `dead_letter` → §ADR-9 AM1–AM8 admin resend surface |

---

## Mapping to §ADR-9 decisions

| §ADR-9 decision | CF Queue | CF Cron Worker | EF baseline |
|---|---|---|---|
| C2 at-least-once + event_id | ✅ | ✅ | ✅ |
| C2 no FIFO ordering | ✅ | ✅ | ✅ |
| C3 sign at dispatch-time | ✅ +1 Hyperdrive subrequest | ✅ | ✅ |
| C4 retry + dead-letter | ⚠️ dual-state | ✅ Postgres-owned | ✅ |
| C6 append-only `callback_attempts` | ⚠️ Hyperdrive write-back race | ✅ direct write | ✅ |
| AM1–AM8 admin resend + tenant scope | ⚠️ must also re-enqueue to CF Queue | ✅ Postgres-first | ✅ |

---

## Free-tier limits summary

| Primitive | Free cap | Est. daily baseline | Verdict |
|---|---|---|---|
| Workers CPU | 10ms/invocation | <5ms per dispatch | ✅ |
| Workers subrequests | 50 (free) / 1000 (paid) per invocation | ~3 per callback | ⚠️ drain loops constrained on free |
| Workers Cron | Unlimited | 1/min | ✅ |
| CF Queues | 1M msgs/month (~33k/day) | ~45k/day + retries | ❌ exceeds free; ~$0.54/mo paid |
| Durable Objects | 100k req/day | ~45k/day + retries | ⚠️ near free limit |

---

## Mapping to cf-gateway-fail-open (thread #254 spec §3.2)

The inbound Worker's `rateLimitHit` fail-open rule — *any KV/infra error → ALLOW, log
structured warning, never propagate 5xx* — applies symmetrically to any CF egress variant:

> Any CF infra error (Queue unavailable, Hyperdrive timeout on secret lookup) **MUST**
> fail-open: fall back to the Supabase EF dispatch path, log a structured warning, never
> block delivery of a financial terminal event.

---

## Verdict

**Phase-1: NOT recommended (viable-with-caveats for Phase-2 only).** Three load-bearing
complications with no Phase-1 payoff:

1. **Producer bridge gap** — cannot eliminate the Supabase EF; `pg_notify` cannot reach CF
   natively; CF Queue always needs a bridge EF.
2. **Dual-state** — CF Queue retry state vs Postgres `callback_attempts` diverges under
   infra errors; admin dead-letter recovery surface (§ADR-9 AM1–AM8) sees stale picture.
3. **Push-path regression** — a pure Cron Worker variant reverts the ratified §ADR-9 D1
   fast path (~100ms → 60s); hybrid still needs the Supabase EF.

§ADR-9's Supabase EF substrate is correct for Phase-1.

---

## Phase-2 triggers + best architecture if triggered

**Triggers (any one suffices):**
- Dispatcher EF CPU saturation at sustained >50k callbacks/day
- Merchant geographic distribution makes CF edge-proximity a measurable delivery-latency SLA
- Supabase EF invocation cost becomes a budget item at scale
- Per-merchant retry schedules required (§ADR-9 D4 Phase-2)

**Best architecture if triggered — CF Queue Consumer hybrid:**

```
pg_notify
  → thin bridge EF  (enqueue to CF Queue only; no dispatch logic)
  → CF Queue Consumer Worker
      → Hyperdrive secret lookup
      → HMAC-SHA256 sign  (§ADR-9 C3)
      → fetch() to merchant endpoint
      → Hyperdrive callback_attempts write-back  (§ADR-9 C6)
      → ack

pg_cron + EF sweep  ← safety net for CF Queue misses (unchanged)
Postgres            ← source of truth for all retry/audit state
```

---

## Proposed ADR addition

**NOT a new standalone ADR.** File as `§ADR-9 §Amendment [deferred] — CF Queue Consumer
Worker Egress Tier`, status `#design-exploration / #not-ratified`. Same decision domain as
§ADR-9 (how `callback_queue` rows become HTTP calls). A standalone ADR would split the
ratification chain.

**Five open questions that block ratification:**
- OQ1: Producer bridge atomicity — `pg_net` is async/fire-and-forget; enqueue is not
  transactional with the Postgres status flip. Acceptable at-least-once tolerance?
- OQ2: `callback_attempts` write-back race — Hyperdrive write fails post-dispatch; attempt
  log gap vs delivery already happened. Acceptable?
- OQ3: Admin resend coupling — `POST /admin/.../resend-callback` must also re-enqueue to CF
  Queue. Shape?
- OQ4: CF Queue paid cost at trigger volume (~$0.54/month at 45k/day baseline; scales
  linearly with retry storm). Acceptable?
- OQ5: Dead-letter dual-state — CF Queue DLQ vs `callback_queue.status`. Bridge design?
