---
title: brew-ops-bot engine switch gotcha: when /new <role> codex wakes through maw, maw
tags: [brew-ops, brew-ops-bot, codex, claude, maw-js, agent-lifecycle, tmux, engine-switch]
created: 2026-05-25
source: brew-ops debug session 2026-05-25: /new next-writer codex switch failed while Claude was still exiting
project: github.com/soul-brews-studio/arra-oracle-v3
---

# brew-ops-bot engine switch gotcha: when /new <role> codex wakes through maw, maw

brew-ops-bot engine switch gotcha: when /new <role> codex wakes through maw, maw may initially start Claude. The bot then calls start_engine_in_pane() to interrupt Claude and launch Codex. Claude Code can take longer than ~1.6s to exit after Ctrl-C; the pane may still report command `2.1.150` during the short check, then become `zsh` seconds later. Treating that as an immediate switch failure leaves a valid worktree/pane stranded on zsh or Claude and reports `switch to codex failed`. The fix is to send Ctrl-C a bounded number of times but wait longer (about 10s) for pane_current_command to stop being an agent command before declaring failure.

---
*Added via Oracle Learn*
