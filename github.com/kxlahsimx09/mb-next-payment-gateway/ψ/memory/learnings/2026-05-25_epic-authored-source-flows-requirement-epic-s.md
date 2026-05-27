---
title: # epic authored - Source Flows requirement epic (SETTLE-001 / PULLOUT-001 / DIRE
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic, workflow-1, source-flow, settlement, pullout, direct-transfer, s2-ratified, adr-12, cross-repo]
created: 2026-05-25
source: docs/requirements/epic-source-flows.md@working-tree 2026-05-25 Asia/Bangkok
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# # epic authored - Source Flows requirement epic (SETTLE-001 / PULLOUT-001 / DIRE

# epic authored - Source Flows requirement epic (SETTLE-001 / PULLOUT-001 / DIRECT-001)

On 2026-05-25, next-product-writer ran Workflow-1 authoring for recommendation #1 from the W1 gap analysis and added `docs/requirements/epic-source-flows.md`.

The new epic is one S2 ratified Source Flows epic, grounded primarily in §ADR-12 plus the ratified withdrawal-lane substrate:
- `SETTLE-001`: client/sub-client API or admin UI creates a settlement; client machine path uses `Idempotency-Key`, admin UI is JWT/RBAC and idempotency-exempt; settlement queues substitutable `pending_routing` work and failure releases the settlement wallet hold.
- `PULLOUT-001`: manual admin, scheduler tick, balance-threshold, and demand-refill triggers all call one pullout dispatcher; dispatcher owns dedup and shared guards before creating direct-addressed named-bank work; no client wallet refund on failure.
- `DIRECT-001`: admin direct transfer sync-validates before insert/enqueue; failed validation creates no row, no approved state, and no bot work, closing DTR1776285027RZE1H2-class drift.

Companion updates:
- `docs/requirements/README.md`: Settlement, Pullout, Direct Transfer rows now point to `epic-source-flows.md` anchors with S2 trust.
- `docs/requirements/INDEX.md`: added Source Flows story ids.
- `docs/requirements/glossary.md`: added source flow, settlement, pullout, direct transfer terms.
- `docs/requirements/cross-repo.md`: added bankbot-v2 boundary rows and reading-order entry.

Validation run:
- `wc -l docs/requirements/epic-source-flows.md` => 196 lines.
- Bare-brace MDX trap check over touched requirements files => no hits.
- Placeholder check for `AWAITING_THREAD` / `RATIFICATION_PENDING` => no hits.
- `git diff --check` => clean.
- `node /tmp/mmv/check-mermaid.mjs docs/requirements/epic-source-flows.md` => 3 Mermaid blocks, 0 failures.

---
*Added via Oracle Learn*
