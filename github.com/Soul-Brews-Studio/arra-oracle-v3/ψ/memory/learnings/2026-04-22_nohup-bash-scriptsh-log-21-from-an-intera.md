---
title: `nohup bash script.sh > log 2>&1 &` from an interactive shell does NOT fully det
tags: [brew-ops, repo:arra-oracle-v3, infrastructure, scripts, gotcha, shell, sigttin, nohup, 2026-04-21]
created: 2026-04-22
source: commits f7789bb (self-isolate) + 987f21f (spawn fix) on arra-oracle-v3 feat/all-prs-rebased-2026-04-20 branch; live incident 2026-04-21 with 11 SIGSTOP'd processes
project: github.com/soul-brews-studio/arra-oracle-v3
---

# `nohup bash script.sh > log 2>&1 &` from an interactive shell does NOT fully det

`nohup bash script.sh > log 2>&1 &` from an interactive shell does NOT fully detach — stdin is still connected to the parent's controlling tty. If any grandchild process (2+ levels deep) tries to probe `/dev/tty` — e.g. `docker compose exec -T` checking term size, `curl` prompting for password, `ssh` asking for a passphrase — the kernel raises `SIGTTIN` on the grandchild (background process group trying to read tty) and stops it with state `T`. The whole chain hangs: grandchild stopped → parent bash waits → script never completes.

**`nohup` alone is insufficient.** It only ignores SIGHUP (terminal close) — doesn't close stdin or detach from tty.

**Fix: belt-and-suspenders.**

*At caller* (explicit stdin redirect):
```bash
nohup bash script.sh </dev/null > log 2>&1 &
disown
```

*At script entry* (self-defense — safer):
```bash
#!/usr/bin/env bash
set -u
exec </dev/null    # close own stdin immediately, regardless of how caller invoked
```

Self-defense at script entry covers: operator forgetting `</dev/null`, launchd plist missing `StandardInPath`, cron jobs with weird stdin, re-entry from another automation. Trade-off: script can't do interactive prompts — correct behavior for unattended runs anyway.

**Observed:** 2026-04-21 regression-then-investigate.sh chain hung for 17+ min. 11 processes in state `T`:
- regression runner (bash, sleeping on children)
- timeout 30m wrapper
- test-deposit-cancel.sh (bash, stopped)
- 4× `docker compose exec -T mongodb mongosh …` (stopped — the `-T` flag didn't prevent tty probe)
- 2× docker-compose go binary (stopped)
- sub-shell + zombie

User spawned via `bash … &` from interactive zsh. `nohup` wasn't there. Chain collapsed on the first `docker compose exec -T` because mongosh or docker probed tty.

**Applied in:**
- `arra-oracle-v3/scripts/regression-then-investigate.sh` — `exec </dev/null` at entry (commit `f7789bb`)
- `arra-oracle-v3/scripts/w2-watcher.sh` — `exec </dev/null` at entry (commit `f7789bb`)
- Watcher's regression spawn — `nohup … </dev/null … &` (commit `987f21f`)

**Generalization:** Every long-running bash script that spawns docker/curl/ssh grandchildren should `exec </dev/null` at entry. Cheap, no downside for unattended automation. Also recommend `disown` after background spawn to remove from caller's job table (prevents Ctrl-Z propagation to children).

---
*Added via Oracle Learn*
