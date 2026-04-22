---
title: drift — statement-push-cursor-get-silent-swallow (W4 queue item, priority: low)
tags: [technical-writer, repo:bank-bot, drift, followup, w4-queue, flow:statement-push-error-handling-and-retry, priority:low, observability-gap]
created: 2026-04-22
source: Oracle Learn
project: github.com/kokarat/bank-bot
---

# drift — statement-push-cursor-get-silent-swallow (W4 queue item, priority: low)

drift — statement-push-cursor-get-silent-swallow (W4 queue item, priority: low)

**Flow doc reference:** `docs/flows/statement-push-error-handling-and-retry.md@6efc727` §Error paths entry `CURSOR_GET_FAIL` (marked `[INTENTIONAL?]` pending ratification → ratified as `[DRIFT]` via thread #38 on 2026-04-22).

**Thread verdict anchor:** thread #38 (closed 2026-04-22) Q1 — human picked option 2 (add warn log, behavior unchanged). Do NOT pick option 3 (split catch by error type) without reopening the thread — that option was explicitly deferred.

**Root cause.** `scrapeStatementSafe` at `app.js:696-701@6efc727` and `scrapeStatementSafeForTransfer` at `app.js:1893-1898@6efc727` wrap the `api.getLastStatementDate(config.account_number)` call in a try/catch with an empty `{}` body. Every failure mode (network down, gateway 500, 404, 4xx auth, 30s AbortSignal timeout) is silently absorbed and the code falls through with `lastInDateBKK = 0, lastOutDateBKK = 0` — which triggers full-refresh scrape mode on the NEXT line. The dedup contract on the gateway side absorbs the fatter payload so no correctness is lost, but operators debugging "why did bot 4102508550 just re-push 200 rows?" have zero signal from bot logs.

**Why it's harmless TODAY.** Gateway-side dedup key `(account_number, transaction_date_bkk, amount, transaction_code)` + `balance_after` (KTB) / `description` (SCB) absorbs the re-delivery deterministically. Server returns 200 with `inserted=0, skipped=200` on the re-push. No wallet corruption, no duplicate matching. See mobiz breadcrumb `learning_2026-04-19_flow-cross-repo-breadcrumb-deposit-auto-match-fr` for the dedup contract.

**Why it's a drift.** Silent-swallow cannot distinguish three operationally-different states: (a) gateway transient hiccup (will self-heal next tick), (b) account not yet known to gateway (first-ever scrape for this bank account — legitimate full-refresh), (c) persistent 5xx / auth failure (will NOT self-heal, needs operator intervention). Bot logs look identical in all three cases — not even a warn line distinguishes them. Ops has no way to tell a benign hiccup from a genuine stall without cross-checking the gateway side.

**Fix plan.** Replace `catch {}` with `catch (e) { log.warn(\`[${label}] cursor GET failed, defaulting to 0 (full refresh)\`, { error: e?.message, status: e?.status }) }` at both sites. Keeps EVERY other behavior identical — same default to 0, same full-refresh fallback, same absorption by server dedup. Only change is one warn line per failed tick. Includes `e?.status` so 404 vs 500 vs AbortError are visibly different in log output.

**Scope.** Exactly 2 sites in `app.js`:
- Line 696-701 (`scrapeStatementSafe` — dual-control path, SCB).
- Line 1893-1898 (`scrapeStatementSafeForTransfer` — single-transfer path, KTB).

No other files touched. No new module-level state. No new constant. No caller-side signature change.

**Estimated LOC.** ~8 lines added (4 per site — converting `catch {}` to `catch (e) { log.warn(...) }`), 0 removed.

**Priority: low.** Observability-only, no correctness impact at current load. Appropriate for a "first PR when onboarding a new contributor" or a 5-minute cleanup pass. Bundling with Q2 + Q4 fixes (see sibling drifts tagged `w4-queue + flow:statement-push-error-handling-and-retry`) is reasonable but not required — Q1 can ship standalone.

**Testing.** Cannot unit-test (no unit test infrastructure at `f8bcdf5`). Manual verification: temporarily break `API_URL` env var to a non-routable host, run bot, observe the new warn line in logs. Revert env var.

**Related.** Sibling drifts in the same flow — both also flagged for W4:
- `drift-statement-push-4xx-no-circuit-breaker` (Q2)
- `drift-statement-push-auth-failure-silent-stall` (Q4)

All three share the theme "add observability + circuit-breakers to silent-swallow error paths around statement push". Can be bundled into a single W4 PR or picked off independently.

---
*Added via Oracle Learn*
