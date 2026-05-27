---
title: brew-ops-bot /ctx gotcha for Codex sessions: Codex token_count events report `mo
tags: [brew-ops, codex, brew-ops-bot, ctx, context-window, gpt-5.5, maw-js, telegram]
created: 2026-05-25
source: brew-ops debug session 2026-05-25: clarify Codex /ctx usable vs raw context window
project: github.com/soul-brews-studio/arra-oracle-v3
---

# brew-ops-bot /ctx gotcha for Codex sessions: Codex token_count events report `mo

brew-ops-bot /ctx gotcha for Codex sessions: Codex token_count events report `model_context_window` as the effective usable context window, not necessarily the raw model context window shown in the local model catalog. For GPT-5.5 on Codex CLI 0.133.0, `models_cache.json` reports `context_window=272000` with `effective_context_window_percent=95`, while JSONL token_count reports `model_context_window=258400` (272000 * 95%). If /ctx displays only 258400 with no model/raw label, users can misread the session as not running GPT-5.5. The bot should label Codex context as usable, show model+effort, and include raw/effective model-cache window when available.

---
*Added via Oracle Learn*
