---
title: flow — ktb-keepalive-session-rotation — intent at a glance
tags: [technical-writer, repo:bank-bot, current, flow, flow:ktb-keepalive-session-rotation, ktb, keepalive, session, angular-router, idle-loop, reverse-engineered, ratification-pending, s4, bot-first, thread-32]
created: 2026-04-21
source: W8 flow-map authoring pass — ktb-keepalive-session-rotation intent learning, 2026-04-21 GMT+7
project: github.com/kokarat/bank-bot
---

# flow — ktb-keepalive-session-rotation — intent at a glance

flow — ktb-keepalive-session-rotation — intent at a glance

Purpose: while the KTB bot is idle between queue claims (or between statement scrapes), it rotates its Playwright session through a real Angular route change — click the account card on the dashboard to navigate into account-detail, then open the sidebar and click แดชบอร์ด back to the dashboard — so that KTB Business Internet Banking's server-side session timer actually resets. Without this rotation, REST-only idle activity (scrapeStatementAPI / getAccountSummaryAPI) and repeated clicks of the already-active dashboard link silently lose the session after ~10-15 minutes: the UI profile-button check still reports "logged in" because the HTML shell is cached, but the next REST call returns 500 and the bot enters a popup-dismiss spiral.

Actors:
- System:BankBot-Idle (transfer role or maker role — same rotation for both)
- External:KTBPortal (Angular SPA owning the router state and server-side session timer)

No gateway actor, no OTP actor, no queue-row changes. Keepalive is entirely bot-internal.

Sequence (7 actor-crossing messages + 1 retry loop + 2 alt branches):
1. locate `.card-account-container` isVisible 3s
  - 1a. card not visible → log warn, skip rotation this tick, return (timer NOT reset — best-effort, next tick retries)
  - 1b. card visible → proceed
2. click account card + humanDelay(1500, 2500) → first real route change, timer reset 1
3. retry loop up to 3 attempts:
  3a. mouse move (30, 85) + click sidebar + humanDelay
  3b. locate แดชบอร์ด link isVisible 3s
  3c. link visible → click + humanDelay(1500, 2500) → verify card isVisible 3s afterwards (catches clicks that land on wrong route) → break on success
  3d. link not visible → warn, next retry re-opens sidebar
4. terminal:
  4a. returned to dashboard within 3 attempts → log info route-change-2 success, done (timer reset 2)
  4b. all 3 attempts failed → clearCachedHeaders + clearStorage('ktb-transfer') + throw KTB_SESSION_DEAD (caller at app.js:1838 or :2131 runs resetBrowser)

Invariants + incident history (why this flow exists):
- KTB Angular router resets session timer ONLY on real URL-hash changes. REST calls in the background never reset it.
- Clicking the already-active dashboard link is a Router no-op (Angular dedupes) — not a timer reset.
- Production bot 0170681475 stalled for 24 hours on 2026-04-11 because of the REST-only-idle failure mode → this rotation was added.
- Production bots 0170679675 / 0170689786 on 2026-04-13 got wedged on the account-detail page after an earlier keepalive returned without confirming the dashboard card was visible → the 3-attempt retry + post-click card verification was added in response.

Scope boundary (explicit in the flow doc §Scope):
- IN: public `KTBModule.keepSessionAlive` + its two idle-branch callers at `app.js:1826-1846` + `app.js:2120-2145`.
- OUT: private `_keepSessionAlive` (single-click bump inside scrapeStatement — no retry, no sentinel); `isSessionLikelyDead` REST-probe session-health detector; `checkApiHealth` pre-claim probe. Each owned by a different sibling flow.

Cross-repo framing: bot-first, no mobiz sibling anticipated — keepalive never crosses into mobiz. Breadcrumb tagged `#cross-repo-sync-bot-first`. The only indirect mobiz-visible effect is that a thrown `KTB_SESSION_DEAD` causes a `resetBrowser` → the subsequent pollLoop tick reports `status=offline` per `bot-bootstrap-and-status-reporting.md §Step 8c`.

Claim strength S4 (reverse-engineered from `banks/ktb/index.js:232-312` + `app.js:1826-1846 / 2120-2145` + `banks/base.js:138-155` at commit `efd660f`, 2026-04-21). `[RATIFICATION_PENDING:32]` — four judgement calls filed for human confirmation: (Q1) scope boundary confirm; (Q2) `[DRIFT-keepalive-err-code-string-vs-constant]` promote or leave as note; (Q3) mermaid linear-with-retries vs full loop-wrap; (Q4) incident-ID citation style in flow doc body vs code-comments-only.

Tags: technical-writer, repo:bank-bot, current, flow, flow:ktb-keepalive-session-rotation, ktb, keepalive, session, angular-router, idle-loop, reverse-engineered, ratification-pending, s4, bot-first, thread-32

---
*Added via Oracle Learn*
