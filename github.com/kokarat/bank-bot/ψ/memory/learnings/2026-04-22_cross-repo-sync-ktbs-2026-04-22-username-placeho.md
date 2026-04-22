---
title: cross-repo-sync: KTB's 2026-04-22 username-placeholder rename (ระบุรหัสผู้ใช้งาน
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, cross-repo-sync, ktb, login, selector-drift, mock-bank, w2]
created: 2026-04-22
source: banks/ktb/selectors.js:14@338070b + mobiz integration-tests/mock-bank/public/ktb.html:157
project: github.com/kokarat/bank-bot
---

# cross-repo-sync: KTB's 2026-04-22 username-placeholder rename (ระบุรหัสผู้ใช้งาน

cross-repo-sync: KTB's 2026-04-22 username-placeholder rename (ระบุรหัสผู้ใช้งาน → ระบุชื่อผู้ใช้งาน) on the real KTB portal propagates across bank-bot + mobiz-payment-gateway. bank-bot side fixed in PR #96 / commit c4e0cf7 (banks/ktb/selectors.js:14 + login.js clear-first) — W2 trace ba80615b-2b96-4929-bd43-c743f51e4062. mobiz side still shows stale aria-label in integration-tests/mock-bank/public/ktb.html:157 (old string) — tracked in mobiz learning learning_2026-04-22_drift-mock-bank-ktb-login-username-aria-label-se filed by the tester workflow-3. Cross-repo link could not use arra_trace_link slot (mobiz W2 trace 37f9c272 already had a next-link); captured here in the breadcrumb instead per W2 Step 2c slot-contention guidance. Shared concept: KTB portal UI text contract. Expected ripple: mobiz mock-bank fixture needs its aria-label updated so the mock aligns with the real portal; until then, integration tests exercising the mock keep validating the pre-rename string.

---
*Added via Oracle Learn*
