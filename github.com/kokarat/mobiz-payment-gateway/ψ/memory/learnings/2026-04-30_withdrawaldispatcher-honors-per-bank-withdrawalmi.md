---
title: WithdrawalDispatcher honors per-bank withdrawal_min_amount + withdrawal_max_amou
tags: [technical-writer, repo:mobiz-payment-gateway, current, withdrawal-queue, dispatcher, bank-rotation, operator-config]
created: 2026-04-30
source: scheduler/withdrawal_dispatcher.go:499-525@ae6f523, services/bankRotation.go:61-72@ae6f523
project: github.com/kokarat/mobiz-payment-gateway
---

# WithdrawalDispatcher honors per-bank withdrawal_min_amount + withdrawal_max_amou

WithdrawalDispatcher honors per-bank withdrawal_min_amount + withdrawal_max_amount at ae6f523 (PR #335, 2026-04-29). The system_banks fields `withdrawal_min_amount` / `withdrawal_max_amount` are exposed in the operator UI under "ถอน (Payout + Settlement + Direct Transfer + Pullout)" but the dispatcher (`scheduler/withdrawal_dispatcher.go:findBestBankForItem`) never consulted them when picking a source bank for a queue item. Result observed 2026-04-29 on bank 0170715728: a 759 baht payout landed on a bank flagged for ≥1000 only. Fix adds two checks after the existing balance check: skip if `bank.WithdrawalMinAmount > 0 && item.Amount < bank.WithdrawalMinAmount`; skip if `bank.WithdrawalMaxAmount > 0 && item.Amount > bank.WithdrawalMaxAmount`. `0` in either field means "no limit" — same convention as `MaximumOutstandingWithdrawal`. Applies to every withdrawal `source_type` the dispatcher routes (payout, settlement, direct_transfer, pullout) so the UI label is honored literally. Skip lines log per-bank. Operational caveat: an item below every active bank's minimum sits in pending until a bank is reconfigured; the existing "no idle bank" pending-loop already covers that shape — operators see the row in `/withdrawal-queue` and can cancel or loosen a bank's min. The legacy `services/bankRotation.go:SelectBankForPayout` that did filter on these fields is **deprecated** in the same commit (kept only for tests; payouts go through `withdrawal_queue` + dispatcher in production).

---
*Added via Oracle Learn*
