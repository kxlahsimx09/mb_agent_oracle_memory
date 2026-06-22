# Handoff — Keep dashboard UI deployed & WORKING; one open issue (/incidents page hangs)

**From:** brew-ops · **Date:** 2026-06-16 14:20 (GMT+7) · **Stack:** AWS acct `261955339426`, `ap-southeast-1`, ECS cluster `mb-next-keep`
**Owner ask that started this:** "deploy a Keep dashboard UI on ECS connected to the backend, accessible from the internet with login."

## TL;DR — current state
Keep is **LIVE, internet-accessible, with login, and the alerts view WORKS**:
- URL **`https://3-1-0-33.sslip.io`** → login → lands on **`/alerts/feed`** (renders, no hang — **verified with a headless browser**, not guessed).
- Login: `admin` / password in fleet-secret **`keep-admin.env`** (see Secrets below).
- REST API + websocket + the harness integration (`KEEP_ALERTS_API`) all work.

**THE ONE OPEN ISSUE for you:** Keep's **`/incidents` page hangs forever on "getting your data"**. It is Keep's default post-login landing page, so it *looked* like everything was broken. I **band-aided it with a Caddy redirect** `/incidents → /alerts/feed` so users land on the working feed. **Your job: figure out why `/incidents` hangs and fix it properly (then the redirect can be removed).**

## The open issue in detail — `/incidents` hangs
Proven via headless Playwright (the fast debug method — see below):
- Login → default landing `/incidents` → body contains "getting your data" forever (`STUCK=true`).
- Navigate to `/alerts/feed` → `STUCK=false`, renders.
- The **websocket WORKS on both**: `WS← pusher:connection_established` then `WS→ pusher:subscribe {channel: private-keep}` then `WS← pusher_internal:subscription_succeeded`. So transport + channel auth are fine.
- All `/backend/*` REST calls return **200** (`preset`, `alerts/query`, `dashboard`, `incidents`, `incidents/facets/options`, `incidents/meta`, `pusher/auth`, `topology`).
- The `?_rsc=` `net::ERR_ABORTED` you'll see are Next.js **nav-menu prefetch cancellations — benign** (the feed renders despite them).
- So `/incidents` waits for *something extra* that `/alerts/feed` doesn't — most likely an incident-specific websocket **data push** that never arrives (0 incidents in the DB), or an AI/correlation step. `PUSHER_DISABLED=true` did NOT give a REST fallback (Keep 0.53 still waits for the socket — confirmed). **Next step:** headless-capture the `/incidents` WS frames *after* subscription_succeeded + the exact request left PENDING, and/or check Keep's AI/incident-poll config.

## How to debug FAST (the key tool — use this, don't guess blind)
Drive a **headless Chromium with Playwright** that's already on this box (the live-test harness uses it). This shows you exactly what the browser sees (WS frames, console, network) — it's how I found the `/incidents` vs `/alerts/feed` split.
```bash
HARNESS=/home/ubuntu/Code/github.com/kxlahsimx09/mb-next-payment-gateway.wt-1-live/poc/integration
PW=$(grep '^KEEP_DEFAULT_PASSWORD=' ~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/keep-admin.env | cut -d= -f2)
NODE_PATH="$HARNESS/node_modules" KPW="$PW" timeout -s KILL 40 node /tmp/your-script.js
```
- `require('playwright')` resolves via `NODE_PATH` (script lives in /tmp, so NODE_PATH is required).
- Capture `page.on('websocket', ws => ws.on('framereceived'/'framesent', ...))`, `page.on('console')`, `page.on('requestfailed')`, `page.on('response')`.
- **Always add a hard `setTimeout(()=>{writeFile;process.exit(0)}, 30000)`** and write output to a FILE — `/incidents` hangs the page, so `waitUntil:'networkidle'` and piping through `head` both wedge; the timed-out node + chromium ignore SIGTERM. Templates left at `/tmp/keep-debug.js`, `/tmp/keep-debug2.js`, `/tmp/kf.js`, `/tmp/kv.js`. Login selectors: `input[name="username"]`, `input[name="password"]`, `button[type="submit"]`.

## Deployment topology (what exists)
- **ECS service `mb-next-keep`** (cluster same name), task-def **`mb-next-keep:9`** = **3 containers**:
  - `keep` = `…/keep-api:0.53.0` @8080, `AUTH_TYPE=DB`, `DATABASE_CONNECTION_STRING` (secret), `KEEP_JWT_SECRET`==the UI's `NEXTAUTH_SECRET` (REQUIRED or `/signin`→401 "Missing JWT secret"), `PUSHER_*`→localhost soketi, `DATABASE_POOL_SIZE=2`/`MAX_OVERFLOW=3`.
  - `keep-ui` = `…/keep-ui:0.53.0` @3000, `NEXTAUTH_URL=https://3-1-0-33.sslip.io`, `NEXT_PUBLIC_API_URL=https://3-1-0-33.sslip.io:8443`, `PUSHER_HOST=3-1-0-33.sslip.io`, `NEXTAUTH_SECRET`.
  - `soketi` = `quay.io/soketi/soketi:1.4-16-debian` @6001, `SOKETI_HOST=0.0.0.0`, app id/key/secret = `1`/`keepappkey`/`keepappsecret`.
