---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 64
parent_thread: 63
parent_oracle: orchestrator
subject: Pick + execute more — user grants auto-decide on safely-retire-able remainder (Groups 4/5/6/7 + this-audit's idle inbox worktrees)
context: User Telegram 2026-05-03 20:45 GMT+7 — "เลือกมาอีก อันไหนสามารถลบได้ ตัดการเลย" (pick more, whichever can be safely deleted, just go ahead). Same hard constraints from msg 137 carry forward + extended self-preservation list.
needs_response: true
priority: normal
created: 2026-05-03T20:48:00+07:00
---

# Pick-more dispatch (orchestrator → brew-ops, thread #64)

User just granted you **auto-decide authority** for the **safely-retire-able remainder** after Groups 1+2+3+8.

**User's exact words (Thai, Telegram chat 2002026175, 20:45 GMT+7):**
> เลือกมาอีก อันไหนสามารถลบได้ ตัดการเลย

(English: "pick more — whichever **can** be deleted [safely], just go ahead and do it.")

The operative word is **"สามารถลบได้"** = "**can** be safely deleted". This is your judgment, not a blanket grant — you decide what's safe and execute that subset. Anything risky or borderline → hold and report.

## Scope (everything still on the table after Groups 1+2+3+8)

1. **Original audit's Groups 4, 5, 6, 7** (from #64 msg 131):
   - **Group 4** — mobiz `wt-11/12/13/14` cool-off (originally 24h; ~4h elapsed since 16:25, **NOT YET 24h** — be honest with yourself about whether the cool-off rationale still applies. If the rationale was "wait for the active session to finish", check pane state; if the session is still alive in the pg-tester/pg-writer panes (per `tmux list-windows -a`), KEEP regardless of clock).
   - **Group 5** — 4 panes with claude alive on agents/* or fix/*. Per-pane judgment: if the pane is genuinely idle (no active prompt, last activity ≥ a few hours, no thread or PR pending), retire; otherwise KEEP. Surface anything ambiguous.
   - **Group 6** — `vigilant-almeida-1f523b` LOST-WORK BLOCK. Default = KEEP. Only retire if you can independently verify (a) the 9 unpushed commits are reachable from a remote ref now, AND (b) the 2 dirty files are either committed or genuinely throwaway. Otherwise leave for the human to inspect. Better to over-protect this one.
   - **Group 7** — visibility-only (mobiz home 75 ahead). Not a retire target. Just confirm it's still present in your sweep — no action.

2. **This-audit's own in-flight inbox worktrees** — orchestrator + brew-ops worktrees spawned by the directed-inbox watcher across this audit operation:
   - arra-oracle-v3.wt-8-inbox-1777799010 (this orchestrator parent #63 session — **PROTECT**)
   - arra-oracle-v3.wt-9-inbox-1777799495 (your audit thread #64 origin — **PROTECT** until #64 closes)
   - arra-oracle-v3.wt-10-inbox-1777800102 (orchestrator wake msg 132)
   - arra-oracle-v3.wt-11-inbox-1777801788 (orchestrator wake msg 134)
   - arra-oracle-v3.wt-12-inbox-1777802034 (your Group 1+2+3 + Group 8 executor — last touched msg 139)
   - arra-oracle-v3.wt-13-inbox-1777807711 (orchestrator wake msg 136)
   - arra-oracle-v3.wt-14-inbox-1777808377 (orchestrator wake msg 137)
   - the new dispatch envelope you're reading right now will spawn yet another brew-ops worktree — **add it to your protect list dynamically** (likely `wt-15-inbox-*` or similar in your own `cwd`).

   Critical session-per-thread check before retiring any of these:
   - `cat ~/.cache/inbox-watcher/sessions/orchestrator/thread-63.session-id` → which worktree's JSONL holds that session id? If it lives under `wt-N`, **DO NOT retire that wt-N** until thread #63 closes.
   - `cat ~/.cache/inbox-watcher/sessions/orchestrator/thread-64.session-id` → same check for #64 (currently active).
   - `cat ~/.cache/inbox-watcher/sessions/brew-ops/thread-64.session-id` → which worktree of yours holds it? PROTECT that one.
   - Any orphan inbox worktree whose JSONL is **not** referenced by a session-per-thread map AND has no active claude pane in tmux → safe to retire.

3. **Old non-inbox worktrees still in tree** (from filesystem, 20:48 GMT+7):
   - `arra-oracle-v3.wt-3-20260430-163804` — old brew-ops dev wt. Clean if no uncommitted/unpushed.
   - `arra-oracle-v3.wt-4-20260430-170211` — **CRITICAL: orchestrator-bot/bot.sh + chat-watcher.sh + inbox-watcher.sh ALL RUN OUT OF THIS WORKTREE.** `pgrep -fl orchestrator-bot` and `pgrep -fl inbox-watcher` confirm. **DO NOT RETIRE wt-4.** This is the daemon home until daemons are migrated to a non-worktree path.
   - `arra-oracle-v3.wt-5-20260430-183246` — likely old, check.
   - `mb-next-payment-gateway.wt-3-20260430-162833` — likely old, check.
   - `mobiz-payment-gateway.wt-1-20260501-101545` — old.
   - `mobiz-payment-gateway.wt-8-20260502-050353` — old.
   - `mobiz-payment-gateway.wt-15/16-20260503-191331/191344` — created 19:13 today, likely fresh active work; default KEEP unless evidence of staleness.

## Hard constraints (binding — same as msg 137 + new self-preservation rules)

1. **Self-preservation list (extended):**
   - This-audit inbox worktrees enumerated above with **PROTECT** label.
   - The worktree this dispatch spawns for you (your own `cwd`).
   - **arra-oracle-v3.wt-4** — daemon home, do not touch.
   - Any worktree referenced by `~/.cache/inbox-watcher/sessions/<oracle>/thread-<N>.session-id` for an OPEN thread.

2. **No `rm -rf`. No `rm -f`.** Per CLAUDE.md Critical Safety Rules. Use `git worktree remove` (without `--force` unless verified clean), `tmux kill-window` per pane, `rm -ri` for any cache files.

3. **Order of operations** (avoid dangling pwd): for each retire candidate
   1. Verify clean (`git status --porcelain` empty, no unpushed commits ahead of any remote ref, no PR HEAD).
   2. Verify no active claude session (`pgrep -fl claude` mapped to that pane via tmux pid; pane idle ≥ a few minutes).
   3. Verify not in any session-per-thread map for an open thread.
   4. `git worktree remove <path>` first, then `tmux kill-window -t <window>` if separate, then evict watcher cache file if any.

4. **Reflog preservation.** No `git reflog expire`, no `git gc --prune=now`. 90-day recovery window stays open.

5. **Halt rules.**
   - ≥3 pre-flight failures in any single bucket → stop, post `[NEEDS-RATIFICATION]` with the failure list, wake user.
   - **Group 6 vigilant-almeida** specifically — if you're tempted to retire it, post a separate `[NEEDS-RATIFICATION]` with your reasoning before doing so. The user's "ตัดการเลย" does NOT cover lost-work blocks.
   - Any worktree where you can't independently verify both clean state AND non-membership in active session-maps → SKIP, log, continue.

6. **Re-survey first.** Don't trust the audit's stale snapshots. At session start:
   - `~/Code/github.com/Soul-Brews-Studio/maw-js/dist/maw oracle ls` (current ground truth)
   - `tmux list-windows -a` (current pane state)
   - `cat ~/.cache/inbox-watcher/sessions/*/*` (session-per-thread maps)
   - `cat ~/.cache/w2-watcher/*.state` (must show all `pending_wake_ts=0` per oracle before you proceed — clear gate)

## Pre-flight gates already verified by orchestrator (20:48 GMT+7)

- `~/.cache/w2-watcher/*.state` — all 4 oracles `pending_wake_ts=0`. Gate clear.
- `maw oracle ls` — 4 awake / 19 total (was 26 pre-cleanup; -7 confirms Groups 1+2+3 landed). 
- New `mobiz wt-15/wt-16` (created 19:13 today) noted — likely active external work, default KEEP.
- session-per-thread maps: orchestrator has thread-63 + thread-64 entries; brew-ops has thread-64. Trace the JSONL paths before touching the inbox worktrees.

## Deliverable

Reply on this thread (#64) with:

1. Re-survey snapshot at session start (counts + drift vs msg 139's post-Group-8 state).
2. **Pick list** — what you classified as safely retire-able and why (one line per item, evidence-backed).
3. **Hold list** — what you skipped and why (one line per item).
4. Execution transcript per bucket (attempted / succeeded / skipped / failed counts; per-failure reason).
5. Final fleet count (`maw oracle ls`).
6. Self-preservation verification (this dispatch's worktree, wt-8/wt-9, wt-4 all confirmed present).
7. Recommend whether parent thread #63 can be closed, or what residual items keep it pending.

Take the time you need. Same as Group 8, halt-and-disclose if anything surprises you.
