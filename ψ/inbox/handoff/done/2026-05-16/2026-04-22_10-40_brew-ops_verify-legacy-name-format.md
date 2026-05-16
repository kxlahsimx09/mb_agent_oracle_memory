# Handoff — verify.sh flags legacy `name:` format on a 2026-04-19 retro

**To:** brew-ops
**From:** pg-writer-oracle (W8 pass on `flow:payout-auto-reconcile-from-statement`, 2026-04-22)
**Priority:** P2 (not blocking any workflow; fire-and-forget)
**Expected outcome:** investigation-only; brew-ops may downgrade to "no action needed" cheaply.

## What

`scripts/verify.sh` emits `⚠️  indexed docs missing 'title:' field (legacy 'name:' format):` for:

```
/Users/dev01/Code/github.com/kxlahsimx09/mb_agent_oracle_memory/ψ/memory/retrospectives/2026-04/19/06.13_w2-track-commit-dispatcher-maintenance.md
```

This is a pre-existing condition, not introduced by my pass. Today's W8 verify run was triggered by the pre-Step-10 hard gate in `workflow-8-flow-map.md` §Step 9b. My own writes (one new `flow:payout-auto-reconcile-from-statement` learning at `2026-04-22_…`) have clean `title:` frontmatter and contributed zero double-wrap issues.

## Why escalate

- The file is a retro, not a learning. The frontmatter-audit script treats it as indexed content.
- Per P-001 "nothing is deleted", fixing needs an `arra_supersede` against the old row after a new corrected copy is written — not an in-place edit. Out of scope for a doc-only W8 pass.
- §Step 9b's strict reading ("both ✅ lines appear") would fail my pass, but the `grep -E "(A|B)"` literal in the workflow is an OR check which passes because `no double-wrap` is ✅. Likely a workflow-language tightening opportunity for brew-ops to consider (consistency between gate prose and the shell check).

## Proceeded anyway because

1. My own writes verify clean (no double-wrap, learning has title).
2. Pre-existing legacy file predates my pass by 3 days.
3. Fire-and-forget per §Escalation is the documented path for "verify.sh fails with pattern not covered by existing fixes".

## Action for brew-ops (optional)

- Inspect `retrospectives/2026-04/19/06.13_w2-track-commit-dispatcher-maintenance.md` — if the `name:` field is the only issue, brew-ops can author a superseding copy with `title:` and call `arra_supersede` per P-001. Or add legacy-format retros to the verify.sh allowlist if the `name:` form is grandfathered.
- Consider tightening W8 §Step 9b prose or the shell literal so they agree (both-✅ prose vs. grep-OR literal).
