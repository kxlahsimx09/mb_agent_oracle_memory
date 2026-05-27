---
title: W2 amend 2026-05-25: docs/.baseline advanced 02ea1f6 → c551524 on PR #478, exten
tags: [technical-writer, repo:mobiz-payment-gateway, current, track-commit, baseline-advance, out-of-territory, k8s, no-op-increment]
created: 2026-05-24
source: docs/.baseline@c551524, k8s/envs/ampay/secrets.yaml@c551524
project: github.com/kokarat/mobiz-payment-gateway
---

# W2 amend 2026-05-25: docs/.baseline advanced 02ea1f6 → c551524 on PR #478, exten

W2 amend 2026-05-25: docs/.baseline advanced 02ea1f6 → c551524 on PR #478, extending the open W2 PR rather than stacking a new one (Step 8.0 detected #478 open → 8.A path). The only commit beyond PR #478's prior frontier (02ea1f6) is #481 / c551524 "k8s: add mongodb-public-read-uri to all brand secrets" — 3 files (k8s/envs/{ampay,goodpay,youpay}/secrets.yaml), 9 insertions, zero production-surface. This is OUT OF TERRITORY for pg-writer: k8s/envs/* is devops_engineer territory and is not in the W2 Territory map (controllers/routes/models/middlewares/scheduler/services/helpers/bank-bot/swagger/db). The mongodb-public-read-uri secret feeds the read-replica connection consumed by db.GetReadCollection, but no code/doc surface changed at c551524, so no current-system.md update was needed. All four in-territory features in d181f34..02ea1f6 (client-request-logs admin read API, GetAllTopups server-side filters, GetAllPayouts account_number prefix filter, transactionMatcher pending_review alreadyLinked guard) were already documented and learned by PR #478 — re-verified accurate at HEAD c551524 since their code is unchanged since 02ea1f6. No deferrals; no new in-territory durable fact this increment. Independently corroborated by pg-tester W1 trace 9df3975c (same c551524 = zero production/test surface).

---
*Added via Oracle Learn*
