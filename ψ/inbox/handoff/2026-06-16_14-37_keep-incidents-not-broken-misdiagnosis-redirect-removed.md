# Handoff — Keep `/incidents` was NEVER broken (false-positive in the debug harness); band-aid redirect REMOVED

**From:** brew-ops · **Date:** 2026-06-16 14:37 (GMT+7) · **Stack:** AWS `261955339426`, `ap-southeast-1`, ECS cluster `mb-next-keep`
**Resolves:** `2026-06-16_14-20_keep-ui-deployed-incidents-page-hang.md` (the "`/incidents` hangs on getting your data" handoff)

## TL;DR — there was no bug to fix
Keep's `/incidents` page **works perfectly**. It renders the empty state **"No Incidents Found / No active incidents found"** in **1.2 s** after navigation (measured headless). The "hang on *getting your data*" reported in the prior handoff was a **false positive in the debug script**, not a Keep defect.

**Action taken:** removed the Caddy `/incidents → /alerts/feed` band-aid. Users now land on the real Incidents dashboard after login. **No ECS redeploy, no task-def change, no DB change** — Keep was untouched, so the deploy-deadlock/pool gotchas never applied.

## Root cause of the misdiagnosis (important — this will bite the next debugger too)
The prior debug scripts (`/tmp/keep-debug*.js`, `/tmp/kf.js`, `/tmp/kv.js`) detected "stuck" with:
```js
const body = await page.textContent('body');   // ← includes <script> contents
body.toLowerCase().includes('getting your data')  // → true, but INVISIBLE
```
`Node.textContent` concatenates **every** node, including inline `<script>`. Next.js streams the page's React-Server-Component payload into inline `<script>self.__next_f.push([...])</script>` tags, and that payload contains the serialized text of the route's `loading.tsx` Suspense fallback — for the incidents route that fallback string is **"Getting your data"**. So `textContent` matched a `display:none`, 0×0 `<script>`, never a visible loader.

`/alerts/feed` uses a *different* loading fallback (a skeleton, no "Getting your data" text), so its flight payload didn't contain the magic string → the same detector returned `STUCK=false`. That asymmetry is the entire illusion that `/incidents` alone was broken. **Both pages were always fine.**

### Proof (headless, this session)
| Signal | Value |
|---|---|
| empty-state ("No Incidents Found") visible after nav | **1.2 s** |
| OLD detector — `body.textContent` has "getting your data" | `true` (the hidden `<script>`) |
| `body.innerText` (what the user actually sees) has "getting your data" | **`false`** |
| `body.innerText` has "No Incidents Found" | `true` |
| visible `.animate-spin` spinners (w>0,h>0) | **0** |
| pending/never-finished requests at 30 s | **none** |
| all `/backend/incidents*` responses | **200**, valid JSON, `count:0, items:[]` (0 incidents in DB; feed has 130 alerts) |
| post-login default landing | `/incidents?facet_status='firing','acknowledged'` → renders empty state, no manual nav |

Screenshots: `/tmp/incidents.png`, `/tmp/incidents-landing.png` (fully-rendered dashboard, facets panel, "Create Incident", footer `0.53.0 | Build 502f38`).

## The fix (what changed on the box)
**Only `/etc/caddy/Caddyfile`** on ops box `oracle-runner` (`i-0a04dc349691324dd`, EIP `3.1.0.33`). Removed the `@inc` redirect block; reloaded caddy. Now:
```
3-1-0-33.sslip.io {
    handle /app/* { reverse_proxy 172.31.19.122:6001 }   # soketi ws
    handle       { reverse_proxy 172.31.19.122:3000 }    # keep-ui
}
3-1-0-33.sslip.io:8443 { reverse_proxy 172.31.19.122:8080 }  # keep api
```
Backup of the pre-fix (with-redirect) Caddyfile: `/etc/caddy/Caddyfile.bak.keepfix-1781594934`.
Live health verified: `/` → 307 `/incidents`; `/incidents` → 307 `/signin` (NextAuth, **not** the old 302→feed); `/alerts/feed` 307 signin; `:8443/docs` 200; caddy `validate` OK.

> Caddy upstream IP is still `172.31.19.122` = current task `:9` private IP. The gotcha stands: **any redeploy = re-point these 3 upstreams + `systemctl reload caddy`** (IP is ephemeral, no ALB).

## How to debug Keep UI FAST (corrected method — do this, don't repeat the textContent trap)
Same harness as before, but **assert on `innerText` / a real selector, never `textContent`**:
```bash
HARNESS=/home/ubuntu/Code/github.com/kxlahsimx09/mb-next-payment-gateway.wt-1-live/poc/integration
PW=$(grep '^KEEP_DEFAULT_PASSWORD=' ~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/keep-admin.env | cut -d= -f2)
NODE_PATH="$HARNESS/node_modules" KPW="$PW" timeout -s KILL 60 node /tmp/your-script.js
```
- "Is it stuck?" → `await page.evaluate(() => document.body.innerText)` (excludes `<script>`), or `await page.locator('text=Getting your data').isVisible()`, or take a screenshot. Never `page.textContent('body')`.
- Templates from this session left in `/tmp`: `inc-debug.js` (WS frames + pending map), `inc-debug2.js` (response bodies + DOM chain), `inc-debug3.js` (screenshot + visibility), `inc-proof.js` (the innerText-vs-textContent proof), `inc-final.js` (fresh-login landing). Login selectors unchanged: `input[name="username"]`, `input[name="password"]`, `button[type="submit"]`.

## Outstanding / for owner
- **Nothing blocking on Keep.** It is LIVE, internet-accessible, login works, both `/incidents` and `/alerts/feed` render. Default landing is now the real Incidents dashboard.
- **Docs (gateway PR #528):** the prior handoff said docs there describe the `/incidents→/alerts/feed` redirect as the final shape. That redirect is now **gone** — update `docs/stack-topology.md` + `docs/design/monitoring/keep-deployment.md` to drop it (and drop the "/incidents hangs, band-aided" note) before/at merge.
- **AWS `root-boostrap` profile** (account-root temp grant): I used it for **read-only** ECS/EC2/logs describe only. Still safe to **revoke** per the prior handoff.
- Still-open infra niceties (unchanged from prior handoff, not bugs): Supabase pooler 15-conn limit forces manual old-task stop on deploy; ephemeral task IP forces manual Caddy re-point; front still on the ops box pending free vCPU.
