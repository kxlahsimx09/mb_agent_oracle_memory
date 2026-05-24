---
title: title: VERIFIED by live test — codex implements the Claude Stop-hook contract; l
tags: [codex, engine-parity, loop-closure, stop-hook, hook-trust, verified, correction, brew-ops, repo:cross, fleet, decision]
created: 2026-05-24
source: brew-ops LIVE TEST of codex-cli 0.133.0 Stop-hook, 2026-05-24 (supersedes the review-time finding)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# title: VERIFIED by live test — codex implements the Claude Stop-hook contract; l

title: VERIFIED by live test — codex implements the Claude Stop-hook contract; loop-closure works on codex (corrects the earlier "no-op" fear)

#repo:cross #fleet #brew-ops #codex #engine-parity #loop-closure #stop-hook #verified

**Supersedes** [[2026-05-24_title-codex-engine-parity-is-delivered-only-on-th]], whose two main claims are now resolved/refuted by live testing of `codex-cli 0.133.0` on the dev01 node (2026-05-24) and by the follow-up commits on the PR bundle.

**Method.** Isolated `CODEX_HOME=/tmp/...` run (real `~/.codex` untouched) with a probe `Stop` hook that logged its stdin payload and `exit 2`. Drove interactive codex in tmux. (Note: `codex exec` headless does NOT fire Stop — only interactive does; the probe only fired once the hook was trusted + active.)

**Finding 1 (REFUTED my review-time fear).** codex 0.133.0 implements the Claude-Code hook contract **faithfully** — it is not a no-op:
- Reads `~/.codex/hooks.json` in Claude schema (`.hooks.Stop[].hooks[].command`); also consumes `claude-plugins-official` plugins (SessionStart/SessionEnd/PreToolUse, `${CLAUDE_PLUGIN_ROOT}`).
- Full lifecycle: `Stop` ("Right before Codex ends its turn"), PreToolUse, PostToolUse, SessionStart, UserPromptSubmit, SubagentStart/Stop, PreCompact, PostCompact, PermissionRequest.
- **Stop payload is Claude-identical, top-level `session_id`:** `{"session_id":"…","turn_id":"…","transcript_path":".../rollout-….jsonl","cwd":"…","hook_event_name":"Stop","model":"gpt-5.5","permission_mode":"…","stop_hook_active":false,"last_assistant_message":"…"}`. So `inbox-loop-closure-hook.sh`'s `jq -r '.session_id'` reverse-lookup works on codex natively. (PR #92 follow-up added `.payload.id // .id` fallbacks — harmless but unnecessary.)
- **`exit 2` blocks the stop:** codex printed `Stop hook (blocked) / feedback: <stderr>` and forced the agent to keep working; the re-entrant fire carried `stop_hook_active:true` (exact Claude semantics). → the loop-closure gate ENFORCES on codex identically to claude.

**Finding 2 (RESOLVED).** The review-time "inbox-watcher.sh has zero codex awareness" was true at review but is fixed in PR #92 follow-up `3e3e5a9c`: `find_latest_codex_jsonl`, `codex_session_id_from_jsonl` (`session_meta.payload.id`), `codex_jsonl_has_prompt` (T1), dual-path `derive_session_id`/`verify_delivery` (+`session_engine`). With maw-js #9's `codex resume` composition, the autonomous directed-inbox loop now closes for codex (capture → verify → resume).

**The one real residual — codex hook-TRUST gate (new, actionable).** codex gates hooks behind trust:
- A newly-installed/changed hook is `Installed=1, Active=0, Review=1` and does NOT run until trusted (interactive "Trust all" → persists `trusted_hash` in `~/.codex/config.toml`). `--dangerously-bypass-hook-trust` did NOT auto-activate it in the interactive TUI.
- `install-inbox-loop-closure-hook.sh` writes `~/.codex/hooks.json` but does NOT establish trust. So on a FRESH codex node (or after editing the hook command), the gate is silently inactive until a human trusts it. The current dev01 node is already trusted (`config.toml` has `…hooks.json:stop:1:0` `trusted_hash`) → live there.
- Trust hash is over the hook **entry/command**, not script content (proven: the `afplay` Stop hook has a trust hash but no script file). → editing the hook **script** preserves trust; changing its **command string** re-triggers review.

**How to apply.**
- Treat codex loop-closure as WORKING (proven) on a trusted node — not a no-op. Drop the "claim overstated" framing.
- Installer follow-up: make `install-inbox-loop-closure-hook.sh` either print the exact "trust this hook in codex" step, or write `trusted_hash` into `config.toml` non-interactively, so "installed on both runtimes" also means "active on both runtimes" on fresh nodes.
- Guardrail: `codex exec` (headless) does not fire Stop — keep codex dispatch on interactive `codex`/`codex resume` (current behavior). If ever switched to `codex exec` (headless analog of `claude -p`), loop-closure silently breaks.

related: [[2026-05-24_title-codex-engine-parity-is-delivered-only-on-th]] [[2026-05-24_loop-closure-stop-hook-policy-must-be-installed-on]] [[2026-05-24_maw-wake-codex-path-is-not-claude-compatible-res]]

---
*Added via Oracle Learn*
