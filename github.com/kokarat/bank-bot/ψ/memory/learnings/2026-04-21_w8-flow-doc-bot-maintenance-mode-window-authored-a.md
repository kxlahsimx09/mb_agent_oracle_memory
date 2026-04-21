---
title: W8 flow doc bot-maintenance-mode-window authored at bank-bot HEAD a35dbf9 on 202
tags: [technical-writer, repo:bank-bot, current, flow, flow:bot-maintenance-mode-window, maintenance, poll-loop, viewer-loop, report-status]
created: 2026-04-21
source: docs/flows/bot-maintenance-mode-window.md@a35dbf9
project: github.com/kokarat/bank-bot
---

# W8 flow doc bot-maintenance-mode-window authored at bank-bot HEAD a35dbf9 on 202

W8 flow doc bot-maintenance-mode-window authored at bank-bot HEAD a35dbf9 on 2026-04-21. Reverse-engineered S4 claim, RATIFICATION_PENDING Oracle thread 35. Covers the bot-side choreography when config.maintenance_time is active in Bangkok local time: every long-lived loop (pollLoop, maker/approver/transfer idle, viewer, claim helpers) drains to zero work on detection, pollLoop runs the canonical logout + resetBrowser + clearStorage + reportStatus maintenance sequence for maker/transfer role, viewerLoop runs its own parallel branch for role=viewer, and the exit transition falls through to the existing pre-claim health + ensureLoggedIn path that reports status=online via the normal bootstrap path. Key facts reverse-engineered: isInMaintenanceWindow parses HH:MM[-or endash]HH:MM with Bangkok timezone hardcoded and overnight wraparound supported, the 5-min CONFIG_REFRESH_INTERVAL bounds admin-edit propagation latency, sub-loop releases are defensive (every loop re-checks rather than trusting a global flag) which causes a by-design double-report at startDualControlLoops pre-entry, and the entry-side reportStatus at app.js 1999 lacks the .catch swallow used by every other caller (DRIFT-maintenance-report-no-retry queued for W4 decision via thread 35 Q3). Flow is bot-first: mobiz does not push enter/exit signals, the gateway owns maintenance_time string storage and serves it via GET /bot/config/account but never notifies. Cross-repo boundary is the POST /bank-status/report contract owned by bot-bootstrap-and-status-reporting. W8 trace a0cb05b1-b369-4dad-b696-529484c3efca.

---
*Added via Oracle Learn*
