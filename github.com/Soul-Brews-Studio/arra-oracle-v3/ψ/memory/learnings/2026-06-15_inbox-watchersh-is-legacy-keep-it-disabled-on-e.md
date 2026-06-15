---
title: inbox-watcher.sh is LEGACY — keep it DISABLED on every box.
tags: [inbox-watcher, systemd, fleet-dispatch, migration, legacy, cutover]
created: 2026-06-15
source: brew-ops (EC2 cutover 2026-06-15)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# inbox-watcher.sh is LEGACY — keep it DISABLED on every box.

inbox-watcher.sh is LEGACY — keep it DISABLED on every box.

`scripts/inbox-watcher.sh` (arra-oracle-v3's old "core fleet dispatch" daemon) is unused as of 2026-06. Do NOT enable it on a new/migrated box.

Evidence:
- On the Mac its launchd plist was renamed `com.soulbrews.inbox-watcher.plist.disabled-20260530-123846` — off since 2026-05-30, and the fleet ran fine for 2+ weeks without it.
- Owner confirmed 2026-06-15 ("inbox-watcher.sh ไม่ได้ใช้แล้ว มันเป็น legacy ของ orchestrator … ปิดไปได้"). On the EC2 migration it's `systemctl --user disable`d (inactive/disabled).
- Actual fleet dispatch now flows through orchestrator-bot / brew-ops-bot + maw, not inbox-envelope polling (consistent with the "leader inbox not polled" learning).

Why it traps you under systemd: its `case ${1:-loop} in loop|start)` runs `run_loop` in the FOREGROUND but also writes $PID_FILE and guards with find_other_daemons (pgrep). Under Type=simple the MainPID/child split makes systemd think it died → Restart=always → next start hits the pidfile guard → "another inbox-watcher.sh is already running … exit 1" → restart-loop. Don't try to fix the Type — leave it disabled.

The live fleet after the 2026-06-15 EC2 cutover is 4 user units + 1 timer: oracle-http (:47778), w2-watcher, brew-ops-bot, orchestrator-bot, and oracle-reindex.timer (nightly 03:00 Asia/Bangkok). Mac is demoted to an operator terminal; rollback = EBS snap snap-040a4d175b5de8574 + restart the Mac daemons.

Doc debt: install docs 05-daemons.md + 08-systemd-daemons.md still call inbox-watcher "core fleet dispatch / highest risk" and the cutover runbooks still say `systemctl --user start inbox-watcher …` — those lines are stale; mark it legacy/disabled-by-default.

---
*Added via Oracle Learn*
