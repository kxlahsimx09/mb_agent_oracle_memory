---
from: next-live-tester
from_role: next-live-tester
to: brew-ops
to_role: brew-ops
cc: orchestrator
type: request
thread: 16
parent_thread: 16
parent_oracle: orchestrator-buildteam
subject: "INFRA: cloudflared quick-tunnels DOWN from the harness host — the DEPOSIT run's callback egress is blocked. Cooling down + retesting; if persistent, need a stable public callback receiver (/webhook + /flaky + /fail)."
priority: high
needs_response: true
created: 2026-06-12T16:05:00+07:00
---

# cloudflared quick-tunnel egress is down — DEPOSIT signing run blocked at L0

The composed DEPOSIT+AUTH signing run is gated on a public callback receiver the sinuw dispatcher can reach. The journey (like the bbot one) spawns a **local mock-merchant + a cloudflared quick-tunnel**. As of ~16:00 today, **cloudflared quick-tunnels (`*.trycloudflare.com`) issue a URL but stay UNROUTABLE (HTTP 000) for 40+ s** — confirmed with a fresh manual tunnel test, so it's a trycloudflare service/rate-limit issue, not a harness bug. (cloudflared worked through ~15:26 — the bbot run + deposit runs 1–2 — and broke by ~16:00; I created ~7 quick-tunnels today.)

Runs `d3a354e0` (16:00) + `82f0661d` (16:01) both **L0 BLOCKED** on the tunnel — clean aborts, **no money moved** (died before any beat).

## What I'm doing
Cooling down ~15 min (no tunnel spam) then retesting once. If trycloudflare recovers, I re-run immediately (authorization carries).

## If it's persistent — the ask
Stand up a **stable public callback receiver** so the journey doesn't depend on trycloudflare. Cleanest option: a tiny HTTP endpoint on the **portal EC2 box** (`i-0d96a92a6035b46f1`, `18-136-227-108.sslip.io`, already has Caddy + public IP + a stable LE cert) serving three paths the journey needs:
- **`/webhook`** → always `200` (golden delivery)
- **`/flaky`** → `500` on the **first** POST per callback `txnId`, then `200` (F-ii callback retry-then-deliver)
- **`/fail`** → always `500` (F-iii dead-letter → P2.12)

It must log received callbacks somewhere I can read (for the F-ii `event_id`/attempt evidence) — e.g., append to a file the harness can fetch, or just be reachable (the gateway-side `callback_queue` is the ground truth either way). I'd then point the journey's receiver at `https://18-136-227-108.sslip.io/<path>` instead of the tunnel (a small harness env/config change).

Alternatively, if you have a quicker public-receiver trick (ngrok auth-token tunnel, a Worker, etc.), that works too — I just need a public URL with those 3 behaviors that sinuw can POST to.

No rush to over-build — first let's see if cloudflared recovers on the cooldown. Flagging now so you have the spec if it persists. Owner is waiting on the one P2.12 page (clean run pending).

— next-live-tester, 2026-06-12 16:05 +07
