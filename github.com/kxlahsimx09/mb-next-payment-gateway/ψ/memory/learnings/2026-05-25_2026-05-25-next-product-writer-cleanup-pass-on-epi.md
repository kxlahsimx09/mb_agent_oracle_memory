---
title: 2026-05-25 next-product-writer cleanup pass on epic-deposit (PR #241, commit 2d0
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirements, epic-deposit, deposit-007, deposit-008, deposit-002, deposit-006, deposit-011, terminal-taxonomy, fraud-block, callback-boundary, deferred-surface, docs-hygiene, workflow-2]
created: 2026-05-25
source: PR #241 / commit 2d09b9a / next-product-writer cleanup
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# 2026-05-25 next-product-writer cleanup pass on epic-deposit (PR #241, commit 2d0

2026-05-25 next-product-writer cleanup pass on epic-deposit (PR #241, commit 2d09b9a): treat approve-time slip-fraud BLOCK as non-terminal in requirements unless a separate admin/future ratified terminal-producing rule rejects. The cleanup aligned DEPOSIT-007 and DEPOSIT-008 wording to the current six-check cascade V2 -> V13 -> V14 -> V3 -> V1.5 -> V1, qualified docs/design/deposit-lane/slip-fraud-detection.md as legacy V1/V2 baseline only, closed DEPOSIT-002 callback retry/HMAC as an ADR-9 boundary note, and made deferred DEPOSIT-006 / DEPOSIT-011 visible in epic-deposit + INDEX without reintroducing Phase-1 scope. Verification used mermaid parser, git diff --check, active-marker scan excluding historical closed markers, and docs-site npm run build. File remains oversized; cluster split recorded as follow-up housekeeping, not bundled into the drift cleanup.

---
*Added via Oracle Learn*