- **Backend store = Postgres** (NOT sqlite anymore): schema **`keep`** in the sinuw project (`sinuwgsqqyqzlpaavimf`), role **`keep_rw`** (`search_path=keep`), **session pooler `aws-1-ap-southeast-1.pooler.supabase.com:5432`**, injected as Secrets-Manager secret **`mb-next-keep-db`** → `DATABASE_CONNECTION_STRING`.
- **Front = Caddy on the ops box** `oracle-runner` `i-0a04dc349691324dd` (stable **EIP `3.1.0.33`** → `3-1-0-33.sslip.io`, Let's Encrypt). Caddyfile `/etc/caddy/Caddyfile`, systemd unit `caddy`. Routes: 443 `/app/*`→soketi:6001 (the browser connects `wss://3-1-0-33.sslip.io/app/keepappkey` — port 443, /app path, NOT :6001), `/incidents*`→redirect `/alerts/feed` (the band-aid), `/`→keep-ui:3000; `:8443`→api:8080.
- **SGs:** keep SG `sg-0fed3b09f1d59662e` inbound 8080/3000/6001 from ops-box SG `sg-0719678a0c780f3e9` (+ 8.245.7.85/32 on 8080). Ops-box SG inbound 80/443/8443/6001 from `0.0.0.0/0` (internet — OK because Keep DB-login is the auth boundary).

## ⚠️ Gotchas (will bite you)
1. **Task IP is EPHEMERAL** (no ALB) → after ANY redeploy you MUST re-point Caddy's 3 upstreams to the new private IP + `sudo systemctl reload caddy`. Re-resolve: `aws ecs list-tasks…describe-tasks…ENI…describe-network-interfaces PrivateIpAddress`. No dedicated front EC2 because **EC2 On-Demand vCPU is 8/8 full** (r7i.xlarge ops box + 2× t4g.nano bank portals).
2. **Supabase pooler connection limit = 15 (session mode), Keep holds ~15** (multiple engines; `DATABASE_POOL_SIZE` barely helps). So **deploys DEADLOCK**: the old task holds 15 conns, the new task can't connect → fails. **Fix at deploy time: `aws ecs stop-task` the OLD task right after `update-service` to free conns so the new one boots.** Symptom of exhaustion in logs: `psycopg2 … EMAXCONNSESSION max clients … pool_size: 15` → HTTP 500 everywhere.
3. **Do NOT switch to the transaction pooler (`:6543`)** — Keep's migrations crash on it (`keep` container exit 1, crash-loop). Stay on `:5432` session pooler.
4. **`PUSHER_DISABLED=true` does NOT give a REST-polling feed** in Keep 0.53 — the feed still hard-waits on the websocket. Keep the websocket (soketi) enabled.
5. Caddy one-line site blocks `site { directive }` fail to parse — use multi-line blocks.

## Secrets / where things live (durable)
- **Admin login + NextAuth secret:** `~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/keep-admin.env` (chmod 600). Source of truth for the password is the **hash in `keep.user`** (sha256) — plaintext only in this file + (regrettably) chat.
- **DB connstring (keep_rw):** Secrets-Manager `mb-next-keep-db` (+ ephemeral `/tmp/keep-db.conn`).
- **Harness Keep query:** slot `~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/slots/staging.env` → `KEEP_ALERTS_API=https://3-1-0-33.sslip.io:8443/alerts` + real `KEEP_API_KEY` (a `keep.tenantapikey`, sha256). NOTE: the harness key was minted under NO_AUTH originally then re-minted as a real tenantapikey when we flipped to DB-auth.
- **AWS:** used profile **`root-boostrap`** (account root, the temp grant noted in `stack-topology.md`) — **revoke after this work**.

## Outstanding / for owner
- **FIX `/incidents` hang** (this handoff's purpose) → then drop the Caddy `/incidents→/alerts/feed` redirect.
- Connection-pool efficiency (Keep hogs 15; every deploy needs manual old-task stop) — consider a dedicated/raised pool or a Keep-state isolation.
- Stable Caddy upstream (service-discovery / NLB) so redeploys don't need a manual Caddy re-point; move the front off the ops box to a dedicated EC2 once vCPU frees (interim exposure of the crown-jewels box).
- Docs: `docs/stack-topology.md` + `docs/design/monitoring/keep-deployment.md` updated in **gateway PR #528** (awaiting owner merge); they predate the soketi/UI/Caddy-redirect final shape — update once /incidents is fixed.
- task-def evolution for context: `:2` (NO_AUTH, sqlite) → `:3` DB-auth+pg → `:4` +KEEP_JWT_SECRET → `:5` PUSHER_DISABLED(reverted) → `:6` soketi → `:7` low-pool → `:8` PUSHER_DISABLED+no-soketi(reverted) → **`:9` current** (soketi + pusher + low-pool + 5432). Several `:N` are dead ends kept for history.
