---
title: # Brew-ops-bot Codex startup can false-succeed on the first untrusted repo
tags: [brew-ops, brew-ops-bot, codex, maw-js, agent-lifecycle, tmux, telegram, trust-prompt]
created: 2026-05-25
source: brew-ops debug 2026-05-25: /new pg-writer codex in mobiz-payment-gateway stopped at Codex trust prompt
project: github.com/soul-brews-studio/arra-oracle-v3
---

# # Brew-ops-bot Codex startup can false-succeed on the first untrusted repo

# Brew-ops-bot Codex startup can false-succeed on the first untrusted repo

Observed 2026-05-25 GMT+7 with `/new pg-writer codex` for `github.com/kokarat/mobiz-payment-gateway`.

Symptoms:
- Telegram reported `✓ created ... engine=codex` and made the chat active.
- The pane command later returned to `zsh`, so sending a normal message failed with `ไม่มี agent CLI รัน ... pane cmd=zsh`.
- Pane scrollback showed Codex's first-run trust prompt: `Do you trust the contents of this directory?` for the repo root.
- `codex-watcher.sh` started but bailed with `no codex rollout found` because Codex never reached a real session turn.

Root cause:
- `maw wake` still creates the pane through the default Claude template, then `brew-ops-bot` switches the pane to the requested engine.
- `start_engine_in_pane()` previously returned success immediately after typing the Codex command, before verifying that the requested engine reached a usable TUI state.
- On a repo missing `[projects."..."] trust_level = "trusted"` in `~/.codex/config.toml`, Codex opens an interactive trust prompt. Telegram bootstrap/user text can land in that prompt instead of the agent.

Fix pattern:
- For Codex engine startup, pre-trust the current git repository root in `${CODEX_HOME:-~/.codex}/config.toml` when `CODEX_AUTO_TRUST_REPOS=1`.
- After sending the engine command, wait for the expected pane command to stay alive for multiple checks instead of returning immediately.
- Detect a visible Codex trust prompt from the current tmux screen and fail startup with an actionable `/relaunch` message.
- Refuse normal user sends while a Codex trust prompt is visible, because otherwise the user's task is consumed by the prompt and the agent never receives it.

Operational recovery:
- Add the missing trusted project entry for the repo root, restart Codex in the same pane, restart `codex-watcher.sh`, and resend the pending bootstrap/task.
- Confirm watcher logs show `JSONL file: ...` and `pushed agent turn` for that chat.

---
*Added via Oracle Learn*
