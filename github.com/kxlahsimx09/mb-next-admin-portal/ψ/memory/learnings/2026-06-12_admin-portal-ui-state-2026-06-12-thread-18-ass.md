---
title: admin-portal UI state @ 2026-06-12 (thread #18 assessment) — the portal is a REA
tags: []
created: 2026-06-12
source: thread #18 reply 2026-06-12; route-classification sweep + src/lib/*-api.ts read-only audit
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# admin-portal UI state @ 2026-06-12 (thread #18 assessment) — the portal is a REA

admin-portal UI state @ 2026-06-12 (thread #18 assessment) — the portal is a READ console, not yet an OPERATOR console.

All 13 "live" screens are READ-ONLY watch surfaces: every src/lib/*-api.ts data lib (deposits/wallet/payouts/transactions/bank-statements/entities/monitoring) has ZERO .insert/.update/.delete/.upsert/.rpc/.functions.invoke. The operator can watch deposits, wallets, queues, callbacks, statements, entities — but cannot ACT (approve/reject/match/adjust/resend/verify).

Route census: 13 LIVE-WIRED (dashboard, deposit, payout, wallet, transaction, wallet-logs, queue=withdrawal_queue, bank-statements, activity-log=audit_log, callbacks=callback_queue, mdr-shared, clients/merchants/partners) · 15 MOCK-ONLY on src/lib/mock.ts (bank-accounts, direct-transfer, mdr, login-log, otp-logs, bot-telegram, topup, settlement, system-bank, reports, revenue, subclients, pull-out, setting/telegram, users/roles) · 6 static/utility.

Coverage vs WUI docs: Wallet WUI-001 ✅ / 002 🟠 / 003 ⛔ / 004 🟠. Auth WUI-002+003 ✅, 001 🟠 (4 login failure-states not distinguished), 006/008 🟡mock, 009/013/015 ⛔. Deposit WUI-101+109 ✅ (read), but 102/103/104/114 (4 of the 6 HIGH = all action surfaces) ⛔ NOT-BUILT. P2P WUI-115..122 ALL ⛔ (design+docs merged via campaign/p2pui+p2puiprev, §ADR-17 ratified, no /p2p screens; WUI-122 match-preview = docs yes/UI no).

The biggest gap and recommended next arc = "Deposit Operator Action Console": make /deposit actionable (WUI-104 approve/reject first, then WUI-102 match-pick, WUI-114 slip-review, WUI-103 slip-upload+AU1). Backend substrate is live-verified; WUI-104 is NOT step-up-gated (WUI-013 covers refund/DTR/settlement/pullout only).</pattern>
<parameter name="concepts">["next-ui","repo:mb-next-admin-portal","next","coverage-matrix","read-only-console","deposit-action-console","WUI","gap-analysis","thread-18"]

---
*Added via Oracle Learn*
