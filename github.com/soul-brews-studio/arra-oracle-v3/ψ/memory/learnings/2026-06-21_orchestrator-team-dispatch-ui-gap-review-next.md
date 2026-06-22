---
title: orchestrator team-dispatch — "UI gap review #next-vs-#current" 2b-fanout(solo) a
tags: [orchestrator, team-dispatch, 2b, accepted, ui-gap-review, next-ui, #next, #current, #repo:cross, #decision]
created: 2026-06-21
source: campaign o-ui-gap (orchestrator session, 2026-06-21)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator team-dispatch — "UI gap review #next-vs-#current" 2b-fanout(solo) a

orchestrator team-dispatch — "UI gap review #next-vs-#current" 2b-fanout(solo) auto-dispatch accepted. Campaign o-ui-gap: dispatched ONE next-ui teammate (role-matched, owner of mb-next-admin-portal UI) to compare every page of OUR next-gen admin portal (kxlahsimx09/mb-next-admin-portal) vs CURRENT prod admin-ui (kokarat/clone_maxpay_frontend). Report (next-ui_o-ui-gap_findings.md, committed branch campaign/o-ui-gap; merged to ψ/memory/mailbox/next-ui/) covered 4 gap classes: missing pages, extra pages, per-page button/element gaps, non-functional buttons w/ file:line. Headline: 2 real missing pages (/terms-conditions compliance subsystem; /pull-out-tasks PullOutManager), 4 net-new EXTRA pages (bankbot-logs, callbacks, bank-statements, pools), 16 dead/mock controls (4 inert Export buttons + 4 fully-mock pages: settings, setting/telegram, bot-telegram, direct-transfer), many write-features intentionally read-only re-platformed. Pattern: a bounded read-only page-vs-page comparison is well-served by one domain-owner teammate (opus) writing a structured findings file; orchestrator only relays the design/scope decisions (read-only re-platform end-state? mock pages back-or-hide? terms-conditions rebuild/defer/drop?) to the user — does not decide them.

---
*Added via Oracle Learn*
