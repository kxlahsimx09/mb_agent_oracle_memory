---
title: inbox-watcher.sh `log()` double-write bug (fixed 2026-05-17, PR #74).
tags: [inbox-watcher, logging, daemon, shell, fleet, gotcha]
created: 2026-05-17
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# inbox-watcher.sh `log()` double-write bug (fixed 2026-05-17, PR #74).

inbox-watcher.sh `log()` double-write bug (fixed 2026-05-17, PR #74).

Symptom: every line in `~/.cache/inbox-watcher/inbox-watcher.log` appears exactly twice — identical text, identical timestamp. First noticed on gc_sweep output but affects ALL log lines (scan/fire/alert/gc).

Root cause: `log()` was `printf … | tee -a "$LOG_FILE" >&2`. The daemon is launched `nohup … >>"$LOG_FILE" 2>&1`, so fd 2 points back at $LOG_FILE. `tee -a "$LOG_FILE"` writes the line once (tee→file); the trailing `>&2` sends tee's stdout to fd 2 — the same file — writing it a second time. Confirmed via `lsof -p <pid> -d 0,1,2`: fd 1 AND fd 2 both on inbox-watcher.log.

Fix: `log()` appends one copy to $LOG_FILE directly and echoes to stderr only when stderr is a TTY (`[ -t 2 ]`) — keeps console output for foreground runs, never double-writes.

General lesson: a shell daemon whose `log()` helper both `tee`s to a file AND echoes to stderr will double-write whenever the process is daemonized with `2>&1` into that same file. The `[ -t 2 ]` guard is the safe pattern. #repo:arra-oracle-v3 #fleet #gotcha #brew-ops

---
*Added via Oracle Learn*
