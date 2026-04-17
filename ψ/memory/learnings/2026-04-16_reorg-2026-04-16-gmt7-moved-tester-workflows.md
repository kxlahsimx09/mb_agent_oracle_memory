---
title: Reorg (2026-04-16, GMT+7) — Moved tester workflows from flat `.agent/workflows/`
tags: [tester, repo:mobiz-payment-gateway, current, decision, agent-design, refactor, skill-layout]
created: 2026-04-16
source: Conversation with Mobiz, 2026-04-16 GMT+7, brew-ops-oracle session
project: github.com/kokarat/mobiz-payment-gateway
---

# Reorg (2026-04-16, GMT+7) — Moved tester workflows from flat `.agent/workflows/`

Reorg (2026-04-16, GMT+7) — Moved tester workflows from flat `.agent/workflows/` into `.agent/skills/tester/references/workflow-N-<slug>.md` to match the `technical-writer` convention.

## What changed
- `.agent/workflows/validate-integration-tests.md` → `.agent/skills/tester/references/workflow-1-validate-integration-tests.md`
- `.agent/workflows/add-new-test-case.md` → `.agent/skills/tester/references/workflow-2-add-new-test-case.md`
- `.agent/workflows/mock-bank-sync-check.md` → `.agent/skills/tester/references/workflow-3-mock-bank-sync-check.md`
- H1 of each file now reads `# Workflow N — <title>` for quick numeric recognition.
- Placeholder reserved for `workflow-4-smoke-subset.md` (not yet written).
- `skills/tester/SKILL.md` § "Workflows" table now points at `references/…` paths.
- `skills/tester/SKILL.md` § "First session" step 2 path updated to `references/workflow-1-…`.
- `.agent/AGENTS.md` §11 directory listing reflects the new structure and notes the technical-writer parallel.
- `.agent/workflows/` now only contains non-tester flat workflows (`run-integration-tests.md`, `create-test-case.md` — historical).

## Why
Symmetry with `technical-writer/references/workflow-N-*.md`. A skill that owns its workflows inside its own folder is self-contained and easier to copy between repos (same reason technical-writer's SKILL.md is "shared verbatim"). Flat `.agent/workflows/` stays for genuinely cross-skill or legacy workflows.

## Non-goals of this reorg
- Did not touch content of workflows beyond the H1 renaming.
- Did not rewrite cross-references — they already used "workflow N" notation rather than file paths.
- Did not remove or rename the two remaining files in `.agent/workflows/` (`run-integration-tests.md`, `create-test-case.md`) — those are not tester's to touch.

## Files touched
- skills/tester/SKILL.md (workflows table + first-session path)
- skills/tester/references/workflow-{1,2,3}-*.md (moved; H1 updated)
- AGENTS.md (§11 directory listing)

---
*Added via Oracle Learn*
