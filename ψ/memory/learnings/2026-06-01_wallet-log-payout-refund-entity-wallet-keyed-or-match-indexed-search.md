---
title: wallet-change-log — payout refund sites re-keyed to entity=wallet + admin-list OR-match + indexed request_id search (#505)
tags: [technical-writer, repo:mobiz-payment-gateway, current, wallet, payout, wallet-change-log, w2, track-commit]
created: 2026-06-01
source: controllers/WalletChangeLogController.go:65-103,454-471,534-573@a9a3acb
related:
  - 2026-05-07_w2-track-commit-39141ff-walletchangelog-union
project: github.com/kokarat/mobiz-payment-gateway
---

`a9a3acb` (#505, 2026-06-01) makes three refinements to the wallets_change_logs
audit trail. No balance math changed — "the money is correct; only the index was
wrong" (repro `PAY1780306054S7AIW1`, refund existed, wallet balance correct at
฿480,343.47 = `balance_after`, but admin UI surfaced only the deduct row).

**(A) Write side.** Three payout *refund* write sites now log
`entity_type=wallet` + `entity_id=wallet._id` (was `entity_type=client` +
`entity_id=client._id`), matching the deduct side written at payout creation so
both rows point at the same `wallet._id`:
- `PayoutController.UpdatePayoutStatus` (admin status → `failed`) — line ~948
- `PayoutController.CancelPayout` (admin cancel) — line ~1182
- `PayoutRequestController.CancelPayout` (client cancel) — line ~757

`EntityName` falls back to `payout.ClientName` when the wallet doc has no
`owner_name` (legacy wallets). **Partially supersedes** the #423 (`39141ff`)
motivation: the PayoutController admin-cancel refund is no longer client-keyed.
`MaintenanceCancelScheduler` refunds were NOT touched and may still be
client-keyed — covered by (B).

**(B) Read side.** Wallet↔owner union extracted from `buildEntityLogFilter` into
a shared `resolveWalletEntityIDs()` helper and now ALSO applied to the admin
`GetAllWalletChangeLogs` `?entity_id` filter (previously a single-`entity_id`
match, see #378): resolves to `{$in: [wallet._id, wallet.owner_id]}` so the admin
"filter by wallet" dropdown surfaces deduct + refund even for legacy
client-keyed entries.

**(C) Indexed request_id search.** New `resolveSearchToReferenceID()` — a `?search=`
string starting with `PAY`/`DEP`/`TOP`/`STL` is looked up in the source
collection (`ts_payouts`/`ts_deposits`/`ts_topups`/`settlements`) and the filter
rewritten to the indexed `reference_id` field, instead of `$regex` on the
unindexed `note`. A single request_id search on a ~4M-row collection 500'd via
the 10s context timeout (~182k-row date-filtered COLLSCAN). Applied symmetrically
to `GetAllWalletChangeLogs` + `buildEntityLogFilter`; unrecognized prefixes /
misses fall back to the original regex.

Financial-adjacent (wallet audit trail) — CC'd `code_reviewer` on the W2 PR
(#507 amend). Documented in `docs/current-system.md` §3.2 wallet-change-logs row.
