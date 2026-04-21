---
title: Drift — bank-bot startDualControlLoops unintentional double-report on maintenanc
tags: [technical-writer, repo:bank-bot, current, drift, flow:bot-maintenance-mode-window, maintenance, reportStatus, dual-control, deferred-fix]
created: 2026-04-21
source: app.js:373-378@a35dbf9 + app.js:1983-2003@a35dbf9 + docs/flows/bot-maintenance-mode-window.md@a35dbf9 + Oracle thread 35
project: github.com/kokarat/bank-bot
---

# Drift — bank-bot startDualControlLoops unintentional double-report on maintenanc

Drift — bank-bot startDualControlLoops unintentional double-report on maintenance entry. When processBatch is invoked with items during an active maintenance window, startDualControlLoops at app.js:373-378 calls resetBrowser() + api.reportStatus('maintenance', 'maker') before returning. Seconds later, pollLoop's own maintenance branch at app.js:1983-2003 runs the canonical logout + reset + report sequence and posts a second identical status=maintenance report for the same role. The gateway's idempotent status update absorbs the duplicate without state change, but the bot's log shows two [Maintenance] sequences ~30s apart. Originally framed as by-design defense-in-depth in the initial flow doc draft — Oracle thread 35 Q5 (2026-04-21) verdict REVISED this to unintentional. The right long-term shape is: only pollLoop owns the maintenance report; startDualControlLoops should return early without calling reportStatus, letting pollLoop run its branch on the next tick after processing=false releases. Fix is deferred — no W4 queue at this time. If the fix lands later, option (b) from thread 35 Q5 is the right direction: remove the reportStatus call from startDualControlLoops pre-entry (keep the resetBrowser call since that prevents stale browser state leaking into the pollLoop's own Step 4 teardown). Flow doc: docs/flows/bot-maintenance-mode-window.md §Error paths MAINTENANCE_STARTDUAL_DOUBLE_REPORT. W8 trace: a0cb05b1-b369-4dad-b696-529484c3efca.

---
*Added via Oracle Learn*
