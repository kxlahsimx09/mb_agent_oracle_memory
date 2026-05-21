---
title: §11d loop-closure hook — Check 2 trusted frontmatter presence, not the reply art
tags: [brew-ops, inbox-watcher, loop-closure, directed-inbox, gotcha, 11d, stop-hook, thread-159, fleet]
created: 2026-05-17
source: parent thread #159 — brew-ops root-cause reply msg 465
project: github.com/soul-brews-studio/arra-oracle-v3
---

# §11d loop-closure hook — Check 2 trusted frontmatter presence, not the reply art

§11d loop-closure hook — Check 2 trusted frontmatter presence, not the reply artifact (fixed, fork PR #78) 2026-05-17

The §140 inbox-loop-closure `Stop` hook (`inbox-loop-closure-hook.sh`, global hook in `~/.claude/settings.json`) is meant to block a session stop when an agent finished a `needs_response: true` consult without writing the reply envelope. It fires correctly on every stop — fresh AND resumed sessions — oracle identification via the watcher's recorded `session_id` works.

The defect: the hook's Check 2 cleared the gate on the mere *presence* of the `handled_by_inbox` or `handled_note` frontmatter field on the archived inbound envelope — it never verified a reply envelope artifact actually existed. On 2026-05-17 next-architect archived a `needs_response: true` consult (thread #148 Phase C) with `handled_by_inbox` set to the inbound envelope's own basename (not a reply path) and a verbose `handled_note` (misuse — `handled_note` is the §11g moot marker). Both fields non-empty → Check 2 `continue` → stop allowed → no reply envelope → orchestrator never woken; the finished Phase C checkpoint sat unrouted ~33 min until a manual check.

Not `--resume`-specific (the orchestrator's initial hypothesis, disproved by brew-ops): any agent, fresh or resumed, that mis-stamps those fields defeats the gate.

Fix (fork `kxlahsimx09/arra-oracle-v3` PR #78, branch `fix/loop-closure-verify-reply-artifact`, base `feat/all-prs-rebased`, pending review/merge): Check 2 now (1) globs the requestor's inbox root + `handled/` for `*_from-<oracle>_thread-<id>_reply.md` — the artifact the watcher actually wakes on; (2) if absent, queries the Oracle API thread status — `closed` = legitimate §11g moot; (3) if API unreachable, degrades to the old `handled_note` moot escape so an outage cannot wedge sessions. `handled_by_inbox`/`handled_note` are now advisory only. Regression test `tests/cli/inbox-loop-closure-hook.test.ts` (7 cases); `tests/cli` 50/50 green.

After merge: re-run `scripts/install-inbox-loop-closure-hook.sh` to refresh `~/.claude/hooks/`.

Orchestrator note: dispatching a fleet-debug task with an explicit hypothesis BUT instructing the agent to disprove it if the evidence disagrees works well — brew-ops disproved the `--resume` lead and found the real (frontmatter-trust) cause. Second such pattern this session (cf. thread #156). Tags: #repo:arra-oracle-v3 #fleet #inbox-watcher #gotcha #directed-inbox #brew-ops #11d

---
*Added via Oracle Learn*
