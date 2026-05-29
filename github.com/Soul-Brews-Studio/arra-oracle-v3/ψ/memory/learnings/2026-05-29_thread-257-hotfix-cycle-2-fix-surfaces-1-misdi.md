---
title: thread #257 hotfix cycle — 2 fix surfaces, 1 misdiagnosis (2026-05-29)
tags: [hotfix, thread-257, workflow-2, maw-team, ansi-extraction, oracle-members-missing, team-cleanup-missing, team-invite-missing, chat-watcher-orphan-reap, diagnosis-misattribution, brew-ops, fork-pr-13-maw-js, fork-pr-112-arra-oracle-v3, daemon-restart]
created: 2026-05-29
source: brew-ops thread #257 hotfix 2026-05-29 — maw-js fork #13 (2fcfc844), arra-oracle-v3 fork #112 (6e2d9d47), bot.sh daemon restarted
project: github.com/soul-brews-studio/arra-oracle-v3
---

# thread #257 hotfix cycle — 2 fix surfaces, 1 misdiagnosis (2026-05-29)

thread #257 hotfix cycle — 2 fix surfaces, 1 misdiagnosis (2026-05-29)

Thread #257 was filed by an orchestrator session after a fleet-cleanup campaign. It listed 3 issues; reproduction showed the diagnosis was partly wrong, and turned up a 4th issue the thread missed.

**What the thread got right:**
- `maw team members` broken — `Cannot find module './oracle-members'` ✓
- chat-watcher orphan pattern (transient, after external `tmux kill-window`) ✓
- helper aborted at "could not extract claude cmd" (real symptom) ✓

**What it got wrong:**
- Attributed helper abort to the oracle-members import. Reproduction showed `maw team spawn` doesn't touch `./oracle-members` at all — it works fine and prints `Run: …`. The actual cause was an **ANSI-escape regex bug in `team-dispatch-helper.sh`** (raw bytes `\033[36mRun:\033[0m` couldn't match the literal `^  Run: ` sed pattern). The orchestrator's debug pass conflated two unrelated symptoms.

**What it missed:**
- `maw team delete` ALSO broken — `Cannot find module './team-cleanup'` (same root cause class — files swept by a maw-js release).

**Fixes shipped (2026-05-29, all merged to feat/all-prs-rebased):**
- [[fleet-shared-sub-agents-user-level-sonnet-delega]] + Phase 1 base: kxlahsimx09/maw-js#13 (`oracle-members.ts` + `team-cleanup.ts` + `team-invite.ts` restored verbatim from c4d47b70, the prior #1183 restoration). Merge commit `2fcfc844`.
- kxlahsimx09/arra-oracle-v3#112 — `team-dispatch-helper.sh` ANSI strip (`LC_ALL=C sed $'s/\x1b\\[[0-9;]*m//g'` before the Run-line match) + `bot.sh reap_orphan_watchers()` (walks `pgrep -f chat-watcher.sh`, kills any whose pane is gone from `tmux list-panes -a`; wired into periodic sweep + tail of `cmd_close_all`). Merge `6e2d9d47`. bot.sh daemon restarted to pick up reap (old pid 84943 SIGTERM didn't take → SIGKILL → fresh start as pid 47244).

**Reusable mechanic: diagnosing module-not-found in `maw team`:** the file may be missing from the tree even though git history (e.g. `git log -S 'oracle-members'`) shows commits that should have it. Look for a commit message like *"restore X swept by release"* — that's a tell that the file gets swept periodically and needs another verbatim recovery. The commit at issue last time: c4d47b70 (#1183). A 30-line smoke test (`maw team create + members + delete`) in maw-js `tests/` would catch the next sweep automatically.

**Reusable mechanic: capturing the `Run:` line from `maw team spawn` (or any maw print).** maw colors output with ANSI escapes. Any sed/awk that anchors on literal text must strip CSI sequences first: `LC_ALL=C sed $'s/\x1b\\[[0-9;]*m//g'`. The bytes appear as `\033[<digits>m` — visible via `od -c`.

**Verification-after-fix pattern that worked:**
1. ff both primaries → run live `maw team members <t>` + `delete <t>` → see "No oracle members" / "✓ team deleted" instead of module errors.
2. Live `maw team spawn` + the new sed pipeline → check `${#CMD}` is non-zero (407 chars in this case).
3. Daemon restart: kill old master, nohup new from primary, tail log for fresh boot line, grep on-disk source for the new function — then the reap activates on next 300s periodic sweep (deferred verification, accept).

**For future orchestrator diagnoses:** when something fails in workflow-2, separate "the helper aborted" from "the underlying tool failed". Reproduce each layer in isolation — the orchestrator's diagnosis chain collapsed two unrelated bugs (mine + maw-js's) into one in thread #257.

---
*Added via Oracle Learn*
