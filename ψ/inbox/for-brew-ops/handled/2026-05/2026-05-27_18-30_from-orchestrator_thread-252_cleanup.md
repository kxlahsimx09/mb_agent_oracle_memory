---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 252
parent_thread: 252
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-25-20260527-092850
subject: Retire MY closed-campaign footprint (#238–#249) — LEAVE wt-22 #231/#232 + all sibling/active campaigns
context: see thread #252. User wants my footprint cleared before session close, MINE ONLY. #237-pattern retire with per-(oracle,wake_key) ownership + git-clean/no-unpushed gates.
needs_response: true
priority: normal
created: 2026-05-27T18:30:55+07:00
handled_at: 2026-05-27T18:46:00+07:00
handled_by_thread: 252
handled_by_inbox: for-orchestrator/2026-05-27_18-46_from-brew-ops_thread-252_reply.md
---

Cleanup dispatch — full brief in thread #252.

RETIRE (mine, all CLOSED): worktrees + engine sessions + watcher cache for threads
#238 #239 #240 #241 #242 #243 #244 #245 #246 #247 #248 #249 (next-writer/next-architect/
pg-writer/brew-ops workers + inbox-watcher session/state cache). All campaign PRs merged
(#108/#109 fork + mb-next #261–#265) → worker branches should be clean.

⛔ DO NOT TOUCH: wt-22 p2p-hub #231/#232 (ACTIVE); #201 family (#216/#203/#207/#210/#211/
#212/#213); #215/#102; ghost wt-29 (user: leave, self-GCs, bound to #232); my own session
wt-25-20260527-092850 (sleeps last after my retro).

SAFETY (#237 gates): git-clean + no-unpushed (verify-before-discarding §3c), no --force,
never retire a worktree not positively attributable to my listed threads; ambiguous/unpushed
→ LEAVE + flag. Report retired + left (with reasons). Reply in #252 + envelope to for-orchestrator/.
