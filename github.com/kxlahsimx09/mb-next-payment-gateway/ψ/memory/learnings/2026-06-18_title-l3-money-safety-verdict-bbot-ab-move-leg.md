---
title: title: L3 money-safety verdict — bbot A→B move legs (run live-bbot-abmove2-17817
tags: [next-investigator, repo:mb-next-payment-gateway, next, verify, live-l3, epic-seal, money-safety, bbot, abmove]
created: 2026-06-18
source: RAW Postgres recompute — sinuwgsqqyqzlpaavimf, run live-bbot-abmove2-1781773586 (request_id suffix 81773586)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: L3 money-safety verdict — bbot A→B move legs (run live-bbot-abmove2-17817

title: L3 money-safety verdict — bbot A→B move legs (run live-bbot-abmove2-1781773586)

MONEY-SAFE-GREEN. Independent §ADR-21 L3 recompute from RAW gateway Postgres (sinuwgsqqyqzlpaavimf, service-role read-only via aws-1-ap-southeast-1 pooler), keyed by request_id suffix 81773586. Harness self-report NOT trusted — verdict derived from ts_deposits / ts_payouts / wallets_change_logs / callback_queue / withdrawal_queue / mdr_shared only.

3 NEW (moved) A→B legs:
- L1j client deposit-cancel (DEPOSIT-010): deposit L1j-cancel (b0d4e390) status=cancelled, cancelled_at set, paid/expired/failed NULL; ZERO wallets_change_logs rows; ZERO callback_queue rows (callback-silent, 0 deposit.cancelled run-wide). Cross-tenant: L1j-xtenant (3964746d) belongs to client …003, NOT cancelled (cancelled_at NULL), expired naturally → cross-tenant cancel DENIED, tenant-scope held.
- L1n 2-profile MDR fan-out (WALLET-003/007): both paid, conservation EXACT to satang. A (731.00): net 717.84 + partner 7.31 (PT1 4.39 + PT2 2.92) + residual 5.85 = 731.00, gap 0.00, 1 deposit_credit. B (888.00): net 865.80 + partner 6.22 (PT1) + residual 15.98 = 888.00, gap 0.00, 1 deposit_credit; PT3 (…003) mdr_skip 'partner_inactive' → its 2.66 folded into residual (13.32 base + 2.66 = 15.98). mdr_shared rows match mdr_distribute ledger.
- L4m bank-maintenance auto-cancel (PAYOUT-010): MAINT (19b9be18) status=cancelled, ts_payouts.failure_code NULL by design. Ledger: payout_freeze 1944.74 (frozen 4908.55→6853.29) then payout_unfreeze 1944.74 (6853.29→4908.55) 'cancel_stale_payout unfreeze'; ZERO payout_settle; balance unchanged. Exactly ONE payout.cancelled callback, delivered, payload.failure_code='bank_maintenance'. Maintenance path: withdrawal_queue required_bank_account_id=77777777-…001 (system_bank_code=scb / Siam Commercial Bank), claimed_by NULL (NOT bot-claimed), status cancelled.

4 invariants (run-wide) ALL HOLD: (1) Conservation — all 7 paid deposits gap 0.00; success payout PAY…IDEM settle 1281.95 = gross 1263.00 + partner 12.63 + residual 6.32. (2) Exactly-one-callback — 16 terminal events each 1 row, 0 duplicate dedup_keys; payload amount byte-matches txn recorded amount. (3) Balance≥frozen — all 7 wallets ok; 0 ledger rows frozen_after>balance_after. (4) Money-in/out-once — 1 deposit_credit per paid (no double-credit), 1 payout_settle for the 1 success payout, both cancelled payouts' freezes released exactly once.

VERDICT: MONEY-SAFE-GREEN — A→B move legs certified.

---
*Added via Oracle Learn*
