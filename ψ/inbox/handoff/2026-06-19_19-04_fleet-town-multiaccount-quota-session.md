---
from: brew-ops
date: 2026-06-19T19:30:00+07:00
topic: Fleet Town — ambient art + multi-account (web-auth) spawn/switch + real quota page
status: ALL DEPLOYED + LIVE + verified end-to-end; code pushed; formal-PR debt to close
tags: [#repo:cross, #fleet, #studio, #maw-js, #brew-ops, #handoff, #multi-account]
---

# Fleet Town session handoff (2026-06-19)

Long build session extending `/town` (oracle-studio, live at https://town.3-1-0-33.sslip.io). Everything below is **DEPLOYED + LIVE** (fleet-town.service active, town 200) and verified. See memory `[[fleet-town-viz-plan]]` for the full durable record (updated).

## What shipped (all live)
1. **Ambient art**: Cainos "Pixel Art Top Down - Basic" set — grass/cobble/dirt/water/wood/brick/+ floor textures (per-zone 🎨 picker, localStorage), 32 recolored folk character sprites (8×4 hue palettes), Cainos statue landmark (replaced ai-town windmill), campfire hearth at each team centre, drag = pause-then-resume.
2. **PWA + Web Push**: installable; push alerts for whole-team-idle (per-team) + agent-waiting (per-AGENT opt-in); debounced (sustained 90s/20s, not edge); titles name who/which-team; `~/.fleet-town/` VAPID+subs. Endpoint family `/__fleet/push/*`.
3. **Auth = cookie-token** (NOT basic-auth — broke iOS standalone PWA): one-time `/__auth?k=qVy50v5MsyDWqAG` → 1yr cookie `town_auth=t84d7b1578c80411fbe6407ef065bf238e8ff6e6f`. Caddyfile town block rewritten (backup `Caddyfile.bak-*`). OLD basic-auth no longer works.
4. **Staging district** (bottom of page): `server/env-probe.ts` + `env-targets.json` health-checks gateway/portal/supabase → pixel buildings glow by status.
5. **📊 Account quota page** — REAL subscription quota via `GET https://api.anthropic.com/api/oauth/usage` (Bearer `<sk-ant-oat accessToken>` from `<config-dir>/.credentials.json` + `anthropic-beta: oauth-2025-04-20`). Mirrors the CLI `/usage` exactly: `limits[]` (Session 5h / Weekly all-models / Weekly Sonnet), "% used" + reset in GMT+7. Grouped by account email.
6. **Multi-account spawn/switch/badge** — the big one (see below).
7. **Chat**: multiline textarea (Shift+Enter, bracketed-paste so newlines insert), 📋 gist button, clickable links, ⚡ presets (`<prompt>` caret marker + manager, localStorage).

## Multi-account (web-auth) — KEY facts
- **Accounts via `~/.fleet-town/auth-plans.json`** (chmod 600, web-auth only): 3 config-dir plans — Midasgo (`~/.claude-midasgo`, id `default`), Mobiztool (`~/.claude-mobiztool`, id `mobiz`), MaxpayPlus (`~/.claude-maxpayplus`, id `maxpayplus`). All Max, all claude.ai web-auth.
- **CRITICAL config finding:** a separate `CLAUDE_CONFIG_DIR` does NOT inherit the default's MCP (arra-oracle-v3, dpay — global-only in `~/.claude.json`), hooks, or skills → would BREAK fleet agents. **So spawn uses TOKEN-OVERRIDE**: inject `CLAUDE_CODE_OAUTH_TOKEN=<oat>` (keeps default `~/.claude` config, swaps only account). Token read from the plan's config-dir credentials.
- **maw `--env`/`--config-dir` flags** (PR #19 + fix PR #20, both MERGED into maw-js fork `feat/all-prs-rebased`; **maw primary `~/Code/.../maw-js` resynced ff-only → e5446c34, LIVE**). Town: ➕ new-agent has a "Claude account" dropdown; AgentChat has a 🔑 switch dropdown (respawn+close); 🔑 badge on the nametag (probe reads `/proc/<claude-pid>/environ` token → matches plan, `server/plan-detect.ts`).
- **VERIFIED end-to-end**: spawned brew-ops on Mobiztool → confirmed via `/proc/<pid>/environ` the claude proc ran on the Mobiztool token (not default). Bug caught + fixed: maw `--wt` (existing-session worktree path) initially dropped the env → silent default-account spawn; fix hoisted `extraEnv`/`withEnv()` to all buildCommandInDir sites.
- **maw deploy reality:** `~/.bun/bin/maw` realpath-resolves to the PRIMARY checkout `~/Code/.../maw-js/src/cli.ts` → ff-only resync is immediately live, no reinstall.
- Quota now (for picking an account): Mobiztool ~39% weekly left (most), Midasgo ~2%, MaxpayPlus ~0%.

## ⚠️ Formal-PR debt (§3c) — the one thing to close
- **All code is pushed + recoverable**: oracle-studio fork branch `feat/town-ambient-props` @ **7197c8c** has EVERYTHING (latest).
- **BUT PR #6** (ui-studio-oracle-studio, head `feat/town-ambient-props` → base `feat/fleet-town`) **merged at 01:08 today = only the early AMBIENT commits.** All later work (quota, multi-account, badge, switch, presets, staging, PWA, auth) was committed to the SAME branch AFTER #6 closed → **pushed + deployed but NOT in any merged PR.**
- **oracle-studio PRIMARY deploy branch `feat/all-prs-rebased` is 67 commits ahead of fork** (local `--merge --no-ff` deploys that were never pushed). The live town runs this. Reproducible only from the primary right now.
- **Next step:** open a fresh PR for `feat/town-ambient-props` (7197c8c) → into the town's canonical branch, OR push the deploy branch — owner's call on which canonical branch. Code is safe (branch pushed); this is bookkeeping to make the merged history match the live deploy.

## Operate / redeploy
- Town redeploy: edit in worktree `oracle-studio.wt-town-props`, `bunx vite build` (NOT `bun run build`), merge into primary `feat/all-prs-rebased`, `bunx vite build` there, `sudo systemctl restart fleet-town.service`.
- maw redeploy: PR → merge into maw fork `feat/all-prs-rebased` → `git -C ~/Code/.../maw-js merge --ff-only fork/feat/all-prs-rebased` (no restart; maw re-execs).
- Token caveat: web-auth token (~7h life) read fresh at spawn; long-run agents may need respawn. Token appears in the local launch command (ps/tmux) — single-user self-hosted, acceptable.

## TODO / ideas (not started)
- Close the formal-PR debt above.
- Optional: per-account "switch" warns if target weekly quota is low.
- Badge font is tiny (8px) — fine in data, hard to read in a full-map screenshot.
