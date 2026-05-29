---
title: Dual-wake load-run collision — watcher --fresh-spawned a SECOND next-impl sessio
tags: [implementation-architect, repo:mb-next-payment-gateway, next, gotcha, load-test, parallel-session, watcher, thread-254, poc]
created: 2026-05-28
source: thread #254 §D re-run dual-wake collision 2026-05-29; wt-17 vs wt-19
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Dual-wake load-run collision — watcher --fresh-spawned a SECOND next-impl sessio

Dual-wake load-run collision — watcher --fresh-spawned a SECOND next-impl session (wt-19) for thread #254's §D re-run while the "presumed-dead" original (wt-17) was actually alive and also processing the RE-FIRE envelope. BOTH launched run-freetier-feasibility.sh against the SAME hosted CF-Worker→EF→Supabase-Micro substrate within 7 seconds of each other (wt-19 22:09:34, wt-17 22:09:41).

Impact: two concurrent open-loop load drivers on a shared-CPU substrate DOUBLE the real RPS and mutually contaminate every overlapping tier — neither run is apples-to-apples vs the single-driver cf-gateway-216 baseline.

Resolution pattern (extends [[feedback_parallel_session_inbox_misroute]] from inbox-misroute to live-process collision):
1. DETECT early via `pgrep -fl "run-freetier|driver.ts"` — a routine ps check on launch surfaced the peer.
2. TIE-BREAK deterministically and asymmetrically: the watcher's --fresh-spawn (§151 ownership-transfer-on-death) AND earlier start time both pointed to wt-19 as owner → the revived duplicate (wt-17) yields.
3. KILL ONLY YOUR OWN tree, identified by env not by name: `ps eww -o command= -p <pid> | grep FT_OUT=` distinguishes my /tmp/ft254-cfgw-rerun from peer's /tmp/cfgw254. Killing the runner bash does NOT kill the in-flight `bun driver.ts` child — it reparents to ppid=1 and keeps loading; hunt the orphan via `lsof +D <my-out-dir>` / ppid=1 + LOAD_LOG_PATH and TERM it too.
4. ANNOUNCE the yield in-thread so the peer does not ALSO yield (mutual-yield deadlock = neither runs). The session that already killed its run must broadcast "I'm out, you complete."
5. BACKUP: monitor the survivor; re-launch solo only if it dies.

Bonus empirical: even WITH 2× contaminating load, the hygiene+fail-open substrate beat cf-gateway-216 by 3-5× on low-tier p99 and held 20x to 0% 5xx (was 7.34%) — contamination only inflates, so the true solo delta is larger.

---
*Added via Oracle Learn*
