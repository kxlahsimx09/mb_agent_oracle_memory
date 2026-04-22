---
title: drift — statement-push-4xx-no-circuit-breaker (W4 queue item, priority: medium)
tags: [technical-writer, repo:bank-bot, drift, followup, w4-queue, flow:statement-push-error-handling-and-retry, priority:medium, circuit-breaker-gap, schema-drift-risk]
created: 2026-04-22
source: Oracle Learn
project: github.com/kokarat/bank-bot
---

# drift — statement-push-4xx-no-circuit-breaker (W4 queue item, priority: medium)

drift — statement-push-4xx-no-circuit-breaker (W4 queue item, priority: medium)

**Flow doc reference:** `docs/flows/statement-push-error-handling-and-retry.md@6efc727` §Error paths entry `POST_4xx` (flagged `[DRIFT]` from first pass, ratified via thread #38 Q2 on 2026-04-22).

**Thread verdict anchor:** thread #38 (closed 2026-04-22) Q2 — human picked option (b) cross-tick counter + `reportStatus('error')` after N failures. Do NOT pick option (a) per-4xx immediate report (too noisy — a single transient 4xx could be a gateway hiccup). Do NOT pick option (c) ops-alerting-from-log-patterns (accepts silent stall as OK, we rejected that).

**Root cause.** `POST /api/v1/bot/bank-statements` calls at `app.js:706-711@6efc727` (`scrapeStatementSafe`) and `app.js:1902-1908@6efc727` (`scrapeStatementSafeForTransfer`) are wrapped in the SAME outer catch that handles scrape errors. A 4xx response (schema mismatch between bot payload and gateway endpoint — e.g. gateway added a new required field the bot hasn't emitted, or a field got renamed) produces a single `log.warn` line per tick and nothing else. No cross-tick memory, no threshold, no reportStatus escalation. Cursor-reload recovery (which works for 5xx/timeout because they self-heal) does NOT work for 4xx because schema drift does not heal by waiting — every re-delivery fails the same way.

**Why it's harmless MOST OF THE TIME.** 4xx is rare. Normal operation sees 200 + `{inserted, skipped}` every tick. A transient 4xx (e.g. malformed single-row from a partial scrape) heals on the next tick once that row successfully parses.

**Why it's a drift.** Persistent 4xx (schema drift between bot + gateway deploys — e.g. gateway upgraded, bot hasn't) stalls deposit matching 100% with ZERO alerting signal. Operator-visible symptom is NOT "bot crashed" (bot is still polling + logging happily), it's "deposits stop matching on one bank account". That symptom typically surfaces only when a client escalates a missing deposit, which can be hours later. Meanwhile the bot's log file has hundreds of `Statement scrape failed (non-fatal): HTTP 400` lines — but nothing upstream of ops tooling reads them.

**Fix plan.** Add cross-tick counter + threshold + escalation:

1. Add module-level state at `app.js:217-231` (the "Browser management" counters block):
   ```
   let consecutiveStatementPushFailures = 0;
   const MAX_STATEMENT_PUSH_FAILURES_BEFORE_ALERT = 5;
   ```
2. Wrap the `api.saveBankStatements(...)` call in its OWN try/catch inside both `scrapeStatementSafe` and `scrapeStatementSafeForTransfer`:
   - On success (200) → reset `consecutiveStatementPushFailures = 0`, keep existing log line + conditional `updateBalance` call.
   - On failure → increment counter, log warn with `error.message + error.status`, at threshold call `api.reportStatus(config.account_number, config.bank_code, 'error', \`Statement POST repeatedly failing (${consecutiveStatementPushFailures}x) — schema drift or gateway down\`, label.toLowerCase()).catch(() => {})`. Do NOT re-throw — let the function return cleanly (no re-throw = no duplicate log from outer catch).
3. `KTB_SESSION_DEAD` still needs to bubble to outer catch for `resetBrowser()` — put the `if (pushErr?.code === 'KTB_SESSION_DEAD') throw pushErr;` guard inside the new inner catch so KTB recovery behavior is unchanged.
4. Threshold value `MAX_STATEMENT_PUSH_FAILURES_BEFORE_ALERT = 5` matches the `MAX_NAV_FAILURES_BEFORE_RECYCLE = 5` precedent in the same file; 5 × 30s = 2.5 min smoothing window before alerting.

**Scope.** 2 sites in `app.js`:
- `scrapeStatementSafe` at lines 706-716 (the `saveBankStatements` + conditional `updateBalance` block).
- `scrapeStatementSafeForTransfer` at lines 1902-1913 (same structure).
Plus the counter + constant at the module-scope counters block (1 addition each).

**Estimated LOC.** ~20 lines added, ~4 lines modified (the existing outer try/catch structure needs no change — the new inner try/catch is additive).

**Priority: medium.** Schema drift between bot + gateway deploys is not hypothetical — it has happened historically (see `current-system.md` §8 DRIFT-8 for undocumented endpoint changes). A 2.5 min alerting window bounds the "silent stall" risk; without this fix the window is unbounded.

**Testing.** Can stage-test by making gateway temporarily return 400 on `POST /api/v1/bot/bank-statements` for one bot account, observe (a) the cadence-spam lines, (b) the reportStatus call on the 5th tick. Rollback trivial. Production deploy should be behind a feature flag initially if the ops tooling that reads `reportStatus('error')` has any alerting escalation — otherwise `error` status might trigger page spam.

**Related drifts (share the same W4 bundle opportunity):**
- `drift-statement-push-cursor-get-silent-swallow` (Q1)
- `drift-statement-push-auth-failure-silent-stall` (Q4)

All three share the theme "add observability + circuit-breakers to silent-swallow error paths around statement push". Bundle recommended because the three changes live in adjacent code in the same function; separate PRs would create three-way merge conflicts. Ship them as one PR with three commits.

**Open design decision deferred to implementation time.** Should the counter track ALL non-2xx (including 5xx and timeouts, which ARE recoverable via cursor-reload) or ONLY persistent non-recoverable errors (4xx, 401/403)? Arguments for all-non-2xx: simpler, smoothing also catches "gateway has been down for 2.5 min" which is alert-worthy. Arguments for 4xx-only: avoids false positives from transient outages. Recommended default: ALL non-2xx (covers more cases, threshold of 5 is already tolerant of brief outages). Re-open thread #38 if a narrower scope is preferred at implementation time.

---
*Added via Oracle Learn*
