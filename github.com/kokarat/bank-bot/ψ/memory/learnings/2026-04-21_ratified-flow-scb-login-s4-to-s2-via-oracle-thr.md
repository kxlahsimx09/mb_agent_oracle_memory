---
title: ratified — flow scb-login (S4 to S2 via Oracle thread #33, all five judgement ca
tags: [technical-writer, repo:bank-bot, current, flow, flow:scb-login, scb, login, ratified, s2, thread-33, revision, mermaid-render-fix]
created: 2026-04-21
source: Oracle thread #33 closed 2026-04-21 GMT+7 + commit 522d2ad on docs/flow-scb-login
project: github.com/kokarat/bank-bot
---

# ratified — flow scb-login (S4 to S2 via Oracle thread #33, all five judgement ca

ratified — flow scb-login (S4 to S2 via Oracle thread #33, all five judgement calls KEEP). Bot-side W8 flow doc docs/flows/scb-login.md confirmed by human (mobiztool@gmail.com) at 2026-04-21 GMT+7. Q1 extraction precedent from ktb-login-with-otp KEEP; Q2 linear mermaid variant KEEP (single-shot request-response path); Q3 scope stops at saveStorage and excludes balance scrape and reportStatus('online') KEEP; Q4 dismissPopups compressed to a single bracketing step in the diagram with eleven-class detail in §Implementation pointers KEEP; Q5 asymmetry framing in §Purpose (SCB has no login-time OTP, only at approver-time) KEEP. Both drift items stay as doc notes only — no W4 queue: [DRIFT-scb-login-ignores-popup-failed] (loginIfNeeded ignores dismissPopups returning 'failed') and [DRIFT-scb-storage-key-convention] (storage key duplicated independently in app.js:254 and banks/scb/login.js:247). Mid-session render fix at commit 522d2ad: GitHub mermaid parser failed to render the original alt/else block + paren-comma payloads like (skip form fill, skip saveStorage); replaced alt/else with two Note over lines and removed all paren-comma constructs. Local mmdc still produces 28 KB SVG. Stage 1 grep extended to also catch \([^)]*, going forward — pattern worth propagating into the W8 spec's pre-push grep at the next workflow-edit pass. Bot-side flow portfolio after this pass: scb-dual-control-withdrawal, deposit-auto-match-from-statement, ktb-single-transfer-withdrawal, ktb-login-with-otp, ktb-keepalive-session-rotation, bot-bootstrap-and-status-reporting, scb-login (7 docs total). W8 root trace: e61db885-eb3e-43b6-ab44-731357ad01e8. PR: https://github.com/kokarat/bank-bot/pull/92.

---
*Added via Oracle Learn*
