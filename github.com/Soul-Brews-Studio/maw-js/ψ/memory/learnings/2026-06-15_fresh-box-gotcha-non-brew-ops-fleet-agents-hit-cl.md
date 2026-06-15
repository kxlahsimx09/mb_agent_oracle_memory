---
title: Fresh-box gotcha: non-brew-ops fleet agents hit Claude Code permission prompts; 
tags: [maw, permissions, dangerously-skip-permissions, migration, fleet, claude-code]
created: 2026-06-15
source: brew-ops (EC2 migration 2026-06-15)
project: github.com/soul-brews-studio/maw-js
---

# Fresh-box gotcha: non-brew-ops fleet agents hit Claude Code permission prompts; 

Fresh-box gotcha: non-brew-ops fleet agents hit Claude Code permission prompts; fix = maw `commands.default`.

On a freshly-migrated/cloned box, every fleet agent EXCEPT the ones explicitly listed in maw's `commands` map (only `brew-ops*` had it) launches as plain `"claude"` with NO `--dangerously-skip-permissions`, so Claude Code prompts on every tool use. It only *looked* fine on the old Mac because Claude had accumulated **per-directory trust + tool-permission grants** there over time; a fresh clone has none → prompts constantly.

Key mechanics (maw-js `src/config/command.ts`):
- maw only AUTO-injects `--dangerously-skip-permissions` for **channel-enabled** oracles — the `if (opts.channels?.length)` block, and only when `permissionMode !== "relay"` (#1146). A plain `maw wake <role>` worker (bankbot, next-dev, next-tester, investigator, …) is NOT channel-enabled, so it never gets the auto-inject — it relies entirely on the base command from `config.commands[<agent>] || config.commands.default`.
- It STRIPS the flag when `process.getuid?.() === 0` (#181 — Claude refuses `--dangerously-skip-permissions` as root). So this fix only works for a **non-root** user (EC2 = `ubuntu`, uid 1000 ✓). As root you must run as a non-root user instead, not force the flag.

Fix on a dedicated autonomous box: set maw `commands.default` to `"claude --dangerously-skip-permissions"` (covers the whole fleet in one line; brew-ops already had it). Edit `~/.config/maw/maw.config.json` AND `maw.config.50.json` (both are read in this setup). Verify end-to-end with `bun -e 'import {buildCommand} from "./src/config"; console.log(buildCommand("nextbot-dev-oracle"))'` from the maw-js dir → must contain the flag. **Re-wake agents to apply** — the command is built at wake time; already-running sessions keep their old command.

Applied 2026-06-15 on the EC2 (owner chose fleet-wide `default` over per-role opt-in). bankbot agents = `bot-writer-oracle` (kokarat/bank-bot, fleet 02-bank-bot) + `nextbot-dev-oracle` (kxlahsimx09/mb-next-bank-bot, fleet 06-mb-next-bank-bot).

---
*Added via Oracle Learn*
