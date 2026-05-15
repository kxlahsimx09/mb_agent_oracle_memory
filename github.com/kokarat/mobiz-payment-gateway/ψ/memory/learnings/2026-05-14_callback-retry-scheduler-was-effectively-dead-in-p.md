---
title: Callback retry scheduler was effectively dead in production because the date-win
tags: [technical-writer, repo:mobiz-payment-gateway, current, callback, scheduler, bson-tag-drift, test-gap, regression-candidate]
created: 2026-05-14
source: services/callbackService.go:601-621@f16d602, models/deposit.go, models/payout.go
project: github.com/kokarat/mobiz-payment-gateway
---

# Callback retry scheduler was effectively dead in production because the date-win

Callback retry scheduler was effectively dead in production because the date-window filter anchored on snake_case `created_at` (`d2a2738` #349) while `models.Deposit` and `models.Payout` BSON struct tags persist the field as camelCase `createdAt`. Fix in `f16d602` #437 (2026-05-14) reads either key: `{$and: [{$or: [{createdAt: {$gte: cutoff}}, {created_at: {$gte: cutoff}}]}, {$or: cooldownClauses}]}`. The unit tests passed because they seeded snake_case fixtures; production matched zero rows. The lesson — write a model-level integration assertion any time a scheduler filter references a timestamp field whose BSON key is renamed (camelCase vs snake_case is the most common variant on this codebase: the model carries `createdAt` even though all the human-readable docs and SQL queries say `created_at`).

---
*Added via Oracle Learn*
