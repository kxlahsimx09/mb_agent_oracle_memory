---
title: poc-correction: Phase B mock-merchant-as-EF was a test-substrate divergence — re
tags: [poc-implement, repo:mb-next-payment-gateway, next, poc, phase-b-substrate-parity-fix, cloudflare-tunnel, wan-ingress, ef-to-ef-anti-pattern, callback-dispatcher, production-realistic-baseline, test-substrate-divergence, mock-merchant-deployment, session-2026-05-10]
created: 2026-05-10
source: poc/integration/src/run-hosted.ts (spawnTunnel + spawnMerchant + setMerchantUrl) + evidence/integration-hosted-run-2026-05-10T07-{33,40}-*-hosted-{tiny,default}.json @ commit d32d056; addendum to learning_2026-05-10_poc-ready-integration-poc-deposit-withdraw-la
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-correction: Phase B mock-merchant-as-EF was a test-substrate divergence — re

poc-correction: Phase B mock-merchant-as-EF was a test-substrate divergence — re-running with Bun mock + Cloudflare tunnel produces production-realistic baseline (callback p99 29× lower, no retry tail, 0 dead_letter).

Addendum to: learning_2026-05-10_poc-ready-integration-poc-deposit-withdraw-la

# Issue

The first Phase B run deployed mock-merchant as a 9th Edge Function inside the same Supabase project (chosen as workaround when Cloudflare Quick Tunnel API returned transient 500). This made the dispatcher's HTTP-out path test "Supabase-internal EF→EF routing" instead of "real WAN egress to external merchant". Three things distorted measurement:

1. **Cold-start variance per EF invocation** — every dispatch may hit a cold mock-merchant instance (~100-200ms), unlike a long-running merchant server.
2. **Per-call TLS handshake within Supabase** — internal but still encrypted; no QUIC session reuse benefit.
3. **No real WAN hops** — Singapore→Singapore inside same project is faster than Singapore→external-merchant in different region/infra.

Result: occasional 5xx responses from cold/slow EF cold-start triggered the cron retry path (1-min wait between retries), creating tail latency that didn't reflect production.

# Correction

Reinstated Phase A's approach: Bun mock-merchant local on :3011 + cloudflared Quick Tunnel (with 3-attempt retry to handle transient API 500s like the one that originally caused the workaround). orchestrator PATCHes merchant_config.callback_url to per-session tunnel URL before fixture loader starts. mock-merchant EF retained in supabase/functions/ as fallback but unused.

# Comparison (default 100/50 fixture, hosted, SPEED=10x)

|                                 | EF→EF path (flawed) | Tunnel + Bun (correct) | Δ                |
|---------------------------------|--------------------:|-----------------------:|------------------|
| assertions                      | 17/17 pass          | 17/17 pass             | same             |
| deposits paid / expired / failed| 87 / 8 / 5          | 87 / 8 / 5             | same             |
| callbacks delivered             | 149                 | 150                    | +1 (no dead_letter) |
| callbacks dead_letter           | 1                   | 0                      | retry tail gone  |
| **callback p50**                | 1191 ms             | 540 ms                 | **55% faster**   |
| **callback p90**                | 34226 ms            | 1311 ms                | **26× faster**   |
| **callback p99**                | 50832 ms            | 1744 ms                | **29× faster**   |
| callback max                    | 53445 ms            | 1870 ms                | 28× lower        |
| **quiescence after loader exit**| 45.8 s              | 159 ms                 | **288× faster**  |
| stmt_push→match p50             | 35 ms               | 36 ms                  | same             |
| deposit→paid p50                | 11561 ms            | 11539 ms               | same             |
| payout→completed p50            | 8514 ms             | 8349 ms                | same             |
| fair-router LRU                 | scb=8/ktb=8/kbank=7 | scb=8/ktb=8/kbank=7    | same             |

The non-callback metrics are unchanged because they don't depend on the merchant network path.

# Why the tunnel path is more production-realistic

- **Bun process is single warm instance** — same shape as a real merchant server (long-lived process, no per-request cold-start). Real merchants are not deployed as Supabase EFs.
- **cloudflared QUIC connection is persistent** — TLS session cached at edge after first handshake. Subsequent dispatches reuse the connection. Real-world HTTPS clients (in EFs) typically pool connections to merchant URLs.
- **Cloudflare BKK edge is geographically close to Supabase Singapore region** — adds realistic but small WAN latency (~5-15ms RTT). A merchant in eu-central or us-east would add 100-300ms more.
- **Real DNS lookup + TLS** is now in the path (was bypassed in EF→EF). DNS lookups for trycloudflare.com are cached after first resolution.

# Lessons

1. **Test infrastructure deployed as EF is a substrate divergence**. Even when the EF code is clearly test-named (mock-merchant), running it inside the substrate-under-test creates noise that distorts measurement. Specifically: any time the test rig sends HTTP from substrate to substrate-internal target, the latency profile is wrong.
2. **Quick-fix workarounds for transient infra failures must be temporary**. Cloudflare Quick Tunnel API 500 was a one-off. Retrying with 3-attempt backoff handles transient errors without replacing the substrate path.
3. **Tail-latency metrics are extra-sensitive to substrate divergence**. p50 was 2× off (acceptable), but p99 was 29× off (pathological). When measuring tail behavior, substrate parity is essential.
4. **Verify with at least one alternative path** before publishing latency baselines. The "EF mock vs tunnel" comparison only became visible after running both — initial Phase B numbers looked plausible until contrasted.

# What this means for the original Phase B baseline

The original learning_2026-05-10_poc-ready-integration-poc-deposit-withdraw-la is ARCHITECTURALLY ACCURATE (substrate features verified, fair-router LRU works, 17/17 assertions pass) but its callback-latency claims are MEASUREMENT-FLAWED. The architectural validity stands; the latency baseline should be replaced with the tunnel-path numbers above.

Both runs are reproducible and committed. The tunnel path is now the default in run-hosted.ts.

# Pointers

- Phase B substrate parity fix commit: d32d056
- Run script (tunnel path): poc/integration/src/run-hosted.ts (spawnMerchant + spawnTunnel + setMerchantUrl)
- Tunnel-path evidence (default 100/50): poc/integration/evidence/integration-hosted-run-2026-05-10T07-40-33-172-hosted-default.json
- Tunnel-path evidence (tiny 10/5): poc/integration/evidence/integration-hosted-run-2026-05-10T07-33-56-704-hosted-tiny.json
- Stale EF-path evidence: poc/integration/evidence/integration-hosted-run-2026-05-10T05-54-26-897-hosted-default.json (kept for diff reference)
- Original learning: learning_2026-05-10_poc-ready-integration-poc-deposit-withdraw-la
- Cloudflare BKK edge connection log: /tmp/cloudflared.log (per-session)

---
*Added via Oracle Learn*
