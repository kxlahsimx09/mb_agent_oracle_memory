---
title: `bank-bot/banks/ktb/transfer.js` `batchTransferFlow` treats Playwright `.click()
tags: [repo:bank-bot, repo:mobiz-payment-gateway, repo:cross, tester, thread:16, ktb, silent-fail, post-otp-verification-gap, sub-drift-candidate]
created: 2026-04-20
source: tester session 2026-04-20 (cross-repo finding)
project: github.com/kokarat/mobiz-payment-gateway
---

# `bank-bot/banks/ktb/transfer.js` `batchTransferFlow` treats Playwright `.click()

`bank-bot/banks/ktb/transfer.js` `batchTransferFlow` treats Playwright `.click()` on the OTP confirm button as the ONLY source of truth for transfer success/failure.

If `.click()` doesn't throw, bot logs `[KTB Transfer] OTP confirmed` and proceeds. Every downstream page interaction — `page.mouse.move`, `page.locator(DASHBOARD.ACCOUNT_CARD).isVisible`, dashboard-card verification loop (5 attempts) — is wrapped in `try/catch` or `.catch(() => false)`. If the page is dead post-OTP, these silently return false, the dashboard loop logs `Dashboard not confirmed 1/5 → 5/5`, takes a screenshot, then the function RETURNS NORMALLY without throwing. app.js then marks all pending items as `success`.

**Consequence for test design:** any mock-bank fixture targeting post-OTP ambiguity MUST make the actual `.click()` throw — cannot rely on bot detecting downstream symptoms like dashboard-not-visible. They are swallowed by design.

**Likely sub-drift of thread #16 (not captured by current thread scope):** KTB single-transfer flow has no post-submit success-page verification (e.g. checking "ส่งเรียบร้อย" element visibility). If the page dies post-OTP but pre-success-page, bot reports success even though gateway/bank state is indeterminate. SCB maker/approver flow handles this via TRANSFER ID scraping match — KTB single-transfer has no equivalent guard.

**Applies to:** bank-bot code review, designing new test fixtures that probe post-OTP states, and any future bot refactor that touches OTP confirm path. Worth flagging to bank-bot-writer if a new thread opens for KTB post-submit verification hardening.

**Empirically demonstrated:** 2026-04-20 while validating fixture v3 — with page destroyed by `document.open()` post-click, bot still marked `batch complete: 1 successful` before we switched to the scheduled-nav trick that forces `.click()` to throw (see learning_2026-04-20_playwright-click-does-not-post-verify-element).

---
*Added via Oracle Learn*
