---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 116
parent_oracle: orchestrator
subject: "#116 done — 21 brewbot chats purged, 20 skipped (worktree-safety gate held)"
needs_response: false
priority: normal
created: 2026-05-16T13:11:00+07:00
---

# Purge brewbot chats — #116 complete

**41 candidate chats** evaluated across the 4 tmux sessions (47 windows total
minus the 6-window keep-list). Result: **21 closed, 20 skipped.**

Keep-list verified intact afterward: `orchestrator-inbox-1778326296` (the live
user chat, pane `%6`), all four `*-oracle` baselines
(`brew-ops`/`bot-writer`/`pg-writer`/`next-architect`), and this session
(`brew-ops-inbox-1778911250`). No `-f` / `rm -rf` used — windows killed via
`tmux kill-window`, worktrees dropped via plain `git worktree remove`, then
`git worktree prune` on all 3 repos.

## Closed (21)

For each: tmux window killed + `git worktree remove` succeeded (verified dir
gone). All were git-clean, zero unpushed commits, claude idle / shell idle.

- **arra-oracle-v3 (14):** wt-10, wt-11, wt-14, wt-15, wt-16, wt-17, wt-18,
  wt-19, wt-20, wt-21, wt-24, wt-25, wt-26, wt-28
- **mobiz-payment-gateway (6):** wt-23, wt-24, wt-25, wt-26, wt-31, wt-32
- **mb-next-payment-gateway (1):** wt-18

Note: the only working-tree entry in the arra-oracle-v3 worktrees was an
untracked `.agent` symlink (the central-memory lens — non-value-bearing); it
was removed as a symlink only, target repo untouched.

## Skipped (20) — gate failed, left intact

### Actively running (2)
- `01-soul-brews` brew-ops-20260516-121936 (wt-27, %49) — pane active ~2m ago, task "Debug orchestrator session TUI selection".
- `02-bank-bot` bot-writer-inbox-1778904954 (wt-1, %33) — pane active ~18s ago (live claude).

### Claude mid-task — open menu / blocked on user (3)
- `01-soul-brews` brew-ops-20260509-175544 (wt-8, %2) — selection menu open mid-task.
- `03-payment-gateway` pg-tester-20260515-073949 (wt-29, %28) — agent posed a blocking question, explicitly "won't proceed until told".
- `20-mb-next` next-writer-20260513-142025 (wt-14, %20) — selection menu open + queued instruction "merge ทั้ง 3 ตามลำดับ".

### Pending operator instruction sitting in the input box (11)
Unsent text typed into the chat — closing would lose the queued instruction.
- `01-soul-brews` brew-ops-20260509-174415 (wt-7, %1) — "ผม push เอง".
- `01-soul-brews` brew-ops-20260511-073724 (wt-12, %12) — input box went non-empty between the pre-check and the kill; the final inline guard caught it, window NOT killed.
- `01-soul-brews` brew-ops-inbox-1778902943 (wt-13, %30) — "dispatch the vector-drift P0 fix now".
- `03-payment-gateway` pg-writer-20260509-191344 (wt-20, %9) — "check the PR opened correctly".
- `03-payment-gateway` pg-tester-20260512-130109 (wt-21, %15) — "merge the PR" (PR #432).
- `03-payment-gateway` pg-writer-20260512-130128 (wt-22, %16) — "check PR #431".
- `03-payment-gateway` pg-tester-20260514-033441 (wt-27, %25) — "no-op pass complete, anything else needed?" (PR #438).
- `03-payment-gateway` pg-writer-20260514-033459 (wt-28, %26) — "check both PRs in the browser" (PR #440).
- `03-payment-gateway` pg-writer-20260515-123158 (wt-30, %29) — "อปเดต current-system.md ...".
- `20-mb-next` next-architect-20260509-181504 (wt-9, %5) — "pg-writer ตอบ thread 107 แล้ว ลองอ่านดู".
- `20-mb-next` next-impl-20260514-135306 (wt-17, %27) — "ตอ P0 #4 wallet-missing rollback เลย".

### Unpushed commits (2)
- `01-soul-brews` brew-ops-inbox-1778906274 (wt-22, %44) — 1 unpushed: `fix(vector): surface LanceDB manifest drift instead of swallowing it (thread #113)`.
- `01-soul-brews` brew-ops-inbox-1778906285 (wt-23, %45) — 1 unpushed: `fix(handoff): file failed-detection handoffs to canonical inbox, not _universal/`.

### Value-bearing untracked files (2)
- `20-mb-next` next-architect-20260509-180226 (wt-8, %4) — untracked `poc/integration/evidence/integration-hosted-run-2026-05-11T10-34-43-778-hosted-tiny.json`.
- `20-mb-next` next-writer-20260513-205057 (wt-16, %22) — untracked `presentation.html` + `presentation.txt`.

## Campaign-#108 protection note

The flagged still-working agents are protected: every `pg-writer` /
`pg-tester` candidate with an open PR or queued instruction (#86 pg-writer
arc) and the `next-impl` worktree (wt-17, #87 arc) landed in the skip list —
none were closed. Only long-idle, fully-clean, fully-pushed sessions were
purged.

## Decision note for orchestrator

I treated a non-empty input box / open menu / blocked-on-user question as a
gate failure even though the literal gate is git-clean + no-unpushed +
not-actively-running. Rationale: those chats carry operator-typed intent that
a window-kill would silently destroy — erring toward the brief's "if any
check fails, skip + report". The 11 "pending instruction" + 3 "mid-task"
chats are the recoverable ones: send/clear their queued message, then a
follow-up purge pass closes them safely. The 2 unpushed + 2 untracked need a
push / commit-or-discard first.

— brew-ops, 2026-05-16 13:11 GMT+7

<!-- handled_at: 2026-05-16T13:15:00+07:00 — type=reply needs_response=false; #116 done, 21 closed / 20 skipped. Archived per §11d. -->
