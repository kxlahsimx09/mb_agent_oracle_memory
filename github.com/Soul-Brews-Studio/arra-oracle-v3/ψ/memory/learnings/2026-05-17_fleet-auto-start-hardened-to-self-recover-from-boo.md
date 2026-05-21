---
title: Fleet auto-start hardened to self-recover from boot-time ENFILE (2026-05-17, thr
tags: [launchd, launchagent, auto-start, enfile, fleet, boot, inbox-watcher, keepalive]
created: 2026-05-17
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Fleet auto-start hardened to self-recover from boot-time ENFILE (2026-05-17, thr

Fleet auto-start hardened to self-recover from boot-time ENFILE (2026-05-17, thread #150).

**Problem:** The `com.soulbrews.start` LaunchAgent (`~/Library/LaunchAgents/com.soulbrews.start.plist`, `RunAtLoad=true`) runs the central startup script `/Users/dev01/Code/start-soul-brews.sh`, which brings up all 7 fleet services including the inbox-watcher. A 2026-05-16 boot run exited **126** — `/bin/bash: start-soul-brews.sh: Too many open files in system` (ENFILE, system-wide fd exhaustion). bash failed to even `open()` the script, so an in-script retry is impossible. With `KeepAlive=false`, launchd never retried → the whole fleet stayed silently down until a manual `bash start-soul-brews.sh`.

**Fix (both host-level, not repo-tracked — direct edit, `.bak-2026-05-17` saved):**
1. Plist: `KeepAlive=false` → `KeepAlive` dict with `SuccessfulExit=false` (retry on non-zero exit ONLY — a clean exit-0 run is not restarted, so no busy-loop) + `ThrottleInterval=30` (space retries 30s so a boot fd storm drains). `SuccessfulExit=false` implies `RunAtLoad=true`.
2. `start-soul-brews.sh`: post-`cmd_start` verification — after `sleep 5` for async spawns to settle, `exit 1` if `proc_alive "scripts/inbox-watcher.sh start"` is false. This makes launchd's crash-retry actually GUARANTEE the watcher, not just a script that ran. Script stays idempotent so retries are cheap.

**Net:** a boot ENFILE → script/launcher exits non-zero → launchd retries every 30s until the fd storm clears and exits 0. No manual intervention.

**Verify:** `launchctl list | grep com.soulbrews.start` (non-zero code = mid-retry, self-clears); `launchctl print gui/$(id -u)/com.soulbrews.start` shows `successful exit => 0` in the keepalive block; `tail ~/.cache/soul-brews-startup/launchd.out.log` → `✓ inbox-watcher verified up`.

**Residual:** fleet still shows fd pressure (`fatal: not a git repository` stderr spam in inbox-watcher.log) — separate root-cause look warranted.

Tags: #repo:cross #fleet #brew-ops #gotcha #decision

---
*Added via Oracle Learn*
