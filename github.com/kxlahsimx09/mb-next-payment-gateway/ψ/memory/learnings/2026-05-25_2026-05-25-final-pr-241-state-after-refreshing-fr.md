---
title: 2026-05-25 final PR #241 state after refreshing from latest origin/main ADR-9: o
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirements, epic-deposit, adr-9, preconfigured-callback-endpoint, deposit-007, deposit-008, deposit-002, deposit-006, deposit-011, terminal-taxonomy, fraud-block, callback-boundary, deferred-surface, docs-hygiene, workflow-2]
created: 2026-05-25
source: PR #241 / merge-refresh commit 3f6ab46 / next-product-writer cleanup
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# 2026-05-25 final PR #241 state after refreshing from latest origin/main ADR-9: o

2026-05-25 final PR #241 state after refreshing from latest origin/main ADR-9: origin/main changed callback semantics from client-supplied callback_url to preconfigured per-client/per-flow callback endpoints. The deposit cleanup branch merged origin/main and adjusted DEPOSIT-002/003/004 wording to use snapshotted preconfigured deposit callback endpoint, and updated the DEPOSIT-002 boundary note to include ADR-9 endpoint snapshots and dispatch-time endpoint re-checks. The original cleanup still holds: approve-time slip-fraud BLOCK is non-terminal unless a separate rejection is chosen; DEPOSIT-007/008 align to V2 -> V13 -> V14 -> V3 -> V1.5 -> V1; stale slip-fraud design source is qualified as legacy V1/V2 baseline; deferred DEPOSIT-006/011 are visible without Phase-1 scope. Verification after merge: git diff checks, mermaid parser, conflict-marker scan, active-marker scan, docs-site npm run build.

---
*Added via Oracle Learn*
