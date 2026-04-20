---
title: drift — deposit-auto-expire-pending step 7 — callback resend machinery (`service
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, flow-divergence, flow:deposit-auto-expire-pending, step:7, callback, ratification-pending]
created: 2026-04-19
source: docs/flows/deposit-auto-expire-pending.md@153a4f6 + services/callbackService.go:379-422@153a4f6
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — deposit-auto-expire-pending step 7 — callback resend machinery (`service

drift — deposit-auto-expire-pending step 7 — callback resend machinery (`services/callbackService.go:379-422`) has zero callers.

Flow `deposit-auto-expire-pending` step 7 (§Implementation pointers) claims the client receives 2xx ack with 3-attempt retry on non-2xx. The inline retry loop at `services/callbackService.go:156-168` does exactly that. However the tree also contains `ResendPendingCallbacks()` at `:379-422` — a function that scans `ts_deposits` and `ts_payouts` for `callback_url != "" AND callback_sent = false AND callback_attempts < maxRetries` and re-fires the callbacks. This function has **zero callers** in the repo at `153a4f6` (`grep -rn ResendPendingCallbacks .` returns no hits outside its own definition).

Two readings compete:

1. **Intentional** — clients must poll `GET /api/v1/deposit-request/status/:requestId` to reconcile after 3-attempt exhaustion. `ResendPendingCallbacks` is dead code left over from a rejected design. The flow's actor-contract is "best-effort callback, reconcile via polling". In this reading the code is consistent with itself.

2. **Latent gap** — the function was drafted to be wired to a scheduler in `main.go` and the wiring was forgotten or deferred. The flow doc-as-claim would then be "callback delivery has full resend machinery" while code-as-fact is "only inline 3-attempt retry". Clients that assume eventual delivery would silently miss terminal expiry notifications on transient client-side outages longer than ~12 seconds.

The flow doc provisionally marks step 7 `[DRIFT]` pending Oracle thread #18 ratification (question (b) of four). If human ratifies reading 1, the marker is stripped in a revision pass and prose is clarified; if reading 2, the flow doc retains `[DRIFT]` and the gap is a W4 queue item for a `#regression-candidate` follow-up (either wire `ResendPendingCallbacks` to a 1-minute scheduler, or delete the dead function with a `#dead-code-removed` learning).

Exacerbating factor: the scheduler-killed-mid-tick case (§Error paths last bullet) produces the same observable DB state as "callback never attempted" (`callback_sent=false, callback_attempts=0`). With no resend path, a lost callback after process kill is also unrecoverable without polling.

Evidence:
- Code: `services/callbackService.go:379-422@153a4f6` — function definition.
- Code: `services/callbackService.go:156-168@153a4f6` — inline retry loop (the only live retry path).
- Absence: `grep -rn ResendPendingCallbacks --include='*.go' .` returns only the definition in `services/callbackService.go`.
- Flow doc: `docs/flows/deposit-auto-expire-pending.md` §Implementation pointers step 7 + §Open questions (b).

Queued for W4 on ratification outcome. If thread #18 question (b) rules "intentional", supersede this learning with a #undocumented-step-benign equivalent.

---
*Added via Oracle Learn*
