---
title: CallbackLog gained actor-tracking fields at dc9f7d8 (#372, 2026-05-02). Three ne
tags: [technical-writer, repo:mobiz-payment-gateway, current, callback, audit-trail, actor-tracking, callback-actor, dc9f7d8, pr-372]
created: 2026-05-02
source: models/callback_log.go:21-46@dc9f7d8 + services/callbackService.go:96-300@dc9f7d8
project: github.com/kokarat/mobiz-payment-gateway
---

# CallbackLog gained actor-tracking fields at dc9f7d8 (#372, 2026-05-02). Three ne

CallbackLog gained actor-tracking fields at dc9f7d8 (#372, 2026-05-02). Three new optional `bson:"omitempty"` fields on `models.CallbackLog`: `TriggeredBy` (username or "system"), `TriggeredByType` (admin / client / merchant / system), `TriggerSource` (approval / status_change / resend / auto_match / scheduler / expiry). Threaded through `services.callbackService` via a new `models.CallbackActor{By, Type, Source}` struct passed to `SendDepositCallbackBy` / `SendDepositCallbackForceBy` / `SendPayoutCallbackBy` / `SendPayoutCallbackForceBy`. Non-`By` variants kept for backward compat default to package-level `SystemActor`. Convenience constants exported: `SystemActor`, `SchedulerActor`, `AutoMatchActor`, `ExpiryActor`. Trigger sites updated: deposit approval + status-change + manual resend (DepositController), payout manual resend (PayoutController), matcher auto-match (transactionMatcher uses `AutoMatchActor`), CallbackRetryScheduler retries (callbackService uses `SchedulerActor`). Driven by production case DEP1777588568B6V4E4 on 1 พ.ค. 2026 where two near-identical callback_logs entries (admin approve + manual resend that reset callback_attempts to 0) could not be disambiguated. The outbound webhook payload shape sent to clients is unchanged — the new fields live only in the internal `callback_logs` collection.

---
*Added via Oracle Learn*
