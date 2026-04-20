---
title: ---
tags: [technical-writer, repo:bank-bot, current, drift, ktb, login, otp, imap-fallback, confirm-sentinel, for-bot-writer]
created: 2026-04-19
source: W8 authoring pass ktb-login-with-otp, 2026-04-19T18:20+07:00 — surfaced during doc authoring from banks/ktb/login.js + app.js inspection
project: github.com/kokarat/bank-bot
---

# ---

---
title: two drifts surfaced by ktb-login-with-otp W8 pass (imap-fallback missing, confirm-sentinel missing)
tags: [technical-writer, repo:bank-bot, current, drift, ktb, login, otp, imap-fallback, confirm-sentinel, for-bot-writer]
created: 2026-04-19
source: banks/ktb/login.js@1cf5e14 + app.js:1548-1563@1cf5e14 + banks/ktb/transfer.js:842-843@1cf5e14; surfaced during W8 authoring of docs/flows/ktb-login-with-otp.md
project: github.com/kokarat/bank-bot
---

# two drifts surfaced by ktb-login-with-otp W8 pass (imap-fallback missing, confirm-sentinel missing)

## Drift 1 — `DRIFT-login-imap-fallback`

**Claim:** Login-time OTP has no IMAP final-fallback path; transfer-time OTP does.

**Evidence at 1cf5e14:**
- Transfer-time `getOTP` closure at `app.js:1548-1563` tries API 3x then falls back to `getOtpFromEmail` (IMAP direct).
- Login-time `fillOTP` at `banks/ktb/login.js:207-316` calls `getOtpFromAPI` directly — no closure, no IMAP fallback.
- If gateway OTP relay is down during a bot restart that triggers login-OTP: `fillOTP` throws `OTP not received`, `loginIfNeeded` bubbles up, `ensureLoggedIn` returns false, bot cannot log in even if the SIM + IMAP inbox are both healthy.

**Severity:** Latent. No production incident tied to this yet — OTP relay uptime has been high enough that the difference has never mattered. If relay goes down during a multi-bot restart, every KTB account that triggers login-OTP fails simultaneously.

**Fix direction:** Either pass the `getOTP` closure from `app.js:1548-1563` into `loginIfNeeded` the same way it's passed into `batchTransferFlow`, or duplicate the IMAP fallback logic inside `banks/ktb/login.js::fillOTP`. Former is cleaner but requires threading the closure through `KTBModule.login` → `loginIfNeeded` → `fillOTP` signatures.

**How to apply:** When bot-writer lands the fix, close this learning's `#drift` status and update the `[DRIFT-login-imap-fallback]` anchor in `docs/flows/ktb-login-with-otp.md §Error paths` to a resolution note. No `[AWAITING_THREAD]` marker on this one because no separate thread was opened — authoring-pass learning only.

## Drift 2 — `DRIFT-login-otp-confirm-sentinel`

**Claim:** Login-OTP confirm click has no `KTB_POST_OTP`-equivalent sentinel; transfer-OTP does.

**Evidence at 1cf5e14:**
- Transfer-OTP confirm at `banks/ktb/transfer.js:839-844` wraps the confirm click in try/catch; on error, throws `err.code = 'KTB_POST_OTP'`. Downstream `batchTransferFlow:158-159` translates this into `status: 'waiting_to_review'` for still-pending items.
- Login-OTP confirm at `banks/ktb/login.js:330-333` is bare: `await page.getByRole('button', { name: LOGIN.OTP_CONFIRM_BTN }).click()`. No try/catch, no sentinel.

**Severity:** Latent. If the OTP confirm button click fails after OTP digits have been filled into KTB's form, the bank may or may not have processed the login. There is no bot-side state that captures this uncertainty — `loginIfNeeded` just throws a generic click error, `ensureLoggedIn` returns false, bot retries. On retry the stored OTP may or may not still be valid (3-min TTL), the fresh login attempt may request a *new* OTP, and the user sees two OTP SMS (or emails) arriving minutes apart for what was effectively one login attempt.

**Severity amplifier:** Login is called from `processSingleTransfer:1519` at the start of every batch processing iteration *after* a session loss. If `consecutiveLoginFailures` hits 3 (`app.js:1532-1536`), `resetBrowser` runs and the whole process re-initialises — which is the right thing but consumes OTPs along the way.

**Fix direction:** Parallel the transfer-OTP handling: wrap the confirm click in try/catch, emit a tagged error like `KTB_LOGIN_POST_OTP`, caller interprets as "login may have succeeded, retry read-only checks (checkSession + ensureLoggedIn) before giving up."

**How to apply:** Same as Drift 1 — authoring-pass learning only, no separate thread. Fix-and-close updates the `[DRIFT-login-otp-confirm-sentinel]` anchor in the flow doc.

## Combined note
Both drifts are about the same meta-problem: **login-time OTP handling diverged from transfer-time OTP handling over the code's evolution** (transfer-OTP hardened after 2026-04-11 incidents, login-OTP wasn't). A single "harmonise login-OTP with transfer-OTP" PR could address both — filed here as two bullets rather than one so the code search surfaces them independently.

---
*Added via Oracle Learn*


---
*Added via Oracle Learn*
