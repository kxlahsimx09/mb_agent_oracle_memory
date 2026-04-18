---
title: flow — deposit-slip-upload-admin-approve — intent at a glance.
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, deposit-slip-upload-admin-approve, reverse-engineered, ratification-pending, deposit, admin-approve, thunder, mdr, callback]
created: 2026-04-17
source: docs/flows/deposit-slip-upload-admin-approve.md@c5270b3
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — deposit-slip-upload-admin-approve — intent at a glance.

flow — deposit-slip-upload-admin-approve — intent at a glance.

Purpose (not implementation): the admin-assisted fallback branch of the deposit pipeline. When the bank-statement matcher cannot pin a payer's transfer to a single `ts_deposits` row — either because the statement has not arrived yet or the match is ambiguous — the client forwards the payer's transfer receipt (slip) to the gateway. The gateway verifies the slip via Thunder API, parks the deposit in `status: "checking"` (hidden from the automatic matcher by design), and waits for an admin to issue the terminating decision. Admin approval is the wallet-credit event, not the matcher — a different code path, a different actor (JWT + `deposit:approve`), a different audit trail. The client-observable contract is the same `deposit.completed` callback as the happy path; the difference is only in *which* code path queued it.

Actors: Client (API-Key, forwards slip), Payer (end-user, out-of-band via Client UI), Gateway (this repo), Admin (JWT + RBAC), Thunder (external slip-verification API).

Key divergence points from the matcher path (all open for ratification):
- Admin-only bypass of the `transRef` duplicate guard (`DepositController.go:1954-1973`) — admins can attach the same slip to multiple deposits; clients cannot.
- `wallets_change_logs.operation` is `"deposit"` on this path but `"deposit_match"` on the matcher path — ops reports that filter on a single string miss half the volume.
- Admin-reject branch (non-"paid" status) does NOT write `approved_by`/`approved_at` — reject is recorded as status-only, not as an approval-decision event.
- Silent-skip on inactive-partner / missing-partner-wallet MDR shares — client is still credited in full; no audit row indicates the dropped share.

Alternate entry: admin may upload the slip directly via `POST /api/v1/deposits/:id/upload-slip` (`UploadSlipAdmin`) instead of waiting for the client to forward. Same Thunder + `status=checking` flow; 409 duplicate guard is bypassed for admin callers. Still requires a separate `PUT /:id/status` call to approve — no auto-approve.

Doc: docs/flows/deposit-slip-upload-admin-approve.md (claim strength S4 at `c5270b3`; ratification thread #6, wallet-op thread #7).
W8 root trace: 4b076751-86c5-42b6-ba5a-e3dfea9ea6b3.

---
*Added via Oracle Learn*
