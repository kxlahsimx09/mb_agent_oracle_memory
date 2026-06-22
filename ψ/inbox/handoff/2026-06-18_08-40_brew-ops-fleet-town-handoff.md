---
from: brew-ops
date: 2026-06-18T08:40:00+07:00
topic: Fleet Town — live ai-town-style visualizer of the tmux agent fleet
status: feature-complete · deployed · PRs open for review
tags: [#repo:cross, #fleet, #studio, #brew-ops, #handoff]
---

# Fleet Town — Session Handoff

## What it is
A live, ai-town-style 2D map of the running tmux agent fleet, served at **`/town`**
in **oracle-studio**. It mirrors tmux reality (Oracle/Shadow P-002/P-003 — reflects,
never drives). Plan issue: `ui-studio-oracle-studio#50`.

You can see, at a glance: which **role** each agent is (pixel costume + name-tag),
who is **working / asleep / waiting-on-you / offline**, **context % left**, which
**team/orchestrator** each belongs to — and click any agent to **chat / drive its
TUI menu / nudge / close / spawn a new one**.

## Where it lives / how to operate
- **Code:** `oracle-studio`, route `/town`. Branch `feat/fleet-town` → **PR
  Soul-Brews-Studio/ui-studio-oracle-studio#51** (the canonical repo name; the
  `oracle-studio` remote redirects there). Pushed to fork `kxlahsimx09/ui-studio-oracle-studio`.
- **Live URL:** https://town.3-1-0-33.sslip.io — basic-auth **user `oracle` / pass `qVy50v5MsyDWqAG`**
  (Caddy bcrypt hash in `/etc/caddy/Caddyfile`; plaintext only here).
- **Serving:** Caddy (:443, HTTPS) → `fleet-town.service` (systemd) → `bun server/fleet-server.ts`
  on `127.0.0.1:8788`. No AWS SG change was needed.
- **Redeploy:** `cd oracle-studio && bunx vite build && sudo systemctl restart fleet-town.service`
  (`bun run build` fails on the pre-existing `knowledge-map-3d` dep — use `bunx vite build`).
- **Data:** `server/fleet-probe.ts` reads `tmux list-panes -a` + `~/.claude/teams/*/config.json`
  + Claude transcripts (`~/.claude/projects/<enc-cwd>/*.jsonl`) for context %.
- Full deploy notes: `oracle-studio/deploy/README.md`.

## Work done (19 commits on feat/fleet-town; 25 files, ~2050 LOC)
- **Map + data**: pixel-sprite ai-town map (real `32x32folk.png`), render-agnostic
  `FleetState`, Vite-dev + prod Bun servers (endpoints outside `/api`, %NN-validated, execFile).
- **Grouping**: orchestrator + its dispatched workers cluster together (campaign),
  via dispatch roads = slug-prefix + maw `createdByPane` (authoritative) + per-pane
  role from `tmuxPaneId` (fixes split-pane sub-agents mislabeled as orchestrator).
- **Per-agent**: context % (brewbot `/ctx` logic), activity emoji bubble (🚀/🧪/🔧/💭…),
  💤 idle, **🔔 "waiting for input"** (TUI-menu detection, brewbot `pane-classify.sh`
  bottom-region scan to avoid self-watch FP).
- **Interaction**: click → chat window (History=transcript / Live=screen), TUI nav
  keys ↑↓←→/enter/esc/tab, nudge, close-session, **drag to reposition**, draft
  persisted in localStorage, Esc closes.
- **+ New agent** button → role picker + slug → `maw wake … --fresh`.
- **Layout**: full-width stage, **responsive/mobile** (zones clamp to width).

## Cross-repo changes (3 more PRs)
| Repo | PR / branch | What | State |
|---|---|---|---|
| `ui-studio-oracle-studio` | **#51** `feat/fleet-town` | the whole town | OPEN — needs review/merge |
| `maw-js` | **#2843** (base `alpha`) + branch `feat/team-creator-pane` | `maw team create` stamps `createdByPane`/`createdBySession` | **merged into `feat/all-prs-rebased` (live)**; PR to alpha OPEN |
| `mb_agent_oracle_memory` | **#26** `orchestrator/no-split-teammates` | binding Core Principle 7: orchestrator never split-panes teammates | OPEN |
| `arra-oracle-v3` | branch `fix/team-dispatch-record-pane`, commit `5ecc112b` | `team-dispatch-helper.sh` records the spawned teammate's `tmuxPaneId` | **merged into `feat/all-prs-rebased` (live)** |

## Pending / open
- **All 4 PRs await owner review/merge** (safety rule: never merge without explicit OK).
- **Forward-only fixes**: the maw `createdByPane` + helper `tmuxPaneId` recording only
  apply to teams created/spawned AFTER the patch. Existing teams keep their gaps until
  re-created/re-spawned. (I backfilled adminview/next-dev once during testing, then reverted.)
- **Rejected approach (don't re-add)**: a role-based "open slot" heuristic to rescue
  commons workers — it false-positived (brew-ops-keepfix pulled into orchestrator-doc's
  team). Common roles have many independent instances; match only on `tmuxPaneId`.
- **Offered, not done** (ask owner): change basic-auth password; smoother sprite
  scaling on mobile; double-click-to-unpin a dragged agent; the studio's GLOBAL nav
  (app shell) may still force-zoom on mobile — that's oracle-studio's Header, not /town.

## Key gotchas
- tmux field separator: use a printable token (`<|FLEET|>`), NOT a control char (`\x1f` round-trips badly).
- Claude TUI uses the **alternate screen** → `capture-pane` has ~no scrollback (≈46 lines);
  deep history comes from the JSONL transcript.
- systemd PATH is minimal → `maw`/`ghq` not found; the spawn endpoint runs with the user tool PATH.
- `kxlahsimx09` can open issues but **cannot set labels** on these repos.

## Honest feedback
The session was a long, tight build/observe/fix loop driven by the owner spotting
real fleet edge-cases (split panes, commons-orphans, FP glow). The biggest lesson:
**don't guess identity from role** — only `tmuxPaneId` is authoritative; the one time
I added a role heuristic it mis-grouped unrelated agents. Two structural fixes
(maw + helper recording pane ids) close the gap deterministically. The town is now a
genuinely useful fleet console; main risk is the 4 open PRs drifting unmerged.
