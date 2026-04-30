---
title: title: maw wake template silent-fail blocks Phase 2 inbox automation — root fix 
tags: [brew-ops, repo:cross, repo:maw-js, fleet, mcp-tools, gotcha, decision, directed-inbox, phase-2, wake-silent-fail, 2026-04-30]
created: 2026-04-30
source: brew-ops cold test 2026-04-30 18:22 GMT+7 — wake fired with --fresh --wt --no-attach, claude --continue exited 0, fallback didn't fire, architect pane stuck at shell. User chose Option B (root fix in maw-js) for Phase 2b.
project: github.com/soul-brews-studio/arra-oracle-v3
---

# title: maw wake template silent-fail blocks Phase 2 inbox automation — root fix 

title: maw wake template silent-fail blocks Phase 2 inbox automation — root fix scoped to Phase 2b 2026-04-30
tags: [brew-ops, repo:cross, repo:maw-js, fleet, mcp-tools, gotcha, decision, directed-inbox, phase-2, wake-silent-fail, 2026-04-30]

Rediscovered the maw wake `claude --continue || claude -p '<prompt>'` silent-fail
mode while running the Phase 1 cold test for the directed inbox protocol. This
makes Phase 2a (watcher-fired auto-wakes on inbox files) impossible to ship
correctly until the root cause is fixed in `kxlahsimx09/maw-js`.

# What happened (cold test 2026-04-30 18:22 GMT+7)

Test setup: `maw wake next-architect --fresh --wt cold-test-20260430-182211 --no-attach --task "inbox: 2026-04-30_17-18_from-brew-ops_thread-56_reply.md"`. Goal was to see whether the directed-inbox envelope I had written for `next-architect` was self-explanatory enough for a fresh, charter-naive session to act on.

Observed in `maw peek next-architect-cold-test-20260430-182211`:

```
$ claude --dangerously-skip-permissions --continue || claude --dangerously-skip-permissions -p 'inbox: 2026-04-30_17-18_from-brew-ops_thread-56_reply.md'
No conversation found to continue
DONE
$
```

`claude --continue` exited **0** (success) with the message "No conversation found to continue" because a `--fresh` worktree by definition has no prior session to resume. The shell `||` operator only fires the fallback on non-zero exit. Exit 0 ⇒ fallback skipped ⇒ pane sat at an empty shell prompt with no Claude session running. The architect never received the prompt; the cold test could not measure envelope clarity.

# Why this is a Phase 2 blocker, not just an old gotcha

Prior brew-ops learnings (`2026-04-22_maw-wake-role-fresh-prompt-exits-0-as-so` + the template-fallback recovery commit `6b3662d` to `scripts/w2-watcher.sh`) document this silent-fail. `w2-watcher` works around it by detecting the silent exit and re-sending `claude -p` directly. **The fix lives in the watcher, not in maw.**

The directed-inbox Phase 2a watcher (planned in AGENTS.md §11g) is supposed to fire `maw wake <oracle> --fresh ...` for every first-time inbox file to a thread (per the §11f session-per-thread decision rule). Most inbox-driven wakes will be `--fresh` (the default for first-receipt-in-thread). Each one will silent-fail unless we either:

| Option | Where the fix lives | Trade-off |
|---|---|---|
| **A. Defensive re-send in Phase 2a watcher** | `scripts/w2-watcher.sh` — copy `6b3662d` template-fallback into `scan_inbox()` | Quick to ship; duplicates the workaround across two watchers; every future `maw wake` client repeats it |
| **B. Root fix in maw-js** | `kxlahsimx09/maw-js` (target `feat/all-prs-rebased`) — `maw wake` itself should detect "no session to resume" and run the prompt fallback in-process; or `--fresh` should bypass `--continue` entirely | Right place; benefits every client (watcher, future arra_inbox MCP tool, manual ops); requires maw-js PR cycle |

User decision (2026-04-30): **Option B**. Phase 2b expands from "nice-to-have native `--thread` flag" to "**required: fix wake silent-fail at maw-js root, then add native --thread support**." Phase 2a (watcher inbox scanning) blocks on Phase 2b landing.

# What the maw-js fix looks like (sketch — to be confirmed when the actual PR is scoped)

`maw wake` should not emit the shell template `claude --continue || claude -p '<prompt>'`. Instead it should:

1. Probe whether a continuable session exists for the target oracle (resolve the JSONL path or use claude's own session listing).
2. If yes → run `claude --continue` with the prompt sent as the first user message after attach.
3. If no → run `claude` (interactive) and inject the prompt via `tmux send-keys` after the pane is ready, or run `claude -p "<prompt>"` directly when no interactive attach is needed (`--no-attach` case).
4. `--fresh` flag must skip step 1 entirely and go straight to the no-prior-session path.

The end-to-end success criterion: a `--fresh --wt new-pane --task '<prompt>'` invocation MUST result in a running claude session that has received the prompt, regardless of whether the oracle has prior history elsewhere.

# Phase status update (as of 2026-04-30 18:25 GMT+7)

- **Phase 1:** ✅ Done. AGENTS.md §11 ratified through routing-fix (commits `04c859e` + `aa05b73`). Manual-fire dogfood validated envelope format on a single round-trip.
- **Phase 2b (now blocking):** Open a PR in `kxlahsimx09/maw-js` (branch from `feat/all-prs-rebased` per SKILL.md maw-js workflow) to fix `maw wake` silent-fail + add `--thread <N>` native flag. ETA: separate session — out of scope for this brew-ops conversation.
- **Phase 2a (blocked):** `scripts/w2-watcher.sh` `scan_inbox()` extension waits until Phase 2b lands. Implementing 2a first would mean shipping the template-fallback workaround twice (in w2-watcher.sh and again wherever the next `maw wake` client appears).
- **Phase 3** unchanged.

# How to apply

1. When the maw-js PR is opened, drop `Closes` references to this learning + the 2026-04-22 silent-fail learning + the w2-watcher commit `6b3662d` so the fix carries the full prior-art chain.
2. After the maw-js PR merges into `feat/all-prs-rebased` and a new `maw` build is installed locally, re-attempt the cold test (Option A) for the directed-inbox protocol. Success criterion: `maw wake next-architect --fresh --wt ... --task "inbox: ..."` lands at a running claude session that has the prompt visible.
3. Only then implement Phase 2a in `arra-oracle-v3` (watcher extension).

# What this learning supersedes

Nothing — it adds to the chain. The 2026-04-22 silent-fail learning remains true (still describes the bug). This learning records the next consequence: the bug's continued presence blocks an entire new feature line.

---
*Added via Oracle Learn*
