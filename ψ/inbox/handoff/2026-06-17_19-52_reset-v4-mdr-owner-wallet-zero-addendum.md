# Addendum to bbot handoff — reset v4 (mdr_owner/merchant wallet zeroing)

Follow-up to `2026-06-17_17-02_bbot-live-test-deposit-green-withdraw-next.md` (next-live-tester, 2026-06-17).

**Finding:** the wallet page always shows **2 mdr_owner wallets**, one carrying a stale MDR-residual
balance every clean run (฿59.74→64.97 on staging). Cause: (a) **dual topology** seeded two mdr_owner
entities — old fixture `55555555-…00ff` (2026-06-08) + olive `0117e000-0e51-…001` (2026-06-13), both
`is_active=true`; (b) `reset_runtime_state` only zeroed `client→50000`/`partner→0` and **never touched
mdr_owner** (nor `frozen` for anyone). The ORIGINAL reset (migration 016) zeroed
partner+merchant+mdr_owner; the §D3 fixes (006/007/008) narrowed it to partner-only — regression.

**Fix — gateway PR #569** (migration `20260617000150_reset_runtime_v4_wallet_zero_all_owners.sql`,
applied to staging via Mgmt API): zero EVERY wallet owner_type + frozen:
`client→50000,frozen=0`; `partner/mdr_owner/merchant→0,frozen=0`. **Wallets are RESET, not
deleted/recreated** — persistent ledger accounts (UNIQUE(owner_type,owner_id), FK'd by
wallets_change_logs+mdr_shared on_delete=NO ACTION, stable id). Verified: mdr_owner→0, frozen→0
everywhere, client=50000, **wallet row count unchanged** (no delete).

**STILL OPEN (separate seed-cleanup, NOT reset):** there are still 2 mdr_owner wallets (both now 0).
If only one is wanted, confirm which mdr_owner the CURRENT topology (main_pool / bbot) uses as residual,
then retire the stale `55555555-…` entity. Don't do this in reset_runtime_state.

PR status now: bank-bot #19 merged+deployed · bank-bot #21 OPEN (KTB portal) · gateway #559 (v3) MERGED ·
gateway #569 (v4) OPEN. Brew-ops still owes: merge #21 + deploy KTB portal + add KTB_PORTAL_BASE_URL to slot.
NEXT TASK unchanged: salvage #545's withdraw lane → clean PR → close #545.
