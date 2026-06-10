---
title: USER PREFERENCE (owner, 2026-06-10): ALL maw-dispatched fleet agents must run on
tags: [user-preference, maw, opus, model, dispatch, orchestrator, feedback]
created: 2026-06-09
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# USER PREFERENCE (owner, 2026-06-10): ALL maw-dispatched fleet agents must run on

USER PREFERENCE (owner, 2026-06-10): ALL maw-dispatched fleet agents must run on OPUS, always — not sonnet. The orchestrator MUST pass `--model opus` on EVERY `maw team spawn` (and any agent dispatch). Do NOT rely on the maw default: `maw team spawn` with no `--model` falls back to maw.config.json `commands.default` = "claude", which resolves to SONNET. This caused the simlive campaign's first wave (architect, next-dev, next-ui — and the initial reviewer/tester) to run on sonnet by omission; the owner expected opus throughout and had reviewer+tester re-spawned on opus. Durable fix options: (a) orchestrator discipline — always append `--model opus` to spawn; (b) global — set maw.config.json `commands.default` to "claude --model opus" (a SHARED-infra change affecting every orchestrator's spawns; do via brew-ops/owner, not the orchestrator, per the orchestrator-guard). Why: the owner wants maximum reasoning quality on all build/review/verify work and treats opus as the standing default.

---
*Added via Oracle Learn*
