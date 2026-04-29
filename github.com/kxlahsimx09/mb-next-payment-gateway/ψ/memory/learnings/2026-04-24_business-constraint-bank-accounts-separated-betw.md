---
title: Business constraint — bank accounts separated between deposit-purpose and payout
tags: [business-constraint, repo:mb-next-payment-gateway, next, repo:cross, pool, bank-account, deposit, payout, role-separation, anti-detect, adr-8, architectural-invariant, system-architect, user-ratified]
created: 2026-04-24
source: User ratification in thread #46 (2026-04-24 GMT+7) in response to Phase-2 unified-metric sub-question
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Business constraint — bank accounts separated between deposit-purpose and payout

Business constraint — bank accounts separated between deposit-purpose and payout-purpose; never mixed.

## Source + ratification

User ratification during thread #46 (ADR-8 pass-2 ratification discussion, 2026-04-24 GMT+7). Confirmed explicitly in response to Phase-2 unified-metric sub-question:

> "แยกเหมือนเดิม เพราะ business เคาะมาแล้วว่าจะแยก กันเสมอ ระหว่าง bank deposit กับ bank payout. ถ้าเอามาใช้ร่วมกันถือว่ารับรู้แล้วว่าอาจจะ เกิดปัญหาเรื่อง anti-detect blindspot ได้"

## The constraint

**`bank_account` entities are role-assigned by business policy:** each account has exactly one purpose (deposit OR payout/settlement/pullout/direct-transfer). Deposit-accounts and payout-accounts are **physically different bank accounts** — different account numbers, different portal logins, different actual bank accounts at the financial institution.

Technical surface:
- `system_banks.method` field (array) in current system technically allows multiple methods per account
- In practice under this business policy, each `system_bank` document has exactly one direction's methods:
  - Deposit-only: `method: ['deposit']`
  - Payout-only: `method: ['payout', 'settlement', 'pullout', 'direct_transfer']` (or subset)
- Pool's `bank_accounts[]` array therefore contains mixed-role members; filtered at query time by `method`

## Implications for fair-router design (§ADR-8 pass 2)

### Anti-detect "blind spot" concern — **not applicable under this policy**

Earlier pre-ratification discussion flagged a latent blind spot: bank portal sees unified activity (deposits + withdrawals) but current-system rotations coordinate only within their own direction. Under this business separation:
- Payout-only account's `daily_transactions` = all outgoing activity on that portal
- Same account's `deposit_count` = always 0 (no deposit activity ever)
- Withdrawal-only LRU metric (`daily_transactions + queueLoad`) **fully captures** what that bank portal sees
- **No blind spot in practice** because no single account has cross-direction activity to blind-spot

### `bankDailyUsage` withdrawal-only = correct, not just parity

Fair-router LRU metric choice:
- **Port verbatim (withdrawal-only)** → CORRECT under this constraint
- **Unified metric (daily_transactions + deposit_count)** → inappropriate; would be adding 0 for payout-only accounts (no-op) + scope-crosses business boundary

### Phase-2 unified-metric opportunity — moot; removed from ADR

Previously flagged as Phase-2 design opportunity. With business constraint known, it's not an opportunity, it's a category error. Remove from §ADR-8.

## Revisit trigger

**If business policy changes to allow mixed-method bank accounts** (one account handles both deposits and payouts) → reopen the unified-metric question. Anti-detect blind spot becomes real again under mixed accounts. User acknowledged this risk explicitly:

> "ถ้าเอามาใช้ร่วมกันถือว่ารับรู้แล้วว่าอาจจะ เกิดปัญหาเรื่อง anti-detect blindspot ได้"

(If accounts are mixed, we acknowledge the anti-detect blind-spot problem could occur.)

→ Documented in §ADR-8 §Revisit triggers as explicit trigger for reopening.

## Scope impact

- **§ADR-8 pass 2:** sub-question 6 (Phase-2 metric) answered — port verbatim; removed from open sub-questions
- **§ADR-8 §Critical finding, §Consequences:** "blind spot" language removed or reframed as "not applicable under business separation"
- **§ADR-8 §Revisit triggers:** new trigger for policy change
- **Future subsystem design (deposit auto-match lane, admin-review, etc.):** inherits this constraint; can design independently for deposit-side and payout-side flows

## Cross-references

- `learning_2026-04-24_current-system-prior-art-deposit-routing-via-se` — deposit routing uses `deposit_count` independently
- `learning_2026-04-24_correction-to-findbestbankforitem-prior-art-ban` — withdrawal routing uses `daily_transactions` independently
- `learning_2026-04-22_current-system-prior-art-pool-data-model-shar` — pool is shared between deposit+payout (at the pool level), but individual bank_accounts within pool are role-assigned
- `learning_2026-04-24_w1-adr-8-pass-2-completeness-sub-amendment-x` — current ADR-8 text (needs amendment for this business constraint)

## Durability

This is a **current business policy** that should be preserved as a load-bearing assumption in next-system design. Not a platform constraint; not a bank-portal limit. Pure business operational choice.

If future business pivot allows mixed accounts, treat as a major architecture trigger — multiple design decisions across withdrawal lane + deposit lane + fair-router LRU would need re-examination.

---
*Added via Oracle Learn*
