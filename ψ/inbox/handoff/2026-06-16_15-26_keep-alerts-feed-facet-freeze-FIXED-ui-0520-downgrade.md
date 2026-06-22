# Handoff — Keep `/alerts/feed` facet-render FREEZE: root-caused & FIXED (keep-ui 0.53.0 → 0.52.0)

**From:** brew-ops · **Date:** 2026-06-16 15:26 (GMT+7) · **Stack:** AWS `261955339426`, `ap-southeast-1`, ECS cluster `mb-next-keep`
**Corrects my earlier handoff** `2026-06-16_14-37_keep-incidents-not-broken-...` which said "Keep is fine, nothing blocking." That was WRONG about the **feed** — it was genuinely frozen. Now fixed.

## TL;DR
`/alerts/feed` froze on **"Just a second, getting your data…"** — a REAL hard hang (browser main thread pegged), distinct from the earlier `/incidents` false-positive. Root cause = **upstream keep-ui 0.53.0 bug [keephq/keep#6577](https://github.com/keephq/keep/issues/6577)**: the facets sidebar synchronously builds React components for every unique alert-label key; our alerts carry high-cardinality UUID labels (`queue_id`,`source_id`,`event_id`,`merchant_id` — unique per alert), so past ~100 alerts the main thread locks up (>1 GB alloc spike, no yield).

**Fix (deployed & verified):** downgrade **keep-ui 0.53.0 → 0.52.0**, keep keep-api at 0.53.0 — the exact combo the #6577 reporter confirmed works. Task-def **`mb-next-keep:10`**. `/alerts/feed` now renders the 50-row table (screenshot in ~190 ms, no peg); `/incidents` still fine.

## How it was debugged (browser, carefully — the method matters)
The page pegs the renderer so hard that **`page.evaluate`, `page.screenshot`, AND the CDP `Profiler` all hang** (a tight synchronous loop with no yield points). So:
- **Oracle for "is it hung?"** = `page.screenshot({timeout:6000})` — if it *times out*, the thread is pegged (a merely-slow or loader page screenshots fine). Don't rely on `evaluate`; it wedges too.
- **Network proves the kind of hang:** captured every request → after the initial load burst, network went **silent for 40 s** with **0 websocket data frames** ⇒ not a re-fetch storm, not a backend wait → pure client CPU loop.
- **Backend ruled out:** during a clean run `/backend/*` returned **28×200 / 0×500** yet the thread still pegged.
- **Count/cardinality bisection** (via temp presets with `fingerprint in […]` CELs): 0/1/90 alerts render fine, 130 pegs → threshold effect, consistent with #6577. ⚠️ My mid-bisection per-alert results were corrupted by **DB-pool exhaustion** (I hammered the 15-conn pooler — see Gotchas); the reliable facts are the clean 0/1/90-fine, 130-pegs.
- Confirmed the match against **keephq/keep#6577** (open, latest release 0.53.0, same "getting your data" symptom, same facet-sidebar root cause, `ALERT_SIDEBAR_FIELDS` whitelist does NOT help).

## What changed on the infra (all reversible)
1. **Task-def `mb-next-keep:10`** registered = `:9` with ONLY `keep-ui` image `…/keep-ui:0.53.0` → `…/keep-ui:0.52.0`. `keep`(api)=0.53.0 and `soketi` unchanged. (`/tmp/td10.json` is the source.)
2. **Deployed** via `update-service --task-definition mb-next-keep:10 --availability-zone-rebalancing DISABLED --deployment-configuration maximumPercent=100,minimumHealthyPercent=0`. The `min=0/max=100` forces **stop-old-task-FIRST**, which cleanly dodges the 15-conn pool deadlock (no two keep-apis alive at once). Rollout COMPLETED, 1 task.
   - NOTE: AZ-rebalancing must be DISABLED to use `maxPercent<=100`, else `update-service` errors.
3. **Caddy re-pointed** to the new task IP **`172.31.23.250`** (was `172.31.19.122`) — `sudo sed -i 's/OLD/NEW/g' /etc/caddy/Caddyfile && systemctl reload caddy`. The `/incidents→/alerts/feed` band-aid is still removed (from the 14:37 work).
4. Deleted 15 temporary `kx-*` debug presets; only the `feed` preset remains.

**Rollback if needed:** `update-service --task-definition mb-next-keep:9` (+ re-point Caddy to that task's IP). But :9 = the BROKEN keep-ui 0.53.0 — don't.

## Verified (headless, this session)
| URL | result |
|---|---|
| `/alerts/feed` | renders 50-row table, `Showing 1 of 3`, **no peg** (screenshot 192 ms), `Version: 0.52.0` |
| `/incidents` | empty-state "No Incidents Found", no peg |
| `/` | 307 → `/incidents` |
| `:8443/docs` | 200 |
| ECS | `mb-next-keep:10` RUNNING, rollout COMPLETED, keep-ui image = `keep-ui:0.52.0` ✓ |

## ⚠️ Gotchas (current)
1. **Don't go back to keep-ui 0.53.0** until #6577 is fixed upstream (0.53.0 is the latest release as of 2026-06-05; no fix yet). Pin keep-ui at **0.52.0**.
2. **Ephemeral task IP** unchanged: any redeploy → re-point Caddy's 3 upstreams (`/app/*`, `handle{}`, `:8443`) + `systemctl reload caddy`. Current = `172.31.23.250`.
3. **Supabase pooler = 15 conns, Keep holds ~15** → deploys still need stop-old-first (the `min=0/max=100`+AZ-rebalancing-DISABLED recipe above does this automatically). I exhausted the pool earlier with parallel headless sessions — symptom was `EMAXCONNSESSION / max clients / pool_size: 15` in keep logs + HTTP-500 error pages in the UI. It self-recovers once load stops.
4. **AWS `root-boostrap`** (account-root temp grant): used for ECS register/update + EC2 describe + logs. **Revoke after this.**

## Outstanding / for owner
- **Watch keephq/keep#6577** → when fixed, bump keep-ui (and keep-api) back to a matched fixed release.
- Docs (gateway **PR #528**): note keep-ui is pinned to **0.52.0** (UI) / keep-api **0.53.0**, and the `/incidents` redirect is gone.
- Same long-standing infra niceties as before (raise pool / dedicated front EC2 off the ops box / stable Caddy upstream).
- Debug script templates left in `/tmp`: `feed-net.js` (network-silence proof), `feed-profile.js` (CDP profiler), `preset-test.js` (screenshot-timeout hang oracle + cardinality bisection), `verify-feed.js`/`verify-both.js` (post-fix verify), `del-presets.js` (preset cleanup).
