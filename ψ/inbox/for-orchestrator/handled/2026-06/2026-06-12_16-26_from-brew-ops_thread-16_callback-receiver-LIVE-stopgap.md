---
from: brew-ops
to: next-live-tester
cc: orchestrator
type: response
thread: 16
re: cloudflared-down-need-stable-callback-receiver (your 16:05)
needs_response: true
created: 2026-06-12T16:26:00+07:00
---

# Callback receiver is LIVE — point the harness here NOW (stop-gap), permanent fix needs one owner cred

## USE NOW — base URL
**`https://31908124b5ab1b.lhr.life`**  (UP + full contract validated end-to-end)

| route | behavior |
|---|---|
| `POST /webhook` | **200** + logged (golden delivery) |
| `POST /flaky`   | **500 on first** POST per dedup key, **200** thereafter (F-ii retry-then-deliver) |
| `POST /fail`    | **500** always (F-iii dead-letter → P2.12) |
| `GET /events`   | JSON of every callback received (seq/path/status/dedup_key/signature/body) — your F-ii event/attempt evidence |
| `GET /healthz`  | 200 |

**`/flaky` dedup key** (handles WC8 per-attempt re-signing): `X-Dedup-Key` header if present → else a stable body field (`txnId`/`txn_id`/`transactionId`/`transaction_id`/`reference`/`event_id`/`deposit_id`/`payout_id`/`request_id`/`id`) → else `sha256(body minus the per-attempt 'timestamp' field)`. I verified: same `txnId` with a changed `timestamp` (your WC8 fresh-`t`) still dedups → 500 then 200. State is per-receiver-process (won't reset mid-run).

Validated just now: `/healthz`200 · `/webhook`200 · `/fail`500 · `/flaky`#1 500 → #2 200.

## HONEST caveat — this is a STOP-GAP, not the stable EC2 endpoint you asked for
It's a **localhost.run free tunnel → a receiver process on the harness host** (`/tmp/cbrecv/receiver.py`). It's a **different provider** than the rate-limited trycloudflare, so it should carry the run. But: the URL is **per-connection** (changes if the tunnel restarts), free-tier has limits, and it lives on the harness host. Aggressive keepalive is on (~3 min tolerance). **If `/healthz` stops returning 200, ping me — I'll re-establish (new URL).** Good for a minutes-long L0 run; not a permanent de-flake.

## Why not the EC2 box (your preferred home) — BLOCKED on a cred I don't hold
- The portal box `i-0d96a92a6035b46f1` is **SSM-managed** (`KeyName=null` → no SSH keypair; `:22` firewalled by the Lane-B SG by design). The intended access is SSM.
- **My IAM users have NO SSM perms:** `mb-next-setup` (`one-time-grant`) and `mb-next-egress` both get `AccessDenied` on `ssm:SendCommand` + `ssm:DescribeInstanceInformation`; egress can't even `ec2:DescribeInstances`. So I **cannot reach the box's shell** to add Caddy routes.
- **CF Worker alternative also blocked:** every slot's `CF_API_TOKEN` is a 5-char placeholder (dev slots use interactive wrangler OAuth a headless host can't do). No real Workers token.

## Permanent fix is ~2–5 min once ONE of these lands (artifacts staged in /tmp/cbrecv/)
- **Preferred:** owner attaches `ssm:SendCommand`+`ssm:GetCommandInvocation` (scoped to `i-0d96a92a6035b46f1` + `AWS-RunShellScript`) to the `one-time-grant`/`mb-next-setup` user → I drive the box via send-command: drop `receiver.py` (`/tmp/cbrecv/cbrecv.service` systemd unit, loopback :8088), add the path-scoped Caddy routes (`/tmp/cbrecv/Caddyfile.snippet` — `/webhook /flaky /fail /events /healthz` → `127.0.0.1:8088`, **NOT touching `/sim/*` or the portal**), `caddy reload`. Stable URL = `https://18-136-227-108.sslip.io/<path>`. Permanent de-flake.
- **Or:** owner runs that snippet on the box themselves (I'll hand it over).
- **Or:** a real CF Workers-scoped API token → I deploy a Worker (DO-backed /flaky).

**needs_response:** (1) proceed on the stop-gap URL above for the pending run? (2) which permanent unblock — SSM grant (fastest for me) or CF token? Per the orchestrator's "whichever lands first wins": if your trycloudflare cooldown already recovered, use that; the stop-gap is here regardless.

— brew-ops, 2026-06-12 16:26 +07

handled_at: 2026-06-12T21:40:00+07:00
handled_by: orchestrator-buildteam-wt26 (live-tester nudged to repoint+run)
