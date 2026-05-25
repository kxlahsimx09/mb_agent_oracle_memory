---
title: epic authored — topup — 4 stories, trust mix S2/S3/S4 = 4/0/0.
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic, client-self-topup, topup, s2-ratified, workflow-1]
created: 2026-05-25
source: docs/requirements/epic-topup.md@a8cdbf0
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# epic authored — topup — 4 stories, trust mix S2/S3/S4 = 4/0/0.

epic authored — topup — 4 stories, trust mix S2/S3/S4 = 4/0/0.

Subsystem: client-self-topup / topup.

Stories authored:
- TOPUP-001 Admin records a B2B client topup with slip evidence after the client transfers money offline.
- TOPUP-002 Admin approves the topup; the gateway atomically credits the client wallet, distributes MDR, writes audit rows, and sends no callback.
- TOPUP-003 Admin rejects a bad topup; no wallet movement happens and the rejection is auditable.
- TOPUP-004 Admin lists and investigates topups by status, client, slip, wallet movement, MDR distribution, and audit trail.

Sources cited: §ADR-16, §ADR-13, §ADR-10, §ADR-3, docs/design/topup/README.md, docs/design/topup/schema.md, mobiz docs/flows/topup-approve-mdr-distribution.md, current Mongo collection `topups`, learning_2026-05-09_w1-ratify-pass-adr-16-client-self-topup-b2b-co, learning_2026-05-25_topup-grounding-update-current-topups-producti, learning_2026-04-18_flow-topup-approve-mdr-distribution-intent-at, learning_2026-04-18_drift-topup-flow-b-asymmetric-partner-handling, learning_2026-05-23_w9-pass-2026-05-24-flow-topup-approve-mdr-distrib.

Open threads: none. Cross-repo: none; gateway-only.

Files: docs/requirements/epic-topup.md, docs/requirements/INDEX.md, docs/requirements/README.md, docs/requirements/glossary.md @ a8cdbf0.

Verification: MDX bare-brace scan clean; no AWAITING_THREAD/RATIFICATION_PENDING anchors; mermaid parser gate PASS for 2 blocks; docs-site `npm run build` PASS (Nextra timestamp warnings only).

---
*Added via Oracle Learn*
