---
title: drift-followup — admin queue-terminal endpoints classified as debug/legacy, not 
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow, withdrawal-queue-dispatch-and-claim, admin-endpoint-legacy, ratified, w4-candidate, withdrawal-queue]
created: 2026-04-18
source: Oracle thread #12 ratification 2026-04-18 GMT+7; routes/withdrawalqueue.go:24-25 + controllers/WithdrawalQueueController.go:339-401@252849e
project: github.com/kokarat/mobiz-payment-gateway
---

# drift-followup — admin queue-terminal endpoints classified as debug/legacy, not 

drift-followup — admin queue-terminal endpoints classified as debug/legacy, not operational.

Filed from thread #12 ratification of `docs/flows/withdrawal-queue-dispatch-and-claim.md` (2026-04-18 GMT+7). Human's classification of question (a).

**Endpoints:**
- `PUT /api/v1/withdrawal-queue/:id/success` (JWT, RequireUpdate)
- `PUT /api/v1/withdrawal-queue/:id/failed` (JWT, RequireUpdate)

Both defined at `routes/withdrawalqueue.go:24-25`, controller methods at `controllers/WithdrawalQueueController.go:339-401`. Controller delegates to `services.MarkSuccess` / `services.MarkFailed` — identical service call as the bot-facing endpoints at `routes/bot.go:31-32`. The cascade (source status + MDR + callback + wallet refund + bank unlock) is therefore behaviourally identical regardless of which endpoint fires it.

**Classification:** The endpoints exist for **debug/legacy** purposes, **not** as a documented bot-down operational fallback. Human confirmed during thread #12 ratification: an admin who finds a stuck queue item in production should NOT use these endpoints; the expected operational path is (i) let the bot + safety nets (`tryReconcileAfterMarkFailed`, stale-processing auto-fail at ~10 min) resolve it, or (ii) use admin-cancel (pending items only).

**Why this classification matters (gateway-facing):** Any operator reading `routes/withdrawalqueue.go` might mistake these for a supported manual-override pattern. The `withdrawal-queue-dispatch-and-claim` flow doc now carries an explicit §Error paths entry declaring them debug/legacy so the documentation trail matches the human-decided classification.

**Recommended follow-up (W4 queue item, not this pass):**
- Option A: **Remove** the endpoints + the controller methods behind them. Minimal risk — bot endpoints stay, queue cascade still works. Lose ability to poke queue items in dev without going through bot auth; acceptable trade-off.
- Option B: **Gate behind a feature flag / env var** (e.g., `ENABLE_ADMIN_QUEUE_OVERRIDE=false` in production). Preserves debug usefulness in staging/dev without exposing in prod.
- Option C: **Keep as-is but add runtime warning** — log-level warning when hit, surface in SSE as a monitored event. Cheapest change; weakest protection.

**Who owns the follow-up:** `technical_writer` flagged (this learning); `code_reviewer` decides A/B/C; `backend_developer` implements. No tester action required because the endpoints aren't in the happy-path test matrix.

**Scope note:** This is `#drift` in the sense that doc-claim ("admin manual override is operational") would diverge from human intent ("debug only, don't use"). It is **not** a code-vs-code drift — the code works as written; the issue is absence of a `#deprecated` marker or permission-gate to match intent. File is tagged `#followup` (W4 pickup) not `#drift-immediate` (W1 pickup).

**Related:**
- Thread #12 ratification message-id 23 (2026-04-18 GMT+7) for the primary-source quote.
- Flow doc: `docs/flows/withdrawal-queue-dispatch-and-claim.md` §Error paths → *"Admin manual override of queue terminal state (debug/legacy, not operational)"*.
- Sibling flow: `docs/flows/withdrawal-queue-single-bot-transfer.md` inherits the same classification implicitly (shared gateway machinery); no separate §Error paths entry needed there because it cross-references sibling's shared machinery.

---
*Added via Oracle Learn*
