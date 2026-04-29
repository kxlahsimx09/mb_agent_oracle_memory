---
title: ## Claude Code auth method matrix — `claude.ai` (interactive) vs `oauth_token` (
tags: [claude-code, auth, oauth, tmux, print-mode, gotcha, automation]
created: 2026-04-27
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# ## Claude Code auth method matrix — `claude.ai` (interactive) vs `oauth_token` (

## Claude Code auth method matrix — `claude.ai` (interactive) vs `oauth_token` (print mode)

Claude Code CLI has 2 OAuth-style auth methods. `claude auth status` reveals which is active. Discovered while debugging "watcher wakes 401 nightly" 2026-04-26 → 27.

### The matrix

| `authMethod` | Interactive `claude` | `claude -p '<prompt>'` (print mode) | Source |
|---|---|---|---|
| `claude.ai` | ✅ works (Max subscription session) | ❌ **401 Invalid authentication credentials** | Browser OAuth via `claude` interactive login |
| `oauth_token` | ✅ works | ✅ works | `claude setup-token` (long-lived token) |

### Symptoms

- Watcher's `claude --dangerously-skip-permissions -p '<prompt>'` returns 401 in tmux pane
- Same pane runs `claude` interactive fine (splash screen + Max subscription)
- `claude auth status` in pane shows `authMethod: "claude.ai"`
- `claude auth status` in another terminal (where `claude -p` works) shows `authMethod: "oauth_token"`

→ User had logged in via interactive flow (gives `claude.ai` session) but never ran `setup-token` (which gives `oauth_token`).

### The masked-by-Claude-Desktop trap

When debugging from Claude Desktop's integrated terminal (or via Claude Code's Bash tool), `claude -p` may still work even when standalone tmux panes fail. Reason: Claude Desktop's terminal inherits these env vars:
```
__CFBundleIdentifier=com.anthropic.claudefordesktop
CLAUDE_AGENT_SDK_VERSION=0.2.111
CLAUDE_CODE_ENTRYPOINT=claude-desktop
PATH includes Claude Desktop's local-agent-mode-sessions/skills-plugin/.../bin
```

These env vars route `claude -p` through the desktop's authenticated session, bypassing the standalone CLI's auth check. **A Claude Desktop terminal "claude -p test" succeeding does NOT mean the standalone CLI is auth'd.**

To verify the real CLI auth state, run `claude -p "test"` from a plain terminal OUTSIDE Claude Desktop (or any non-tmux non-desktop shell), or from a fresh tmux pane.

### Fix

Run **ONE** of:
1. `claude setup-token` — interactive browser flow → saves long-lived token. Works for all subsequent `claude -p` calls in any terminal/tmux.
2. `export ANTHROPIC_API_KEY=sk-ant-...` in `~/.zshrc` — bypasses OAuth entirely (different auth method again — API key). New tmux panes pick up via .zshrc source on shell start.

After fix: existing tmux panes still won't see the change (their shell already loaded). New panes will. `tmux kill-server` + restart guarantees all panes refresh.

### How to apply

When automation `claude -p` fails with 401 but interactive works:
1. Run `claude auth status` in BOTH the failing context AND a known-good context — compare `authMethod`
2. If failing context shows `claude.ai`, fix is `claude setup-token` (don't waste time on env-var/keychain debug)
3. If you're testing from Claude Desktop's terminal, your test is invalid — repro from a plain terminal or tmux pane

**Anti-pattern:** Assuming "auth works in MY terminal → auth works everywhere". Claude Desktop's env masks this.

---
*Added via Oracle Learn*
