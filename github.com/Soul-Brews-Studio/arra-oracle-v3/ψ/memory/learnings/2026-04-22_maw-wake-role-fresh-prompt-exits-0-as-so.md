---
title: `maw wake <role> --fresh "<prompt>"` exits 0 as soon as it:
tags: [brew-ops, repo:cross, fleet, mcp-tools, gotcha, maw-wake, silent-failure, telegram, 2026-04-22]
created: 2026-04-22
source: commit 56a16b7 on arra-oracle-v3 feat/all-prs-rebased-2026-04-20 branch; live observation 2026-04-21 18:46 investigation wake silent-fail
project: github.com/soul-brews-studio/arra-oracle-v3
---

# `maw wake <role> --fresh "<prompt>"` exits 0 as soon as it:

`maw wake <role> --fresh "<prompt>"` exits 0 as soon as it:
  1. Creates the worktree
  2. Opens the tmux window + symlinks .agent/.claude
  3. send-keys's the `claude -p '<prompt>'` command into the pane

It does **NOT** wait for claude to finish. If claude dies immediately post-spawn for any reason:
- Anthropic API returned `overloaded_error` (happens under load)
- Prompt got truncated by maw's send-keys path (see separate learning)
- MCP init failure in claude CLI
- Shell parse error (unclosed quote from paste)

...the caller's `if maw wake ...; then log "wake succeeded"` runs the success branch. The operator sees no Telegram, no log, no error — **silent failure for minutes to hours**.

**Fix: invert the notification order.** Send the primary notification (e.g. Telegram) BEFORE spawning the wake. Treat the wake-spawned investigation as best-effort nice-to-have detail:

```bash
# Primary: always-send, via direct curl (no dependency on wake)
send_tg "🔴 Regression failed at test-X. Investigation spawning — detail follows if API OK. ถ้าไม่มี detail ใน 5-10 min = investigation ล้ม"

# Best-effort: may or may not actually send a 2nd Telegram
maw wake pg-tester --fresh "$investigation_pointer"
```

The operator never misses the critical signal. If claude succeeds, they get a 2nd detailed Telegram with classification. If claude dies silently, the primary covers.

**Observed:** 2026-04-21 18:46 — investigation wake spawned, claude hit `overloaded_error` on first API call, exited immediately. Regression runner logged "Investigation wake spawned — pg-tester will send Telegram" (its if-branch success path). No Telegram ever arrived. User in silent-failure state for 30+ min until manual inspection of tmux pane revealed the API error stderr.

**Applied in:** `arra-oracle-v3/scripts/regression-then-investigate.sh` Step 5b — primary curl Telegram before `maw wake pg-tester`, commit `56a16b7`.

**Generalization:** Any automation wrapping a spawn-and-don't-wait command (maw wake, launchd start, systemd unit start, docker run -d) — treat the spawn as a best-effort second channel, always emit the primary signal via a synchronous path the caller controls.

---
*Added via Oracle Learn*
