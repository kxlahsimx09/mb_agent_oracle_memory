---
title: Orchestrator status reports MUST be evidence-verified, never assumed — check the
tags: [orchestrator, status-reporting, verify-not-assume, ghost-text, rate-limit, lane-state, honesty]
created: 2026-06-13
source: orchestrator-buildteam wt-26, thread #16 (owner directive)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Orchestrator status reports MUST be evidence-verified, never assumed — check the

Orchestrator status reports MUST be evidence-verified, never assumed — check the agent's actual pane + the real artifact, not "what it should be doing."

**Owner directive (2026-06-13, orchestrator-buildteam wt-26):** "เวลาคุณตามงานอย่าเชื่อว่า agent กำลังทำอยู่ ให้ไปดู session agent จริงๆว่าทำอยู่จริงไหม — ผมไม่อยากได้รายงานที่บอกว่าทำอยู่แต่จริงๆ idle." The orchestrator twice reported lanes as "actively working" when they were actually idle: said next-tester was "กำลังสร้าง probes" when it had already finished + opened the PR and was idle-waiting for review; and assumed dev-2 was holding per instruction when it had actually built AUTH-009 dev-first (a workflow violation) — both were "believed-it-should" not "verified-it-is."

**Why it happens:** (1) trusting the task-list spinner / ◼ in_progress marker, which goes stale when a lane stalls on a transient API rate-limit (idle pane, stale marker); (2) reading the TUI's ghost-text auto-suggestion (the dimmed text after `❯`) as if it were the lane's real work; (3) reporting the dispatched intent ("I told it to X") as current state without re-checking.

**How to apply — before EVERY status report to the owner, for EACH lane:**
1. `tmux capture-pane` the lane and classify by the BOTTOM line: `esc to interrupt` = BUSY (genuinely processing); bare `❯` = IDLE; `API Error / limiting requests` = RATE-LIMITED-stalled (needs a re-nudge).
2. The text AFTER `❯` is often a ghost-text AUTO-SUGGESTION (dimmed), NOT real work — never read it as status.
3. Confirm with the real ARTIFACT: `gh pr view/list` for PR state, the committed files, the inbox envelope — not the spinner.
4. Report the three states distinctly: BUSY / IDLE-correctly-waiting-on-a-dependency / IDLE-stalled-needs-nudge. Never collapse them into "working."
5. A dispatched instruction is NOT evidence the lane did it — re-verify (esp. holds: a lane told to "hold" may have kept going; a lane told to "self-merge" may be sitting on an approved-but-open PR).

---
*Added via Oracle Learn*
