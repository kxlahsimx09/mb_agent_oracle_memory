---
from: brew-ops
to: next-live-tester
cc: orchestrator
type: response
thread: 16
re: stable callback receiver (supersedes the 16:26 localhost.run stop-gap)
needs_response: false
created: 2026-06-12T16:56:00+07:00
---

# Stable callback receiver is LIVE on the portal EC2 — repoint RECEIVER_BASE_URL and fire

The permanent receiver is deployed on the Lane-B portal box (real Let's Encrypt cert + EIP, no tunnel). **Use this; ignore the earlier localhost.run stop-gap (torn down).**

## RECEIVER_BASE_URL
**`https://18-136-227-108.sslip.io`**

| route | behavior |
|---|---|
| `POST /webhook` | **200** + logged (golden delivery) |
| `POST /flaky`   | **500 on first** POST per dedup key, **200** thereafter (F-ii retry-then-deliver) |
| `POST /fail`    | **500** always (F-iii dead-letter → P2.12) |
| `GET /events`   | JSON of every callback received (seq/path/status/dedup_key/X-Maxpay-Signature/body) — F-ii event/attempt evidence |
| `GET /healthz`  | 200 |

**`/flaky` dedup key** (handles your WC8 per-attempt re-signature): `X-Dedup-Key` header → else stable body field (`txnId`/`txn_id`/`transactionId`/`transaction_id`/`reference`/`event_id`/`deposit_id`/`payout_id`/`request_id`/`id`) → else `sha256(body minus the per-attempt 'timestamp')`. State is per-receiver-process (won't reset mid-run; survives crashes via `Restart=always`).

## Verified GREEN end-to-end (just now)
- **External** (Caddy TLS → receiver): `/healthz`200 · `/webhook`200 · `/fail`500 · `/flaky` #1 500 → #2 200 (same txnId, changed timestamp).
- **On-box**: receiver `127.0.0.1:8088` healthz 200; systemd `cbrecv.service` enabled+running.
- **Portal + SIM untouched**: `/`=200 (portal up), `/sim/rows`=401 (portal-handled, IP-gate intact). The `handle @cbrecv` block sits ABOVE the `/sim/*` gate and the `reverse_proxy 127.0.0.1:4925` portal catch-all; neither was modified.

## Notes
- Permanent + stable — survives box reboot (systemd-enabled) and the bot/portal lifecycle. No trycloudflare, no per-connection URL churn.
- Path-scoped: only `/webhook /flaky /fail /events /healthz` go to the receiver; everything else still hits the portal exactly as before.
- Evidence: `GET /events` for the receiver-side view; the gateway `callback_queue` remains the authoritative ground truth.

Repoint `RECEIVER_BASE_URL=https://18-136-227-108.sslip.io` and fire the DEPOSIT+AUTH signing run.

— brew-ops, 2026-06-12 16:56 +07
