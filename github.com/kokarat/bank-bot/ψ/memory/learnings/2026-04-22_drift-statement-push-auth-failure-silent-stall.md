---
title: drift — statement-push-auth-failure-silent-stall (W4 queue item, priority: mediu
tags: [technical-writer, repo:bank-bot, drift, followup, w4-queue, flow:statement-push-error-handling-and-retry, priority:medium, auth-failure, config-bug-detection, cross-cutting]
created: 2026-04-22
source: Oracle Learn
project: github.com/kokarat/bank-bot
---

# drift — statement-push-auth-failure-silent-stall (W4 queue item, priority: mediu

drift — statement-push-auth-failure-silent-stall (W4 queue item, priority: medium)

**Flow doc reference:** `docs/flows/statement-push-error-handling-and-retry.md@6efc727` §Error paths entry "Auth failure (wrong `X-Bot-Secret` — all three crossings)" (flagged `[DRIFT]` from first pass, ratified via thread #38 Q4 on 2026-04-22).

**Thread verdict anchor:** thread #38 (closed 2026-04-22) Q4 — human confirmed this is in-scope for statement-push flow (NOT out-of-scope to `bot-bootstrap-and-status-reporting.md`). Pick detection + process.exit pattern aligned with existing `consecutiveLoginFailures` convention.

**Root cause.** Every Gateway HTTP call in `core/api.js` sends `X-Bot-Secret` header (`core/api.js:13-15@6efc727`). If the secret is wrong or the gateway has revoked it, every call returns 401 or 403. `core/api.js::request()` at `:33-38` throws `err.status = 401/403` with `err.response = {message: ...}`. Every caller's catch block treats this as a generic error — same as transient 5xx. The statement-push outer catch at `app.js:720-737` logs `Statement scrape failed (non-fatal)` and moves on. No detection of the 401/403 status code specifically. No escalation. Cursor-reload on next tick does NOT fix a wrong config.

**Why it's harmless when config is correct.** Normal operation never sees 401/403 — the `BOT_SECRET` env is set at Droplet provisioning time and rarely rotates.

**Why it's a drift.** Three failure modes produce permanent silent stall:
1. **Wrong `BOT_SECRET` at deploy.** New Droplet provisioned with the wrong env value (typo, copy-paste from another environment, stale secret rotated out). Bot boots, polls, logs "non-fatal" errors forever, never actually pushes statement rows or claims items. Operator sees "bot is running" (green systemd status) but matching is stalled on that bank account.
2. **Secret revoked on gateway side.** Security rotation deleted the credential, the matching env update on the Droplet was missed. Same symptom.
3. **Gateway JWT middleware upgrade** that changes the accepted token format. Same symptom at a different scale (would affect every bot simultaneously until every Droplet gets updated).

Detection latency today: unbounded. Symptom surfaces only when a client escalates a missing deposit / stuck withdrawal.

**Fix plan (central detector recommended — "Option B" from thread #38).**

Place detector in `core/api.js::request()` (NOT in scattered callers). Rationale: 401/403 affects EVERY endpoint (config fetch at startup, claim, mark, statement push, balance update, otp poll, status report). Centralizing detection means ANY failing call contributes to the counter, which detects ~3× faster than counting only statement-push failures alone. Wrong-secret Droplet would detect on the 3rd call regardless of which endpoint fires first.

Implementation sketch:

1. Add module-level state at top of `core/api.js`:
   ```
   let consecutiveAuthFailures = 0;
   const MAX_AUTH_FAILURES_BEFORE_EXIT = 3;
   ```

2. In `request()` catch-like path (after parsing `json` from response but before the `!res.ok` branch), add:
   ```
   if (res.status === 401 || res.status === 403) {
     consecutiveAuthFailures++;
     console.error(\`[API] Auth failure (${consecutiveAuthFailures}/${MAX_AUTH_FAILURES_BEFORE_EXIT}) on ${method} ${path} — X-Bot-Secret may be rejected\`);
     if (consecutiveAuthFailures >= MAX_AUTH_FAILURES_BEFORE_EXIT) {
       console.error('[API] Bot secret repeatedly rejected — exiting for systemd restart');
       // Use console.error NOT log.warn because core/api.js may not have logger imported at top scope — depends on current structure. Verify at implementation time.
       // Attempt a last-ditch reportStatus (best-effort) before exit:
       try { await fetch(\`${this.apiUrl}/api/v1/bank-status/report\`, { method: 'POST', headers: {...}, body: JSON.stringify({ status: 'error', message: 'Bot secret rejected' }) }); } catch {}
       process.exit(1);
     }
   }
   ```
   Then continue to the normal `!res.ok` throw path so callers still handle the error normally.

3. On any 2xx response, reset counter at the top of the success path: `consecutiveAuthFailures = 0`. Placement depends on current code structure — reset must fire on ANY successful call, not just statement-push.

**Why `process.exit(1)` is the right response.**
- systemd `Restart=always` will restart the process. If config is still broken, same error recurs, restart loop is visible in `systemctl status` / `journalctl` as restart-cadence alert signal to ops.
- Alternative "stay alive with error status" would leave the process running indefinitely, hiding the config bug behind ambiguous "online but doing nothing" state. Crash-and-burn is clearer.
- Aligns with the existing pattern at `app.js:1532-1535@6efc727` where `consecutiveLoginFailures >= MAX_LOGIN_FAILURES_BEFORE_RESET` triggers `resetBrowser()`. Same smoothing-then-escalate shape; different escalation target.

**Scope.** Exactly 1 file: `core/api.js`. Changes:
- 2 lines of module state.
- ~10 lines of detector logic inside `request()`.
- 1 line of counter reset on success.

Total: ~13 lines added, 0 removed.

**Why centralizing in core/api.js beats per-caller detection.**
- Every endpoint is covered by default — no risk of forgetting to add the check at a future new endpoint.
- Counter is shared state — 1 × claim + 1 × mark + 1 × push = 3 signals toward the same threshold, detecting faster.
- Single testing surface — one detector to verify, not scattered callers.

**Open design decisions deferred to implementation time.**
- Where exactly in `request()` does the counter reset fire? Probably right after `json = JSON.parse(text)` succeeds (which proves the call got through). Implementation should verify.
- How does the detector interact with endpoints that legitimately return 401/403 as a non-error signal? At `6efc727` there are no such endpoints; all 4xx from our gateway are genuine client errors. If that changes, add an allow-list.
- Should the detector also fire `consecutiveAuthFailures = 0` on any NON-401/403 response even if it's non-2xx? Probably yes — 404 (legitimate "no items" response from `/queue/claim`) and 500 (transient gateway failure) are both evidence the credential is accepted. Reset on ANY non-401-non-403 response, not just 2xx.

**Testing.** Stage-test by swapping `BOT_SECRET` to an invalid value, run bot, observe exit after 3 calls (~30s latency given claim + push + status all hit in one poll cycle). Verify systemd restart happens. Verify log output has the "Bot secret rejected" line. Manual-only; no unit test infra at `f8bcdf5`.

**Related drifts (share the same W4 bundle opportunity):**
- `drift-statement-push-cursor-get-silent-swallow` (Q1)
- `drift-statement-push-4xx-no-circuit-breaker` (Q2)

Q4 (this drift) is in a DIFFERENT file from Q1+Q2 (`core/api.js` vs `app.js`), so bundle is optional — could ship Q4 standalone or together with Q1+Q2 at implementation time. Recommendation: bundle all three because the theme is coherent and reviewers will want to see the whole picture.

---
*Added via Oracle Learn*
