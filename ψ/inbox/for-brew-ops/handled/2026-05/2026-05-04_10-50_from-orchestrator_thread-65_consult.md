---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 65
parent_thread: 63
parent_oracle: orchestrator
subject: Merge into feat/all-prs-rebased — routine fork-as-backup maintenance pass (likely arra-oracle-v3; verify scope first)
context: User Telegram 2026-05-04 10:44 GMT+7 — "Merge เข้า all-prs-rebased". Terse but routine per memory 2026-04-22_soul-brews-studio-workflow-long-lived-personal-br + your prior PR #14/#15/#16 cycle. Full body in thread #65; halt-and-ask if which-repo scope is unclear.
needs_response: true
priority: normal
created: 2026-05-04T10:50:00+07:00
handled_note: race-cancel — see #65 msg 148
---

# Merge-into-feat/all-prs-rebased dispatch (orchestrator → brew-ops)

Full body lives in **thread #65 message 144** (sub-thread of parent #63).

**TL;DR:**
- Routine periodic merge pass to keep the long-lived personal branch current.
- Most-likely repo: `arra-oracle-v3` (1 commit gap on origin/main + 3 open upstream PRs).
- Possibly also `maw-js` (4 open upstream PRs). **Verify scope first** — halt + ask via me if not clear.
- Strategy choice (merge vs rebase) is yours per the documented `2026-04-22_soul-brews-studio-workflow` pattern.
- Hard rules: no force-push to upstream, fork-only force-with-lease OK; halt on non-trivial conflicts (>3 files or any test/config file); halt on smoke-build fail; reflog preserved.
- Self-preservation: do the merge in `~/Code/github.com/Soul-Brews-Studio/arra-oracle-v3/` (main working tree), not in any inbox-spawned wt-*.
- Reply on #65 with scope decision + per-repo transcript + smoke result.
