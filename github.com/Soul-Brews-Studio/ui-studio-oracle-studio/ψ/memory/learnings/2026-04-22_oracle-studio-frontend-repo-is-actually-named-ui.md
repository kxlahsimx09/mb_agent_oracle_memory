---
title: oracle-studio frontend repo is actually named `ui-studio-oracle-studio` (upstrea
tags: [brew-ops, repo:cross, studio, fleet, proxy, vite, bun, pattern, ui-studio-oracle-studio, repo-name, 2026-04-22]
created: 2026-04-22
source: Phase 2a fleet-lens implementation 2026-04-22; verified end-to-end with vite dev server + maw-js on :3456
project: github.com/soul-brews-studio/ui-studio-oracle-studio
---

# oracle-studio frontend repo is actually named `ui-studio-oracle-studio` (upstrea

oracle-studio frontend repo is actually named `ui-studio-oracle-studio` (upstream `Soul-Brews-Studio/ui-studio-oracle-studio`, fork `kxlahsimx09/ui-studio-oracle-studio`). The local checkout directory is `oracle-studio` but the remote repo name is `ui-studio-oracle-studio` — not the same.

**Why:** Discovered 2026-04-22 during Phase 2a of fleet-lens. Earlier memory pointed at `Soul-Brews-Studio/oracle-studio` which returns 404. The `ui-studio-` prefix is not obvious from the local path. This tripped me up when checking for the fork.

**How to apply:**

1. When operating on the studio frontend, the local path is `~/Code/github.com/Soul-Brews-Studio/oracle-studio/` but `gh` API calls must use `ui-studio-oracle-studio` for both owners. Example: `gh api /repos/kxlahsimx09/ui-studio-oracle-studio`, not `/repos/kxlahsimx09/oracle-studio`.
2. `git remote -v` in the local checkout reveals the real name — always check there before assuming.
3. `package.json` name field says `"oracle-studio"` which is the npm package name, not the GitHub repo name.

**Related: maw-js proxy pattern for studio consumption.**

The oracle-studio dev server (vite :3000) and prod server (`bin/serve.ts` Bun static server) both proxy `/api/*` → oracle HTTP API at `:47778`. For Phase 2a fleet lens, studio needs to reach **maw-js** at `:3456` which is a DIFFERENT service from oracle. Pattern used:

- Request path prefix: `/api/maw/*`
- Rewritten to `/api/*` so maw's own Elysia `prefix: "/api"` receives the clean path
- In vite.config.ts:
  ```
  proxy: {
    '/api/maw': {
      target: process.env.MAW_API_URL || 'http://localhost:3456',
      rewrite: (p) => p.replace(/^\/api\/maw/, '/api')
    },
    '/api': { target: process.env.ORACLE_API_URL || 'http://localhost:47778' }
  }
  ```
- **Order matters**: `/api/maw` MUST appear before `/api` — first-match wins.
- In bin/serve.ts, the same rewrite logic lives in the fetch handler. Added `--maw` CLI flag and `MAW_API_URL` env override to parallel `--api` / `ORACLE_API_URL`.

**How to apply:**

1. Any new studio page that reads from a non-oracle backend should reuse this `/api/<service>/*` + rewrite-strip pattern rather than inlining the target URL into the browser request (which would break CORS / host-pinning).
2. Keep the same pattern in BOTH `vite.config.ts` (dev) AND `bin/serve.ts` (prod) — studio switches between these silently depending on how it's invoked.
3. Studio client code hits the relative path only: `fetch('/api/maw/fleet/claude')`. No base-URL config in the React tree.

**Scope:** `Soul-Brews-Studio/ui-studio-oracle-studio`. Applies to `src/api/*.ts` clients and `bin/serve.ts` / `vite.config.ts` changes.

---
*Added via Oracle Learn*
