---
title: SCB login.js now calls dismissLandingBanner(page) immediately after page.goto(BA
tags: [technical-writer, repo:bank-bot, current, scb, login, selector, banner-dismiss, dismissLandingBanner]
created: 2026-04-27
source: banks/scb/login.js:24-41@2fd0681, banks/scb/selectors.js:21@2fd0681
project: github.com/kokarat/bank-bot
---

# SCB login.js now calls dismissLandingBanner(page) immediately after page.goto(BA

SCB login.js now calls dismissLandingBanner(page) immediately after page.goto(BASE_URL), before dismissPopups, to handle a full-screen promotional banner SCB occasionally serves at https://www.scbbusinessanywhere.com/ before the login form is visible. The helper uses getByRole('button', { name: LOGIN.ENTER_SITE_BTN_NAME }) with a 3s visibility check; clicks if present, no-ops if absent. LOGIN.ENTER_SITE_BTN_NAME is a case-insensitive regex matching "Enter Site / เข้าสู่เว็บไซต์" in any order. Added PR #103 (commit 2fd0681) after login was failing to find the username field during SCB campaign windows. Exported from login.js alongside dismissPopups.

---
*Added via Oracle Learn*
