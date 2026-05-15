---
title: Writer reasoning error instance #2 — framing-vs-production-latency caught by arc
tags: [next-product-writer, repo:mb-next-payment-gateway, next, writer-discipline, fabrication-detection, production-grounded-rationale, deposit-008, call-shape-sync-vs-async, thread-92-closed, instance-2-of-pattern, verify-production-before-framing, sibling-of-day-bound-instance-1]
created: 2026-05-12
source: docs/requirements/epic-deposit.md DEPOSIT-008 + arra_thread:#92 + docs/adr.md §ADR-4d D8 sub-amendment 2026-05-12 + PR #75 c52cf32
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Writer reasoning error instance #2 — framing-vs-production-latency caught by arc

Writer reasoning error instance #2 — framing-vs-production-latency caught by architect's dpay audit.

## Pattern surfaced (strengthening at instance #2)

When building an architectural option matrix for a writer-flagged unratified surface, **the writer must verify the relevant production metric (latency / rate / volume / error rate) on the closest production analog BEFORE assigning weights to UX trade-offs in the options.** Otherwise the matrix carries writer-imagined worst-case framing as if it were typical, and the architect's first move (the right one) is to verify the actual distribution.

## Concrete instance (2026-05-12)

DEPOSIT-008 verify-slip-now sync-vs-async call-shape thread #92:

**Writer framing in the option matrix (PR #74, thread #92 opening):**
> "Sync = admin UI loading spinner for 2–30 seconds while Thunder responds; queue freezes; admin can't move on."

Recommended **option C (async + Realtime + 30s cooldown)** on substrate-alignment grounds.

**Architect's first move (thread #92 closing):**
- Ran dpay MCP on `/api/v1/deposits/:id/upload-slip` (closest production analog — mobiz calls Thunder inline at upload time)
- Found: p50 ≈ 600ms · 77% < 1s · 88% < 2s · 99% < 30s · only 1.6% > 30s tail · zero rapid-fire abuse across 282 calls/day
- Ratified **option A (sync default Phase-1)** with explicit Phase-2 async-via-Realtime triggers (p99 > 10s sustained / Thunder 500-rate > 10% sustained / concrete business driver)

The writer's "2-30s blocking" framing was worst-case, not typical. Sync UX is comfortable for the 88% sub-2-second majority. Async + Realtime would have been over-engineered for the 1.6% tail.

## Generalization (pattern for future passes)

When the writer opens a thread asking "sync vs async?" or "should we cache this?" or "rate-limit needed?" or any question whose answer depends on **how often / how slow / how big**, the writer's first action is to run the production-metric query against the closest analog and bake the result into the option matrix as a column. If the writer doesn't, the architect will — and the option matrix will be re-weighted in the close-out post.

**Concrete rule:** before opening a thread on `<endpoint shape> / <cache strategy> / <rate-limit> / <retry policy>`, run at minimum one of:
- `apilogs` / `audit_trail` aggregate on the closest production analog endpoint — find p50/p90/p99/error-rate
- `<entity>` collection volume + per-day distribution — find typical vs peak
- `<event_log>` for the abuse pattern the option is meant to prevent — find if it exists in production

Then bake these numbers into the option-matrix rows as a "production reality" column.

## Sibling pattern (instance #1 — 2026-05-12 day-bound window)

In day-bound-window writer reasoning error: I wrote two reasons for the BKK-day boundary ("physical settlement" + "false-positive control") without verifying the hash algorithm. The hash composition already included minute-level timestamp → cross-day collisions were structurally impossible → my two reasons were plausible-but-wrong.

Same root cause as this instance: **plausible-sounding rationale/framing without verifying the actual artifact (algorithm in instance #1; production latency in instance #2).** Different surfaces (algorithm vs production data) but same writer-discipline gap.

## Pattern accumulation

- **Instance #1 (2026-05-12):** day-bound rationale-vs-algorithm — caught by user reading and pushing back on the rationale
- **Instance #2 (2026-05-12):** call-shape framing-vs-production-latency — caught by architect running dpay audit at thread close

Both instances within the same session day; both on DEPOSIT-007/008 second-pass review. The pattern is now durable. Promotes to writer discipline `verify-production-or-algorithm-before-framing-rationale` (alongside existing `verify-claim-against-source-before-writing-it`).

## arra trace

- Thread #92 closed 2026-05-12 07:31 UTC
- Architect learning: `learning_2026-05-12_w1-sub-amendment-ratify-adr-4d-d8-call-shape-sync-default-thread-92-closed`
- Writer PR #74 updated 2026-05-12 to apply architect handoff (sync Phase-1; Phase-2 triggers as edge cases; rate-limit deferral restored)
- Writer learning #1 (instance #1): `learning_2026-05-12_writer-reasoning-error-caught-by-user-plausible-s`
- Writer learning #2 (this entry): captures generalization across both instances

## Personal note (writer voice)

The first instance I framed as "rationale vs algorithm". The second was "framing vs production". Both feel like the same shape from a different angle. Going forward: any sentence in a story body or thread opening that includes a number (latency, rate, threshold, percentage, volume) or a UX assertion ("blocks", "freezes", "wastes") needs a one-line source — either a verified code reference or a production metric query. If I can't cite it, I shouldn't write it.

---
*Added via Oracle Learn*
