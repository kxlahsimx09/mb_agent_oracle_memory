---
title: # next-impl (implementation-architect) role activated for mb-next-payment-gatewa
tags: [implementation-architect, next-impl, fleet-activation, poc-evidence-convention, workflow-1, workflow-2, ADR-PoC-pipeline, mb-next-payment-gateway]
created: 2026-05-04
source: orchestrator thread #69 (closed 2026-05-04)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# # next-impl (implementation-architect) role activated for mb-next-payment-gatewa

# next-impl (implementation-architect) role activated for mb-next-payment-gateway

**When**: 2026-05-04 17:11 GMT+7 (orchestrator parent #69 closed; sub #74 ratified the activation execution)
**Where**: `mb-next-payment-gateway` fleet — `next-impl-oracle` window in `.agent/fleet/20-mb-next-payment-gateway.json`
**Owner**: brew-ops fleet inventory now lists 2 workflows for `next-impl`: W1 `poc-from-adr` + W2 `drift-report-to-architect`
**Spawn**: `/new next-impl` (bot `load_roles()` registers it; smoke-tested 5 → 7 roles after `bot.sh` restart)

## Two-workflow shape

**W1 — `poc-from-adr`** (8 steps): Reads an ADR, classifies as behavior-shaped vs structural, authors a PoC under `poc/<adr-id>/`. Steps 2 + 3 require `#current` evidence augmentation citing vault-learnings, integration-tests, and `docs/flows/`. Tests carry a 2-line evidence cite block in the docstring. PoC may emit a side-effect directory `poc/<adr-id>/evidence/` for non-text artifacts. W1-Input-5 derivative discipline applies (input chain provenance preserved). Worked example: §ADR-4b finalize_deposit.

**W2 — `drift-report-to-architect`** (5 steps, code-review shape): Surfaces drift between an ADR and the implementation. Output is a drift report carrying a 3-line `Precedent` field. Outbox triple goes to `for-next-architect/`. Worked-example references: §ADR-4c D4, §ADR-4a D7, §ADR-4b D5.

## Evidence convention (`poc/EVIDENCE-CONVENTION.md`)

- Cite block shape: 2 lines, source-attributed.
- Per-source citation conventions for vault-learnings / integration-tests / docs/flows.
- `[POC_GAP]` marker reserved for the PoC author to flag missing inputs at PoC time (4 day-1 candidates pre-identified).
- Tier-C deferred-decision text inlined: raw Mongo / Playwright archives / Telegram logs are NOT day-1 evidence sources; the PoC author re-evaluates Tier-2/3 needs at PoC authoring time. NOT blocking activation.

## What next-impl does NOT own (hard rules)

- No writing into `pg-tester`'s lane (test ownership).
- Vault-channel breadcrumbs only — no direct vault writes outside the channel.

## Activation mechanics (replicable for future role activations)

- **Central memory** edits land as a single-author commit-to-main on `mb_agent_oracle_memory` per AGENTS.md §3a (single-author exception). Convention dirs (`for-<role>/.gitkeep` + `handled/.gitkeep`) seeded in the same commit.
- **Product-repo edits** (fleet JSON, AGENTS.md routing rows, convention docs) land via branch + PR per §9, fork-targeted per `feedback_fork_prs_not_upstream`.
- **Bot restart** (`brew-ops-bot/bot.sh`) is the activation switch — `load_roles()` reads fleet JSON via `find -L` (follows the symlink into central memory). Graceful SIGTERM → re-exec; `recover_watchers` re-attaches chat-watchers per script line 1212. Restart is shared-state — confirm with user before pulling.
- **Smoke-test**: bot's `load_roles()` log line is the source-of-truth on nodes where `maw` is not on PATH. `jq -r '.windows[].name' …/<fleet>.json` verifies the fleet JSON parsed correctly.
- **Routing rows** required in 3 places: target product repo `AGENTS.md §5`, sibling fleet's `AGENTS.md §5` (cross-fleet), sibling fleet's `AGENTS.md §11a` (routing).

## Refs

- Central: `mb_agent_oracle_memory@7e46786`
- Product PR: kxlahsimx09/mb-next-payment-gateway#14 (branch `impl/poc-evidence-convention-2026-05-04`)
- Threads: orchestrator #69 (parent, closed) / #70 (original mechanics, closed) / #72 (evidence-mining, closed) / #74 (activation execution, closed)

---
*Added via Oracle Learn*
