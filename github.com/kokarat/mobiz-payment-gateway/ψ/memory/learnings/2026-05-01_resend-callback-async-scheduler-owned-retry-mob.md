---
title: Resend-callback async + scheduler-owned retry (mobiz `d2a2738` #349, 2026-05-01)
tags: [technical-writer, repo:mobiz-payment-gateway, current, callback, scheduler, rbac, tenant-guard, deposit, payout, regression-candidate]
created: 2026-05-01
source: controllers/{Deposit,Payout}Controller.go@d2a2738 + scheduler/callback_retry.go@d2a2738 + services/callbackService.go:23-33,395-510@d2a2738 + helpers/permissions.go:775-820@d2a2738 + controllers/SubClientController.go:923-934@d2a2738
project: github.com/kokarat/mobiz-payment-gateway
---

# Resend-callback async + scheduler-owned retry (mobiz `d2a2738` #349, 2026-05-01)

Resend-callback async + scheduler-owned retry (mobiz `d2a2738` #349, 2026-05-01). `POST /:id/resend-callback` on both deposits and payouts now returns 202 Accepted immediately, runs the first attempt in a goroutine, and resets `callback_attempts=0` + `callback_sent=false` so the row re-enters the retry budget. Persistent retry is owned by new `CallbackRetryScheduler` (scheduler/callback_retry.go, 1-minute interval, lock:callback_retry). Was previously synchronous: caller blocked ~36 s on 3 attempts × exponential back-off, observable now that frontend PR #111 puts the Callback button in front of clients/sub-clients (not just admins).

Permission gate dropped: `PermApprove("payout"|"deposit")` → `PermUpdate(...)` for resend-callback only — `approve` is reserved for status changes that move money; resend-callback is an idempotent retry of an already-sent webhook so `update` is the right gate (matches the permission clients/sub-clients actually have).

Tenant guard: new `helpers.CallerOwnsClientResource(c, targetClientID)` helper called after the row is fetched — staff (`user_type` not in {`client`, `sub-client`}) bypass; client must match `JWT.user_id == client_id`; sub-client looks up `users.parent_client_id`. Fail-closed on JWT/user-record decode error. 403 message bilingual TH/EN. Currently wired only on the two resend-callback endpoints; commit message intent is "every other endpoint that mutates a client-scoped resource (status updates, cancels, settlement creation, etc.)" — those endpoints remain inline-permissioned at HEAD, sweep candidate for W4. Open thread #58 with security_auditor for ratification of the user_type gate semantics + fail-closed-on-missing-user_type behavior.

`ProcessPendingCallbacks` (was dead code since initial commit) now bounded: `created_at >= now-24h` window cutoff, `last_callback_at <= now-2min` per-row cooldown, `SetLimit(100)` per collection per tick, sort `last_callback_at ASC` (longest-waiting wins). Recommended compound index `{callback_sent:1, callback_attempts:1, last_callback_at:1, created_at:-1}` deferred to a separate migration.

`SubClientController.UpdateSubClient` now invalidates `roles:permissions:<role>` cache when `roles[]` or embedded `resource[]` is in the update payload — was the last write path that mutated permissions without cache invalidation. Caveat preserved: sub-client JWTs carry embedded resource[] snapshots baked at sign-time, so a re-login (or refresh-token) is still required for them — cache invalidation is necessary but not sufficient.

Resources seed gained `update` + `match` actions on `payout` and `deposit` so the role-edit permission grid no longer disables the Update checkbox for those resources. Production DB updated in lockstep via `db.resources.updateOne($addToSet)`.

---
*Added via Oracle Learn*
