---
title: flow — topup-approve-mdr-distribution — intent at a glance.
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, topup-approve-mdr-distribution, topup, mdr, wallet, admin-approve, reverse-engineered, ratification-pending, workflow-8]
created: 2026-04-18
source: docs/flows/topup-approve-mdr-distribution.md@252849e
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — topup-approve-mdr-distribution — intent at a glance.

flow — topup-approve-mdr-distribution — intent at a glance.

An admin approves a pending `topup` request (`status: 0 → 1`) via `PUT /api/v1/topups/:id/status` with `{status: 1, notes}`. The gateway runs a single atomic MongoDB session transaction (`processTopupApproval`, `controllers/TopupController.go:707-1118@252849e`) that: (1) flips the topup row to `status=1, processed=true` via a CAS on `status NIN [1,2] AND processed ≠ true` — double-defence against double-credit; (2) credits the client wallet (`owner_type: "client"`) `$inc balance/available by topup.net_amount`; (3) for each partner in the snapshotted MDR profile with `topup_percentage > 0 AND status == 1`: credits the partner's active wallet by `helpers.CalculateFee(topup.amount, topup_percentage)` — note: share is a percentage of **gross amount**, not of the fee; (4) writes `wallets_change_logs` rows with `operation: "topup"` (client credit) / `operation: "mdr_distribution"` (each partner credit) — these change-log inserts are best-effort, errors silently swallowed; (5) inserts one `mdr_shared` row iff ≥1 partner was credited; (6) embeds `mdr_distributions[] + total_distributed` back onto the topup row. After the session commits, a `transactions` row is inserted **outside** the transaction (`:1059-1095`), best-effort — failure is logged + swallowed, topup stays approved regardless. No SSE event, no external callback — admin-only flow.

Four gaps identified for ratification (folded into Oracle thread #11):
(a) Residual fee routing — `topup_fee − Σ partner shares` is deducted from net_amount but never credited to an owner wallet (`wallets.is_owner`), contradicting prior learning `ψ/memory/learnings/2026-04-15_fact-owner-wallet-mdr-tracking.md`;
(b) Asymmetric partner handling — inactive partner silently skipped, but missing partner wallet aborts the entire transaction;
(c) `ProcessTopup` endpoint (`POST /topups/:id/process`) appears dead after `processTopupApproval` consolidated the two-phase approve+process into one atomic call — no topup can reach `(status=1, processed=false)` via the canonical path, and `ProcessTopup` skips MDR distribution;
(d) Reject branch writes no `transactions` row and no `rejected_*` audit fields — mirrors the deposit-slip-upload-admin-approve retro #6(c) concern.

Doc: `docs/flows/topup-approve-mdr-distribution.md` (claim strength S4, RATIFICATION_PENDING:11). W8 root trace: `cdab28ba-f5df-49c7-9616-8caf30661c7b`. Cross-linked from `docs/current-system.md` §3.2 at the flow-cross-link cluster.

---
*Added via Oracle Learn*
