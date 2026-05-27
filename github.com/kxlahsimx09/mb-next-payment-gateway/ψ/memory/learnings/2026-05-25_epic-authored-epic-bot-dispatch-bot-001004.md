---
title: # epic authored - epic-bot-dispatch BOT-001..004 - fair-router dispatch contract
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic, epic-bot-dispatch, bot-dispatch, fair-router, withdrawal-lane, claim-rpc, realtime, dispatch-sweep, s2-ratified, workflow-1]
created: 2026-05-25
source: docs/requirements/epic-bot-dispatch.md@7519884
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# # epic authored - epic-bot-dispatch BOT-001..004 - fair-router dispatch contract

# epic authored - epic-bot-dispatch BOT-001..004 - fair-router dispatch contract

W1 authored `docs/requirements/epic-bot-dispatch.md` at commit `7519884` with four S2 stories:

- BOT-001: gateway queues bank-resource work and fair-routes substitutable items to one eligible system bank before any bot wakes.
- BOT-002: insert bursts and bank-free lifecycle events are coalesced into bounded fair-router runs.
- BOT-003: dispatch sweep recovers missed routing and missed bot claims while leaving post-claim ambiguity to ADR-4a review triage.
- BOT-004: the selected bank-bot receives assigned work, performs session health checks, and claims through `claim_withdrawal_items`, where the gateway re-verifies authority.

Sources used: ADR-8, ADR-4a, `docs/design/bot-gateway-dispatch/*`, `docs/design/withdrawal-lane/realtime-filter.md`, `docs/design/withdrawal-lane/claim-rpc.md`, ratified current withdrawal dispatch learning, tier-cap resolution learning, and hosted integration PoC learning.

Cross-repo surface updated: README epic index, `docs/requirements/INDEX.md`, and `docs/requirements/cross-repo.md` now point to BOT-004 for the gateway/bankbot v2 boundary.

Validation passed: placeholder scans, Mermaid parser for 2 diagrams, `git diff --check`, and `docs-site npm run build`.

---
*Added via Oracle Learn*
