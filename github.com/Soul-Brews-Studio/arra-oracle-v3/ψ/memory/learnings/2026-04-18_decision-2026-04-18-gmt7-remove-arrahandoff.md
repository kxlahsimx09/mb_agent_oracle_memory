---
title: Decision (2026-04-18, GMT+7) — Remove arra_handoff() from all workflows; close a
tags: [brew-ops, memory, workflow, decision, arra_handoff, arra_thread, deprecation, anchor-discipline, repo:cross, p-001, p-003]
created: 2026-04-18
source: 2026-04-18 brew-ops session, triggered by human noting arra_handoff has no subscriber model and pending work sits unactioned
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Decision (2026-04-18, GMT+7) — Remove arra_handoff() from all workflows; close a

Decision (2026-04-18, GMT+7) — Remove arra_handoff() from all workflows; close all inbox handoffs

Background: `arra_handoff` as a tool writes a file to `ψ/inbox/handoff/` but there is no subscriber model — no agent auto-picks up handoffs and forwards to the right role. In practice, the human has been manually reading each inbox item and triggering follow-up work. The `arra_handoff` tool was therefore surfacing pending work that looked like it would be actioned automatically but wasn't.

Scope of this sweep:
1. **18 workflow/skill/charter files** across mobiz, bank-bot, and arra-oracle-v3 `.agent/` trees were edited to either remove `arra_handoff` usage or convert it to `arra_thread` + `[AWAITING_THREAD:<id>]` anchor pattern.
2. **17 inbox handoff files** were moved to `ψ/inbox/handoff/closed/2026-04-18/` subdirs (across 3 vault locations: universal ψ + kokarat/mobiz + kokarat/bank-bot). Files preserved per P-001; moved with `git mv` for history continuity. Plain `mv` used for the one untracked file.

Classification rules applied:
- "arra_handoff as PR pointer" (DoD checkboxes, session-end markers) → **removed entirely.** PR tracking lives in the PR itself; retro is the state carrier for next session.
- "arra_handoff for session-pause state transfer" (SKILL.md patterns) → **removed.** The `rrr` retro with AI Diary + Honest Feedback already captures state. No need for a second channel.
- "arra_handoff as question to another role" (workflow-4 (B) escalation, W9 W8 revision scheduling, brew-ops audit remediation) → **converted to `arra_thread`** + `[AWAITING_THREAD:<id>]` anchor in a doc, mirroring the thread-first pattern established in the 2026-04-18 workflow-2 Escalation rewrite.
- "arra_handoff as a keyword in retro signal scans" (brew-ops workflow-5 §13 AI Diary keyword list) → **left in place.** Past retros still mention the tool name and serve as historical signal.
- "arra_handoff in charter tool descriptions" (AGENTS.md tool list, vault_path paragraphs) → **left in place.** Describes reality of what MCP tools exist; not a workflow instruction.

Files edited (full list):
- `mobiz/.agent/AGENTS.md` §7 minimum discipline
- `bank-bot/.agent/AGENTS.md` §7 minimum discipline
- `Soul-Brews-Studio/arra-oracle-v3/.agent/AGENTS.md` §7 minimum discipline
- `mobiz/tester/SKILL.md` pause/finish pattern + `tester/workflow-2-add-new-test-case.md` per-test handoff step
- `mobiz/technical-writer/SKILL.md` pause/finish pattern
- `mobiz/technical-writer/workflow-1-baseline-current.md` DoD
- `mobiz/technical-writer/workflow-2-track-commit.md` DoD
- `mobiz/technical-writer/workflow-4-reconcile-drift.md` 6 mentions (outcome (B), step 4, DoD × 3, escalation)
- `mobiz/technical-writer/workflow-8-flow-map.md` DoD
- `mobiz/technical-writer/workflow-9-track-flows.md` step 5d + DoD
- `bank-bot/technical-writer/SKILL.md` + workflow-1 + workflow-2 + workflow-4 (mirrors of mobiz edits)
- `brew-ops/SKILL.md` pause/finish pattern
- `brew-ops/workflow-5-memory-audit.md` 8 mentions (autonomy header, §13b real-gap remediation, §14e output, §14f remediation, §15 persist, escalation matrix × 2, DoD)
- `brew-ops/workflow-6-pre-push-memory-check.md` peer-content escalation

Why this matters:
- P-001 (Nothing is Deleted): handoff files preserved under `closed/2026-04-18/` — not deleted, just out of active inbox view. Next brew-ops audit §10 sees 0 pending handoffs (clean baseline); the `closed/` subdir is a durable audit trail.
- P-003 (External Brain, Not Commander): `arra_thread` is inherently a consultation channel — agents read threads as input. `arra_handoff` tried to be a command channel ("tell role X to do Y") without a dispatcher; the gap caused work to sit unactioned.
- Pattern consistency: the 2026-04-18 Escalation rewrite already established thread-first for verification asks. This sweep extends the same discipline to task-delegation and session-pause semantics. Fewer channels, clearer resolution.

How to apply — for agents reading this in a future session:
- Don't call `arra_handoff` unless you have a specific reason to keep a non-indexed inbox file (there are currently no such reasons documented).
- For questions or task delegation → `arra_thread(title=..., message=...)` + anchor.
- For session-end state → write the retro (`rrr`). The retro is the state carrier.
- For PR tracking → live in the PR; don't duplicate into Oracle.
- To check closed handoffs: `ls ψ/inbox/handoff/closed/YYYY-MM-DD/` in the relevant vault subtree.

Who did this edit: brew-ops (me), with human approval, as a meta-workflow pattern (channel discipline) not domain content. Peer roles (`tester`, `technical-writer`) can counter-edit on their next pass if they disagree.

---
*Added via Oracle Learn*
