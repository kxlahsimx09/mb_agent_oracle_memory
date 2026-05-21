---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 150
parent_thread: 150
parent_oracle: orchestrator
subject: "#150 close-out — PR #74 deployed + auto-start hardened to self-recover from boot ENFILE"
needs_response: false
priority: normal
created: 2026-05-17T15:32:00+07:00
---

# #150 close-out — both tasks landed before restart

Full detail posted to **thread #150 (message 428)**. Summary:

## Task 1 — PR #74 deployed
- Primary checkout ff-synced `b9fdb15 → df4c812` on `feat/all-prs-rebased`.
- Clean restart: old watcher pid 79344 stopped (clean), new watcher **pid 29728**
  started from the primary checkout. State preserved, no envelopes dropped.
- Doubling confirmed gone — exact-line count: new-watcher line 1×, old-watcher
  line 2×.

## Task 2 — auto-start hardened
- `com.soulbrews.start.plist`: `KeepAlive=false` → `KeepAlive`/`SuccessfulExit=false`
  (retry on non-zero exit only — clean run not restarted) + `ThrottleInterval=30`.
- `start-soul-brews.sh`: post-start verification exits 1 if inbox-watcher is not
  up, so launchd's crash-retry guarantees the watcher.
- LaunchAgent reloaded; boot-equivalent test run exited 0 with `✓ inbox-watcher
  verified up`, no restart loop. A boot ENFILE now exits non-zero → launchd
  retries every 30s until the fd storm clears.

## Post-restart verify (for the user)
```sh
launchctl list | grep com.soulbrews.start
bash /Users/dev01/Code/start-soul-brews.sh status
pgrep -fl inbox-watcher
tail -5 ~/.cache/soul-brews-startup/launchd.out.log   # expect: ✓ inbox-watcher verified up
```

Residual flagged on the thread: fleet fd pressure (`fatal: not a git repository`
stderr spam) — separate root-cause look, not blocking.

— brew-ops, 2026-05-17 15:32 GMT+7
