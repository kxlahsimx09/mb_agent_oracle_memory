---
title: regression-candidate — payout-admin-cancel (d) callback not resend-safe on gorou
tags: [technical-writer, repo:mobiz-payment-gateway, current, regression-candidate, followup, flow:payout-admin-cancel, callback, idempotency, resend, goroutine, admin-cancel, payout]
created: 2026-04-21
source: docs/flows/payout-admin-cancel.md + controllers/PayoutController.go:1069-1072@aff85e1 + services/callbackService.go:176-422@aff85e1 + thread #34 closed 2026-04-21
project: github.com/kokarat/mobiz-payment-gateway
---

# regression-candidate — payout-admin-cancel (d) callback not resend-safe on gorou

regression-candidate — payout-admin-cancel (d) callback not resend-safe on goroutine-kill between HTTP response and async delivery. `CancelPayout` at `controllers/PayoutController.go:1069-1072@aff85e1` spawns the `SendPayoutCallback` in a goroutine *after* the HTTP 200 response is written at line 1074-1078. A process restart — SIGKILL from OOM, `kubectl` rolling update, panic in a sibling handler — between the response (step 11) and the goroutine actually running (step 12) leaves the payout `cancelled` + wallet refunded + **no callback delivered**. The admin sees success, the client's integration never learns the payout was cancelled.

`services.ProcessPendingCallbacks` exists at `services/callbackService.go:379-422` (originally added for deposits per `deposit-auto-expire-pending` thread #19 Q-b: latent, not dead) but is **not wired to any scheduler** for payouts at HEAD `aff85e1`. A manual `POST /api/v1/payouts/:id/resend-callback` endpoint exists (`routes/payout.go:33`) but requires operator awareness that a callback was lost — which typically only happens when the client complains.

Ruled regression-candidate via thread #34 on 2026-04-21. Human preference: file as **separate per-flow learning** cross-linked to the existing unified learning `2026-04-21_regression-candidate-callback-resend-with-idempo.md` (which covers `payout-auto-cancel-pending-timeout` (d) via #31 + `deposit-auto-expire-pending` Q-d via #19) rather than scope-extending the unified learning to a third rail. Rationale: a three-rail unified learning was workable but risks becoming a dependency hairball — per-flow entries with cross-links let each flow's owner pick up independently without the unified learning becoming a blocking prerequisite.

Fix sketch (shared primitive across all three rails — payout-admin-cancel + payout-auto-cancel-pending-timeout + deposit-auto-expire-pending): (i) add `callback_sent` / `callback_attempts` / `last_callback_attempt_at` fields to both `ts_payouts` and `ts_deposits` (fields already exist on both; current uses are inconsistent); (ii) wire `ProcessPendingCallbacks` for payouts into a periodic scheduler (the function exists but only scans deposits at HEAD — extend to payouts with the same scan pattern); (iii) idempotency guard — set `callback_sent=true` in the same DB write as the successful HTTP delivery (the update-callback-status path at `services/callbackService.go:254` already does this for deposits; ensure the payout path hits the same update); (iv) guard against duplicate delivery via a callback-event-id (add to `PayoutCallbackPayload`) or `If-None-Match`-style client-side check.

A combined PR across all three rails is still viable — the separated-learnings structure just keeps the W4 queue surface cleaner. If W4 schedules one unified PR, cross-reference all three rail learnings in the PR body so the coverage is traceable. If W4 schedules per-rail PRs, each one delivers one rail's wiring + tests independently and the shared primitive (i)-(iv) should converge through code review.

Companion: cross-references `2026-04-21_regression-candidate-callback-resend-with-idempo.md` (covers the two other rails).

---
*Added via Oracle Learn*
