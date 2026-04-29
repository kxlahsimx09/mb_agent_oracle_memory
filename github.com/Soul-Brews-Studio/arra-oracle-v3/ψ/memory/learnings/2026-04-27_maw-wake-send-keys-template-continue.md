---
title: ## maw `wake` send-keys template — `--continue || claude -p` exit-0 trap
tags: [maw, wake, claude, send-keys, template-bug, automation, anti-pattern]
created: 2026-04-27
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# ## maw `wake` send-keys template — `--continue || claude -p` exit-0 trap

## maw `wake` send-keys template — `--continue || claude -p` exit-0 trap

maw's wake plugin (as of 2026-04-23 a3672e2 ~ 04-27) sends this command via tmux send-keys:

```bash
claude --dangerously-skip-permissions --continue || claude --dangerously-skip-permissions -p '<prompt>'
```

Intent: continue the prior conversation if one exists, else start fresh with the prompt. Reality: **`claude --continue` exits 0 even when there's no conversation to continue** (it prints "No conversation found to continue" and exits 0). `||` only fires on non-zero exit → fallback `claude -p '<prompt>'` **never runs** in fresh-pane / fresh-worktree scenarios.

### Symptom

After `maw wake` returns 0 ("woke ..."), pane shows:
```
╰─❯ claude --dangerously-skip-permissions --continue || claude --dangerously-skip-permissions -p '...'
No conversation found to continue
[empty zsh prompt, no claude session]
```

No claude process spawned → no W2/W9/W1 work → no PR. Watcher's `if maw wake ...` sees exit 0 → marks "wake succeeded" anyway.

This compounds the silent-fail problem — watcher trusts maw's exit code, maw trusts the bash template, bash template trusts `--continue`'s exit code.

### Workaround until maw fixes upstream

After firing `maw wake`, manually push the fallback command:
```bash
tmux send-keys -t "$pane" "claude --dangerously-skip-permissions -p 'อ่าน $prompt_file ...'" Enter
```

Or wrap in a per-call wrapper that uses `if !` instead of `||`:
```bash
claude --continue 2>&1 | grep -q "No conversation found" && claude -p '<prompt>'
```

### How to detect (operator-side)

`pane_current_command` from `tmux list-panes -F "#{pane_current_command}"`:
- `2.1.119` (or current claude version) → claude IS running in pane
- `zsh` → pane is back at shell prompt → claude either finished or never started

If pane returns to `zsh` within seconds of wake (vs 30+ min for a real W2/W9 run) and no PR landed → suspect this template bug.

### Permanent fix candidates (untaken)

1. Patch maw upstream to `if claude --continue 2>/dev/null | tee /tmp/x | grep -qv "No conversation"; then ... else claude -p '<prompt>'; fi`
2. Watcher post-wake pane-content scrape: if pane shows "No conversation found" within 5s, send-keys the fallback manually
3. Always-fresh wake mode in maw: `--task` flag bypasses the `--continue || -p` chain entirely

### Anti-pattern

Don't combine `||` with a command that exits 0 on its "I had nothing to do" path. Either:
- Use exit code that signals "no work" (non-zero) so `||` is meaningful
- Use explicit detection (`grep` on output) before deciding fallback
- Or unconditionally run the second command as the primary path

---
*Added via Oracle Learn*
