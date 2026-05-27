---
title: Settlement money-movement timing — freeze-at-create via §ADR-10 primitive (decis
tags: [system-architect, repo:mb-next-payment-gateway, next, settlement, wallet, data-model, decision, adr-12, adr-10, thread-236, freeze-settle]
created: 2026-05-26
source: dpay prod (settlements N=2986 wallet_before 100%; wallets_change_logs settlement_request@created_at) + §ADR-10 freeze-settle + thread #236/#233
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Settlement money-movement timing — freeze-at-create via §ADR-10 primitive (decis

Settlement money-movement timing — freeze-at-create via §ADR-10 primitive (decision, thread #236 / #233).

§ADR-12 settlement flow — wallet-debit timing resolved (next-architect consult #236; next-writer flagged in #233).

DECISION (within architect authority; applies already-ratified §ADR-10 freeze-settle): a settlement RESERVES the amount at CREATE time using the §ADR-10 freeze primitive (balance → frozen), exactly mirroring payout (PAYOUT-001). On bank-success the freeze SETTLES out (frozen decreases, money leaves). On reject / bank-failure the freeze is RELEASED (frozen → balance, back to spendable). Timing = create, NOT approve.

P-004 grounding (dpay prod 2026-05-26):
- settlements: 2,986 docs, wallet_before populated 100%; wallet_balance = wallet_before − final_amount (post-debit snapshot; there is no wallet_after field).
- wallets_change_logs: every settlement emits a settlement_request op timestamped at the settlement's created_at, NOT approved_at (cross-check: created 12:51:17 / wallet moved 12:51:17 / approved 13:02:13 — wallet moved 11 min before approval).
- reject path: settlement_rejected_refund (23) + settlement_refund (162) reverse the debit → confirms reject returns the reserved balance.

MECHANISM DIVERGENCE (deliberate, non-inherited): prod uses a direct balance-debit (balance −= amount) + refund; next-system uses the §ADR-10 freeze-then-settle primitive instead, unifying ALL withdrawal-side money movement (payout + settlement) under one primitive. Merchant-observable effect is identical (spendable reduced at create, returned on reject) → architectural-consistency choice, not a money-policy change (hence within architect authority, no human ratification needed).

Story impact (next-writer authoring): SETTLE-001 / SETTLE-002 ACs already use 'reserve' / 'reserved' / 'return the reserved amount' language → CORRECT; no AC text change. Only the [AWAITING_THREAD:233] anchor on the SETTLE-001 wallet-debit-timing edge-case closes, with: 'reserve = §ADR-10 freeze at create, mirroring payout.' §ADR-12 amendment doc to follow (bundled with Q2 MDR resolution after user money sign-off).

---
*Added via Oracle Learn*
