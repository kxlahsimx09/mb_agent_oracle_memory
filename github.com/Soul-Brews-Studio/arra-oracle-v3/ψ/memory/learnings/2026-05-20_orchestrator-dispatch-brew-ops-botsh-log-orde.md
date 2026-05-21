---
title: **orchestrator dispatch — brew-ops bot.sh log-order fix resolved auto (2026-05-2
tags: []
created: 2026-05-20
source: parent thread #180 (closed 2026-05-20T12:33:40Z), fork PR #84 merged 2026-05-20T12:27:58Z (9a1aae66)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **orchestrator dispatch — brew-ops bot.sh log-order fix resolved auto (2026-05-2

**orchestrator dispatch — brew-ops bot.sh log-order fix resolved auto (2026-05-20)**

Request: routine startup-log review surfaced `log: Unknown subcommand 'loaded 8 roles...'` noise in `~/.cache/soul-brews-startup/brew-ops-bot.log` on every brew-ops bot boot. Root cause: `bot.sh` defined `log()` at L100 but `load_roles()` body called it from L86, invoked at top-level L88 → bash fall-through to macOS `/usr/bin/log`.

Classification: **2a-trivial-direct** (single agent, single sub-thread, no aggregation).
Confidence at dispatch: **HIGH** (≥3 prior 2a-trivial-direct accepted patterns for brew-ops cosmetic/audit work: thread #116 fleet-purge, #156 fleet-debug, #158 audit).

Sub-thread: **#180** (no parent — 2a omits parent thread per workflow §2a).
Target oracle: brew-ops.

**Process correction during dispatch:** initial attempt sent the fix request via `telegram_send` (wrong channel: Telegram is human↔bot, not agent↔agent); user corrected with "ใช้ thread inbox", then again with "ลองอ่าน SKILL ของ role orchestrator". Re-dispatched correctly: opened thread #180, wrote envelope at `for-brew-ops/...consult.md` with `parent_session` stamped to orchestrator worktree, dropped `parent_thread` field per 2a convention. Companion process-violation learning filed separately (`2026-05-20_orchestrator-dispatch-procedure-violation-ski`).

**Outcome:**
- brew-ops shipped fork PR #84 (`fix(brew-ops-bot): define log/audit before load_roles invoke`) within ~5 minutes of dispatch envelope.
- User merged PR #84 at 2026-05-20T12:27:58Z (`9a1aae66`).
- orchestrator wrote a continuation envelope ("PR merged, run smoke + close") at 19:32 → brew-ops at PID-different session restarted the bot (PID 88424→28753) and ran the 3 acceptance items.
- Smoke acceptance: (1) ✅ `grep "Unknown subcommand"` empty for the new boot window; (2) ✅ `loaded 8 roles across 4 repos: ...` written by in-script `log()` to `~/.cache/brew-ops-bot/bot.log`; (3) ⚠️ shellcheck not installed locally, `bash -n` clean (non-blocking).
- brew-ops closed thread #180 at 2026-05-20T12:33:40Z.

User reaction: **accepted** (user merged PR, no redirect on dispatch shape, no correction on acceptance criteria). Initial channel/SKILL-violation corrections were process-level not outcome-level; the actual dispatch and outcome were both accepted.

**Reusable orchestrator pattern observations:**
- 2a-trivial-direct dispatches with HIGH confidence land fast (~5-10 min architect-class-equivalent for brew-ops cosmetic work).
- Continuation envelopes (`type: notify`) on the same sub-thread with the same `parent_session` are the right shape for "user merged the PR, run the post-merge smoke" handoffs. No new sub-thread needed; the thread is one campaign.
- shellcheck-not-installed observation is a fleet-hygiene followup, not a blocker; brew-ops surfaces it themselves in the smoke transcript without orchestrator escalation.
- Post-restart `recover_watchers` correctly re-picked up the live inbox-1779279627 worktree (orchestrator session continuity preserved across bot restart) — confirms the gc-sweep liveness gate (#179, PR #83) is working end-to-end now that it's deployed.</pattern>
<parameter name="concepts">["orchestrator", "decision-authority", "2a-trivial-direct", "accepted", "brew-ops", "cosmetic-bug-fix", "bot.sh", "log-order-bug", "shell-function-resolution-order", "thread-180", "continuation-envelope-on-same-sub-thread", "post-restart-recover-watchers-verified"]

---
*Added via Oracle Learn*
