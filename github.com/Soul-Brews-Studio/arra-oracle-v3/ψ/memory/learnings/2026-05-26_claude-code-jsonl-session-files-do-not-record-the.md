---
title: Claude Code JSONL session files do NOT record the 1M context variant. `.message.
tags: [brew-bot, ctx, context-window, claude-jsonl, 1m-context, model-tier, brew-ops]
created: 2026-05-26
source: brew-ops session 2026-05-26 — /ctx 1M window fix
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Claude Code JSONL session files do NOT record the 1M context variant. `.message.

Claude Code JSONL session files do NOT record the 1M context variant. `.message.model` is written as the bare model id (e.g. `claude-opus-4-7`) with no `[1m]` suffix, and there is no context-window / beta field anywhere in the record (verified 2026-05-26 against a live `claude-opus-4-7[1m]` session: top-level + `.message` keys inspected). Consequence: you cannot derive the real context window from a claude session file alone — the 200k vs 1M tier is invisible in the data.

The fleet launches `claude --dangerously-skip-permissions` with no `--model`, so panes inherit the account default, which for opus-4.6/4.7 (and sonnet-4.x with the 1m migration complete) is the 1M variant. So the correct window for those panes is 1,000,000, not 200,000.

Fix applied to brew-ops-bot `/ctx` (scripts/brew-ops-bot/bot.sh, cmd_ctx claude branch): map model family → window (opus-4.6/4.7, sonnet-4.x → 1M; else 200k) and keep the observed high-water mark as a safety floor (peak > tier ⇒ bump to 1M). Replaces the old "default 200k, bump to 1M only after observing >200k" heuristic that under-reported the window for ~99% of a session. The 200k default originated in commit c37c7ca (2026-05-24, the codex-parity "unify agent bootstrap" refactor); codex reads model_context_window from its own JSONL but claude has no equivalent field. PR: kxlahsimx09/arra-oracle-v3#101.

Caveat: the model→window map is hand-maintained — revisit when new model families ship or if a pane is intentionally launched on a 200k variant.

---
*Added via Oracle Learn*
