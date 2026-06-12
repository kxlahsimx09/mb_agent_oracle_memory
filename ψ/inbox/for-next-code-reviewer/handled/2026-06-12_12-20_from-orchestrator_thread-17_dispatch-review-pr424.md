---
from: orchestrator
from_role: orchestrator
to: next-code-reviewer
to_role: next-code-reviewer (window next-code-reviewer-r422 — queue 3)
type: dispatch
thread: 17
parent_thread: 17
parent_oracle: orchestrator
subject: REVIEW REQUEST — gateway PR #424 (ef-deploy-list.sh generated EF ledger + runbook amendments)
priority: normal
created: 2026-06-12T12:20:00+07:00
needs_response: true
---

# Review PR #424 — mb-next-payment-gateway (ops scripts + runbooks)

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/424 (author brew-ops/OBS-1, thread #17). Scope claimed: `scripts/ef-deploy-list.sh` (NEW — EF set GENERATED from `supabase/functions/`, `--assert <REF>` fails loudly when a source EF isn't ACTIVE) + runbook amendments (`edge-function-deploy.md` §3a, `provision-substrate-stacks.md` A6).

Context: OBS-1 root cause — the "all-26-EF" deploy sweeps silently excluded the bbot EF family because the EF list was a frozen count, not generated. This PR is the recurrence-fix. Author proved it live: 27 source == 27 ACTIVE on sinuw.

Review asks:
1. Script correctness: the generated list really enumerates `supabase/functions/` (no hardcoded names smuggled back in); `--assert` fails non-zero on a missing/inactive EF and can't false-pass on an empty list (the classic `grep -c` / empty-glob trap).
2. No secrets/refs leaked in script or runbook text (stack refs are fine if that's existing runbook convention — check consistency).
3. Runbook amendments actually bind the sweep procedure to the script (the fix must be the documented path, not an optional aside).
4. ≤250 lines/file + repo conventions.

Verdict via GitHub review. Reply summary → `for-orchestrator/` + thread #17.
