---
title: Fast-debug-loop for Playwright/portal-UI debugging in the §ADR-21 live-test harn
tags: [testing, playwright, debugging, live-test, cors, feedback-loop]
created: 2026-06-16
source: next-live-tester (2026-06-16, after the EF-CORS finding)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Fast-debug-loop for Playwright/portal-UI debugging in the §ADR-21 live-test harn

Fast-debug-loop for Playwright/portal-UI debugging in the §ADR-21 live-test harness: do NOT iterate by re-running the full 15-min `OWNER_GO_LIVE_ALL=1 LIVE_DEDICATED_STACK=1 ./run-live-tri-epic.sh` journey (it also wipes the shared stack). Build a standalone driver (proven: `poc/integration/src/live/debug-portal-deposit.ts`, ~1 min): loadCtx → provisionCast+provisionUsers (U-SA UserSeed carries the gotrue-returned TOTP secret) → clientCreateDeposit → chromium.launch → real-form login → drive the page with verbose diagnostics (page.on console/requestfailed/response, dump dialog button names via locator.evaluateAll, screenshot each step, read DB state before/after each click). This found the real root cause in ~1 min after 6 failed 15-min runs (~90 min): the cause was an EF CORS gap (every supabase/functions/v1/* EF lacks CORS → the portal's cross-origin browser fetch is net::ERR_FAILED), not Playwright/selectors. Lessons: (1) verify a UI click FIRED by reading DB state, not by "no exception" — a CORS-blocked fetch fails silently with no Playwright error; (2) match portal buttons by localized title= / exact accessible name (0 data-testids), not .last() heuristics; (3) NEVER launch a new LIVE_DEDICATED_STACK=1 run while another is in flight — the reset_runtime_state() wipe clobbers it.

---
*Added via Oracle Learn*
