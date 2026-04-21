---
title: flow — scb-login — bot-side intent at a glance. Extracted from scb-dual-control-
tags: [technical-writer, repo:bank-bot, current, flow, flow:scb-login, scb, login, playwright, reverse-engineered, ratification-pending, s4, bot-first, thread-33]
created: 2026-04-21
source: docs/flows/scb-login.md@pre-commit W8 authoring pass, 2026-04-21 GMT+7
project: github.com/kokarat/bank-bot
---

# flow — scb-login — bot-side intent at a glance. Extracted from scb-dual-control-

flow — scb-login — bot-side intent at a glance. Extracted from scb-dual-control-withdrawal.md §Preconditions into its own W8 doc on the same precedent as ktb-login-with-otp. SCB Business Anywhere requires a two-credential login (username + password) and does not challenge with OTP at login time — SCB reserves OTP for the approver's per-batch transfer confirmation. Flow is invoked once per role per process: maker + approver for every dual-control deployment (SCB enforces that the submitter cannot also approve, so distinct credentials are required), plus optionally viewer when config.credentials.viewer is populated. All three passes share one loginIfNeeded implementation at banks/scb/login.js:246-321; the only per-role difference is the credentials object and the storage key (scb-maker, scb-approver, scb-viewer at /data/storage-scb-{role}.json). Diagram is the linear variant (single-shot request-response path, mirrors ktb-login-with-otp's choice per W8 §Design notes loop-vs-linear). Scope stops at saveStorage (Step 14); balance scrape and reportStatus('online') are caller responsibilities documented in scb-dual-control-withdrawal §Postconditions and bot-bootstrap-and-status-reporting. dismissPopups brackets the navigation (pre-goto, post-goto, post-form-fill) because SCB's first paint can render any of eleven popup classes (session-kicked, session-expired, soft_token_form, Transfer-ApproveOwnPopup, promotional banners, MuiSnackbar, MuiDrawer, Transfer-AddNewRecipientPopup, MuiDialog catch-all, MuiBackdrop, generic ตกลง); the helper distinguishes dismissed/none/session_expired/failed but loginIfNeeded currently ignores the 'failed' return — filed as [DRIFT-scb-login-ignores-popup-failed]. Cross-repo state is bot-first (same as ktb-login-with-otp) — mobiz never authenticates against a bank portal. Reciprocal breadcrumb tagged #cross-repo-sync-bot-first. W8 root trace e61db885-eb3e-43b6-ab44-731357ad01e8. [RATIFICATION_PENDING:33] — five judgement calls filed: (Q1) sibling-doc extraction precedent from ktb-login-with-otp, (Q2) linear mermaid variant, (Q3) scope stops at saveStorage, (Q4) dismissPopups compressed to a single bracketing step in the diagram, (Q5) asymmetry framing vs KTB in §Purpose.

---
*Added via Oracle Learn*
