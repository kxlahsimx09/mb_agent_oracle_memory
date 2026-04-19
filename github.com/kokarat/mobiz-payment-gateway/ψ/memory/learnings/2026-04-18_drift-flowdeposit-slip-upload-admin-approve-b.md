---
title: drift — flow:deposit-slip-upload-admin-approve (b) silent skip of inactive-partn
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow, deposit-slip-upload-admin-approve, mdr, audit-log, wallets-change-logs, partner-revenue]
created: 2026-04-18
source: controllers/DepositController.go:902-908@c5270b3 + thread #6
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — flow:deposit-slip-upload-admin-approve (b) silent skip of inactive-partn

drift — flow:deposit-slip-upload-admin-approve (b) silent skip of inactive-partner / missing-wallet MDR shares.

Location: controllers/DepositController.go:902-908 @ c5270b3 (admin-approve path) AND services/transactionMatcher.go (matcher path) — same behaviour in both call sites.

What happens: when MDR fees are distributed for a paid deposit, the controller iterates partners in the deposit's MDR profile. For each partner: if the partner's wallet doesn't exist OR the partner's `Status != 1` (not active), the loop `continue`s past that partner with NO action. No `wallets_change_logs` row, no error returned, no warning logged. The dropped partner share is simply lost — the client still sees the full credit they expect, but the partner economics are silently incomplete.

Why it's a gap: makes it impossible to query "which partners are losing MDR revenue this week, and why?" without grepping app logs (and there's no log line either). A partner whose wallet was accidentally archived or whose status was flipped to 2 (suspended) by a misclick will silently lose all incoming MDR until someone notices in finance reports.

Same behaviour exists in matcher path — so this isn't admin-flow-specific drift; it's a system-wide MDR distribution gap. The deposit-slip-upload doc surfaces it because that's where the human first asked.

Human ruling (2026-04-18, Oracle thread #6): drift / coverage gap; fix later.

Recommended fix: emit a `wallets_change_logs` row with operation="mdr_skip", entity_type="wallet" (or "partner" if no wallet exists), entity_id=partner.ID, amount=&lt;the share that would have been credited&gt;, balance_before=balance_after=&lt;current partner balance, or 0 if no wallet&gt;, and a structured note like `partner_inactive: status=2` or `wallet_missing: no row for owner_type=partner owner_id=&lt;id&gt;`. Add at both call sites (DepositController.go and transactionMatcher.go). ~30 LoC total.

Side effect: enables ops queries like `db.wallets_change_logs.find({operation:"mdr_skip"})` and dashboard alerts on dropped MDR revenue. Doesn't change wallet semantics — just makes the loss visible.

Source: docs/flows/deposit-slip-upload-admin-approve.md@&lt;ratification-commit&gt; §Resolved questions (b) + controllers/DepositController.go:902-908@c5270b3 + services/transactionMatcher.go (same pattern)
W8 root trace: 4b076751-86c5-42b6-ba5a-e3dfea9ea6b3
Ratification thread: #6
Queued for: W4 reconciliation pass; this is system-wide drift, may benefit from being fixed at the helper level (services.distributeMDRFees) rather than per-call-site.

---
*Added via Oracle Learn*
