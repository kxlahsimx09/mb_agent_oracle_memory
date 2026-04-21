---
title: Drift — bank-bot maintenance-mode-window reportStatus entry lacks .catch wrapper
tags: [technical-writer, repo:bank-bot, current, drift, flow:bot-maintenance-mode-window, maintenance, reportStatus, error-handling, deferred-fix]
created: 2026-04-21
source: app.js:1999@a35dbf9 + docs/flows/bot-maintenance-mode-window.md@a35dbf9 + Oracle thread 35
project: github.com/kokarat/bank-bot
---

# Drift — bank-bot maintenance-mode-window reportStatus entry lacks .catch wrapper

Drift — bank-bot maintenance-mode-window reportStatus entry lacks .catch wrapper. The entry-side api.reportStatus('maintenance', role) at app.js:1999 is the only maintenance-entry report in the codebase without a .catch(() => {}) swallow. Sibling reportStatus call sites (:376, :1070, :1115, :1132, :2119) all swallow HTTP errors; this one alone lets an exception propagate into the pollLoop outer catch. Consequence: on gateway transient outage during window-entry, the bot logs a generic error and never successfully posts status=maintenance — the gateway row stays on the previous value (typically 'online') until the window exits and the normal 'online' report fires (and itself also has .catch, so would silently miss too if the gateway were still down). The dispatcher may assign queue items to a bank whose browser is torn down. Verdict from Oracle thread 35 Q3 (2026-04-21): ACKNOWLEDGE as drift, DEFER fix — no W4 queue now. Depends on mobiz-payment-gateway having a stale-bank-status heuristic that would absorb a missed report (unverified at time of filing). If the fix lands later, option (a) add .catch wrapper is the minimum; option (b) .catch + inline retry is safer if mobiz lacks stale detection; option (c) reportStatusWithRetry wrapper used by all callers is the cleanest but touches many files. Flow doc: docs/flows/bot-maintenance-mode-window.md §Error paths DRIFT-maintenance-report-no-retry. W8 trace: a0cb05b1-b369-4dad-b696-529484c3efca.

---
*Added via Oracle Learn*
