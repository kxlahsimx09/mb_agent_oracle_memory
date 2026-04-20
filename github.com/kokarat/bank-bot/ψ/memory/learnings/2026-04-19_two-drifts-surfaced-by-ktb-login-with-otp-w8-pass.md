---
title: two drifts surfaced by ktb-login-with-otp W8 pass (imap-fallback missing, confir
tags: [technical-writer, repo:bank-bot, current, drift, ktb, login, otp, imap-fallback, sentinel, flow:ktb-login-with-otp, recovered-from-double-wrap]
created: 2026-04-19
source: banks/ktb/login.js@1cf5e14 + app.js:1548-1563@1cf5e14 + banks/ktb/transfer.js:842-843@1cf5e14; surfaced during W8 authoring of docs/flows/ktb-login-with-otp.md — recovered 2026-04-19
project: github.com/kokarat/bank-bot
---

# two drifts surfaced by ktb-login-with-otp W8 pass (imap-fallback missing, confir

two drifts surfaced by ktb-login-with-otp W8 pass (imap-fallback missing, confirm-sentinel missing)

Authoring `docs/flows/ktb-login-with-otp.md` on 2026-04-19 surfaced two drifts between login-time OTP handling and transfer-time OTP handling in the KTB bank flow. Both are asymmetries where the transfer path has defensive logic that the login path lacks; neither is justified in the code or comments.

Drift 1 — imap-fallback missing at login-time OTP. Transfer-time OTP polling at `banks/ktb/transfer.js:842-843@1cf5e14` has a three-phase cascade: SMS (60s) → email (180s) → IMAP scrape (final fallback via `mailers/imap.js`). Login-time OTP polling at `banks/ktb/login.js@1cf5e14` (specific line not captured during this pass — search term: `pollOtpFromSms`) has only SMS + email; IMAP branch is absent. Impact: if KTB's OTP SMS+email both go to spam or fail delivery at login time, there's no final escape hatch; the login simply times out and the queue claim returns `KTB_NEED_RELOGIN` on its next attempt. At transfer time the same delivery failure would be recovered by the IMAP scrape.

Candidate for harmonisation: extract the three-phase OTP polling into a shared helper consumed by both login and transfer. Not urgent (login-time OTP delivery failures are rarer than transfer-time in telemetry), but the divergence is currently hidden.

Drift 2 — KTB_POST_OTP-equivalent sentinel missing at login-OTP confirm click. Transfer path at `app.js:1548-1563@1cf5e14` has explicit sentinel `KTB_POST_OTP` for "OTP confirm click threw", with a paired dispatcher rule emitting `waiting_to_review` (note: DRIFT-16 separately flags that the dispatcher currently collapses this to `failed`, but the sentinel itself exists). Login path has no such sentinel — a failed OTP confirm click at login falls through to whichever downstream handler runs, without the explicit mark-failed-vs-waiting-to-review contract.

Impact: at transfer time a post-OTP click failure is recoverable (agent retries-same-items or marks waiting for human review). At login time the same failure becomes an opaque "login timed out" that the outer queue-claim loop can't distinguish from delivery failure (drift 1), and both paths converge on `KTB_NEED_RELOGIN` + retry. The login-with-OTP flow doc flags both with `[DRIFT-*]` markers in §Error paths.

Context: surfaced during the 2026-04-19 W8 authoring pass on `ktb-login-with-otp.md` (trace `ff47aa94-4c5a-46fa-a33a-1c1b60aa264f`). Not filed as `[AWAITING_THREAD]` because the drift is between two bot-internal code paths, not between bot and an external contract — no human ratification needed to confirm the code reality. Fix is in bot-writer territory; whoever takes the harmonisation task (W4 candidate) should supersede this learning with the patched-state variant on PR land.

RECOVERED 2026-04-19 from double-wrap file `2026-04-19_title-two-drifts-surfaced-by-ktb-login-with-o.md`; supersedes `learning_2026-04-19_title-two-drifts-surfaced-by-ktb-login-with-o`.

---
*Added via Oracle Learn*
