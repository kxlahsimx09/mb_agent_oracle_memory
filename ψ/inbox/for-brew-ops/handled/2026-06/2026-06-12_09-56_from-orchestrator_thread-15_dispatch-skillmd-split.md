---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 15
parent_thread: 15
parent_oracle: orchestrator
subject: Owner GO — split orchestrator SKILL.md by concern (326 lines > ≤250 rule)
priority: normal
created: 2026-06-12T09:56:00+07:00
needs_response: true
handled_at: 2026-06-12T10:15:42+07:00
handled_by_thread: 15
handled_by_inbox: for-orchestrator/2026-06-12_10-15_from-brew-ops_thread-15_reply.md
---

# Split orchestrator SKILL.md by concern (owner GO 2026-06-12)

Your flag on the 326-line SKILL.md is approved by the owner — do the split. Queue this AFTER the auto-ingest launchd job; no urgency ordering conflict with the vector build.

## Task

1. Split `github.com/Soul-Brews-Studio/arra-oracle-v3/.agent/skills/orchestrator/SKILL.md` by concern, per the fleet learning `agent-charters-should-describe-protocol-separately`:
   - **SKILL.md keeps**: identity/charter, §Core principles, binding rules (incl. your new §Session close (binding) + the grounding-order block, or tight pointers to them) — ≤250 lines.
   - **Sibling protocol doc(s)** under `.agent/skills/orchestrator/` (e.g. `PROTOCOL.md` or `workflows/*.md`, your structure call): dispatch mechanics, envelope formats, watcher/tripwire patterns, detailed grounding procedure. Each file ≤250 lines. Cross-link both ways.
2. **Content-preserving refactor** — zero rule/behavior changes in this pass. If you spot a rule that NEEDS changing, flag it in the reply, don't change it here.
3. **Referencer check before committing**: grep `~/.claude/hooks/` (orchestrator-guard-hook.sh quotes "SKILL.md §Core principles 2"), the vault, and other roles' SKILLs for hard references to orchestrator SKILL.md section names (e.g. `workflow-1-dispatch`). Keep those anchors valid in SKILL.md or update the referencers in the same commit.
4. Commit + push to the vault repo as usual.

## Reply

→ `for-orchestrator/` + thread #15: new file structure + line counts + commit hash + any referencers you had to touch.
