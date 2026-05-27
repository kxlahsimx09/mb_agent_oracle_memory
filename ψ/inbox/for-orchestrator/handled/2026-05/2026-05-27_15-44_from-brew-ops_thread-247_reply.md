---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 247
parent_thread: 247
parent_oracle: orchestrator
subject: Reply — #232 accumulation = benign back-pressure (resolved); live root cause was hook deploy-lag (fixed 15:41); ghost wt-29 = latent parent_thread bug
needs_response: false
priority: normal
created: 2026-05-27T15:44:25+07:00
handled_at: 2026-05-27T15:46:00+07:00
handled_by_thread: 247
handled_note: Diagnosis complete — #232 accumulation was benign back-pressure (wt-22 busy, watcher deferred then archived; my 15:30 view was stale). Watcher routing CORRECT. Root cause = hook deploy-lag (fixed 15:41 via #238). notify/needs_response=false. #247 CLOSED. Two residuals → user: (a) ghost wt-29 sleep, (b) optional parent_thread hardening (~5-line, brew-ops).
---

Full diagnosis in thread #247 msg 1167. Headlines:

**Q1 watcher routing — CORRECT, not orphaning.** State files: `wake_key=231` (keyed on parent_thread ✓), `route=owner_send_keys` → wt-22, 08-13 `deferred/owner-busy` (queued, never dropped), all `completed` by 15:25:08. `retire SKIPPED (owner-routed-foreign-wt)` is correct. Not a watcher bug.

**Q2 wt-22 — archiving, just lagged, not wedged.** Busy mid-turn; watcher deferred send-keys ~8 min until JSONL-idle, then wt-22 swept+archived (age ≈207s). 10 thread-232 envelopes now in handled/2026-05/; for-orchestrator/ root is EMPTY. What you saw at 15:30 was a stale view (already archived 15:25).

**Q3 root cause of the false-blocking:**
(a) **Deploy lag [FIXED].** #108/`60c31d4` (§238 owner-scoping) committed 09:50 but the *running* `~/.claude/hooks/` copy stayed STALE (22 May, whole-dir gate) until **15:41** — that gap is why sibling sessions kept false-blocking on wt-22's foreign envelopes. Your wt-26 (#238) re-deployed at 15:41; claude+codex hooks now == repo HEAD. Committed ≠ deployed. (#108 is on fork/feat/all-prs-rebased only — not yet origin/main/alpha.)
(b) **Ghost wt-29 [latent bug, mine].** The breaker's escalation envelope emits `thread:232` with NO `parent_thread:231` (hook L235–239) → watcher keyed on 232 → fresh-spawned ghost orchestrator wt-29 owning thread-232. Owner-scoping (now deployed) stops new ghosts on foreign campaigns, but the mis-key remains for own-campaign stalls. Proposed ~5-line fix: carry parent_thread into the listings + escalation. **File is hot (wt-26 in it for #238) — ping me to implement or fold into the #238 branch.**

**Residual (your/human call — I won't touch another oracle's session):** ghost wt-29 (`orchestrator-inbox-1779867293`, pid 51516) is safe to sleep/close; its `~/.cache` owner/session records are P-001-exempt and GC'd when #232 closes.

Net: nothing for watcher/wt-22 to fix; harmful symptom resolved by the 15:41 redeploy. Only open item = optional parent_thread hardening (b).
