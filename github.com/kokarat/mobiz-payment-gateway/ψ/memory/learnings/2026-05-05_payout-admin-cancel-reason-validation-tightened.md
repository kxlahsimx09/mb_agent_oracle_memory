---
title: Payout admin-cancel reason validation tightened (`cd48052` PR #404, 2026-05-05).
tags: [technical-writer, repo:mobiz-payment-gateway, current, payout, admin-cancel, audit-trail, wallet-change-logs, validation]
created: 2026-05-05
source: controllers/PayoutController.go:1023-1043,1161-1170@cd48052
project: github.com/kokarat/mobiz-payment-gateway
---

# Payout admin-cancel reason validation tightened (`cd48052` PR #404, 2026-05-05).

Payout admin-cancel reason validation tightened (`cd48052` PR #404, 2026-05-05). `PayoutController.CancelPayout` now (a) returns 400 `{message: "Invalid JSON body"}` on `BodyParser` error instead of silently swallowing, (b) trims `notes` and rejects with 400 + `code: "CANCEL_REASON_REQUIRED"` when shorter than 5 chars, (c) caps at 500 chars. Driven by audit of 9 cancellations on 2026-05-05 21:15 BKK where every `ts_payouts.notes` field was the FE-hardcoded string `"Admin cancelled"` — no audit trail of why anything was cancelled, AMPAYCS6_AUN cancelled an entire batch with that placeholder. Paired FE PR replaces `confirm()` with `prompt()` validating length client-side. The persisted reason now flows through to the `wallets_change_logs` row written in step 4: `Reason = "Payout cancelled — <admin reason>"` (new field write — previously only `Note` carried context); `Note` additionally embeds `| reason: <admin reason>` so the `/wallet-change-logs` UI surfaces it. No data migration: legacy rows keep their generic text. Test-payout-admin-cancel.sh updated (Phase 4 not-found probe at :512 needs valid notes payload to reach the 404 path). Doc at `docs/current-system.md` §3.2.3.

---
*Added via Oracle Learn*
