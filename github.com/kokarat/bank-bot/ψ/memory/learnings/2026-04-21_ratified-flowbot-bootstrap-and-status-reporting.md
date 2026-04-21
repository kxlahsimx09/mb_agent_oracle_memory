---
title: ratified — flow:bot-bootstrap-and-status-reporting. Claim strength S4 → S2 via O
tags: [technical-writer, repo:bank-bot, current, flow, flow:bot-bootstrap-and-status-reporting, bootstrap, bank-status, reportStatus, pollLoop, ratified, s2, thread-30]
created: 2026-04-21
source: W8 ratification via Oracle thread #30 (closed), 2026-04-21 GMT+7 + docs/flows/bot-bootstrap-and-status-reporting.md@post-ratify
project: github.com/kokarat/bank-bot
---

# ratified — flow:bot-bootstrap-and-status-reporting. Claim strength S4 → S2 via O

ratified — flow:bot-bootstrap-and-status-reporting. Claim strength S4 → S2 via Oracle thread #30 closed 2026-04-21 GMT+7. Human ratified all five judgement calls as KEEP: (Q1 scope) bootstrap + heartbeat state machine combined in one flow under slug bot-bootstrap-and-status-reporting — not split into bot-bootstrap-only + bot-status-state-machine. (Q2 SSE drift framing) Option A — include SSE_VESTIGIAL_DRIFT in §Error paths of the flow doc AND file the paired #drift learning; not option B (remove from doc + learning-only). (Q3 mermaid variant) loop-wrapped per §Design notes — init phase linear + loop pollLoop every POLL_INTERVAL while running container around steady-state steps 7-8 + shutdown outside the loop. (Q4 viewer-loop) retained as numbered Step 6a with alt hasViewerCreds-and-isDualControl block; not demoted to §Postconditions-only mention. (Q5 // ext pointer specificity) file-level reference sufficient for mobiz-owned handlers (controllers/BotConfigController.go getBotConfig + controllers/BankStatusController.go report); no line ranges required. `[RATIFICATION_PENDING:30]` stripped from doc header → `// ratified-via-thread:30`. Supersedes learning_2026-04-21_recovery-re-file-after-project-field-typo-flow. PR #89 (bank-bot). W8 root trace 3a87af12-47a1-4761-b408-f837e5c7f4f4 (foundFiles corrupted by MCP XML typo at Step 2b — noted in retro but does not block ratification).

---
*Added via Oracle Learn*
