---
title: drift — mock-bank KTB login username aria-label SELECTOR-DRIFT
tags: [tester, repo:mobiz-payment-gateway, current, drift, mock-bank, ktb, bot-contract, flow:workflow-3-mock-bank-sync-check]
created: 2026-04-22
source: integration-tests/mock-bank/public/ktb.html:157 + bank-bot/banks/ktb/selectors.js:14@c4e0cf7 + bank-bot/banks/ktb/login.js:443
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — mock-bank KTB login username aria-label SELECTOR-DRIFT

drift — mock-bank KTB login username aria-label SELECTOR-DRIFT

Drift class: SELECTOR-DRIFT.

Consumer: bank-bot/banks/ktb/login.js:443 reads LOGIN.USERNAME from bank-bot/banks/ktb/selectors.js:14.

Expectation: page.getByRole('textbox', { name: 'ระบุชื่อผู้ใช้งาน' }) — the post-rename accessible name.

Reality in mock: integration-tests/mock-bank/public/ktb.html:157 was rendering aria-label="ระบุรหัสผู้ใช้งาน" (the pre-rename label). No <label for=> association, so Playwright's accessible-name resolution falls through to the stale aria-label.

Root cause commit: bank-bot c4e0cf7 (2026-04-22 08:48 +07, "fix(ktb): KTB renamed username placeholder — fix selector + clear fields before type"). The bot side tracked a real KTB placeholder rename; mock-bank ktb.html was last touched 2026-04-21 19:16 (0fb1c2e, path routing) and was not synced the same day.

Remediation (applied in mobiz-payment-gateway PR #278, 2026-04-22): one-line edit to integration-tests/mock-bank/public/ktb.html — aria-label="ระบุรหัสผู้ใช้งาน" → "ระบุชื่อผู้ใช้งาน". Visible <label> text on line 156 left untouched since Playwright's accessible-name resolution uses the aria-label here. Minimal diff.

Blast radius: every KTB integration test with a cold login was silently flaking — test-deposit-ktb.sh, test-deposit-burst-ktb.sh, test-mixed-burst-ktb.sh, test-mixed-flow.sh, test-payout-ktb.sh, test-payout-ktb-post-otp-waiting-to-review.sh. Failure mode: getByRole never resolved the new label, username stayed empty, login submit hit a generic "invalid credentials" popup, result read as flake not drift. Exactly the silent-failure class this workflow was designed to catch.

Baseline: docs/mock-bank-contract.md created in mobiz-payment-gateway PR #277 (tester workflow-3-mock-bank-sync-check, 2026-04-22). KTB-001 is the first row under "Known drift"; on merge of #278 it moves to "Historical drift" per P-001.

---
*Added via Oracle Learn*
