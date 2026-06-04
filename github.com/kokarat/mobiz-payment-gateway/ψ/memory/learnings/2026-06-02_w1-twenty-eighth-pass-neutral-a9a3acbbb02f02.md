---
title: W1 twenty-eighth pass NEUTRAL — a9a3acb..bb02f02 (1 production-surface commit) z
tags: [tester, repo:mobiz-payment-gateway, current, w1, no-op, wallet-log, payout, reference-id, coverage-gap, w1-twenty-eighth-baseline]
created: 2026-06-02
source: controllers/PayoutController.go::OverridePayoutStatus+ConfirmPayoutCompleted@bb02f02 + db/indexes.go@bb02f02 + integration-tests/test-payout-override.sh:454-472 + test-payout-confirm-completed.sh:397,464-481 + docs/test-index.md (PR #506 amend, twenty-eighth pass)
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 twenty-eighth pass NEUTRAL — a9a3acb..bb02f02 (1 production-surface commit) z

W1 twenty-eighth pass NEUTRAL — a9a3acb..bb02f02 (1 production-surface commit) zero flips; amend extending PR #506

W1 twenty-eighth validate pass (amend extending the open PR #506, branch feat/tester-validate-2026-06-01). Range a9a3acb..bb02f02 contains exactly ONE new production-surface commit since the twenty-seventh pass: #510 bb02f02 "fix(payout): populate reference_id+reference_type on override/confirm wallet logs". Cumulative PR range now a011daf..bb02f02 (12 production-surface commits, all NEUTRAL).

What #510 changes: adds ReferenceID=payout.ID + ReferenceType="payout" to FOUR models.WalletChangeLog creations in controllers/PayoutController.go — OverridePayoutStatus (mdr_distribution_reversed ~L1803, payout_override_refund ~L1841) and ConfirmPayoutCompleted (payout_confirm_completed ~L2055, mdr_distribution ~L2114). Purely additive: entity_id / entity_type / operation / amount are unchanged at every site. Companion: two compound indexes on wallets_change_logs in db/indexes.go ({created_at:-1,_id:-1} base sort + {operation:1,created_at:-1,_id:-1} operation filter, drain a 5.2s COLLSCAN on a 4M-row admin list), and a standalone dry-run scripts/backfill_payout_wallet_change_log_reference.go ops migration.

Why NEUTRAL (verified at HEAD bb02f02, P-004): the only two tests on these write sites — test-payout-override.sh (L454-472) and test-payout-confirm-completed.sh (L397, L464-481) — assert wallets_change_logs via db.wallets_change_logs.countDocuments({entity_id, operation}) ONLY, never reference_id/reference_type. Since #510 leaves entity_id+operation byte-identical, every count is unchanged -> 0 flips. The single reference_id-filtering test, test-payout-admin-cancel.sh:261-262, asserts the /payouts/:id/cancel admin-cancel refund (operation:'add') — a write site #510 did NOT touch (it already carried reference_id, which is why that test passes today). The two new indexes are EnsureIndexes-declared at boot, transparent to query results (grep -rnE "idx_wallet_log|EnsureIndexes|created_at.*_id" integration-tests/ -> 0 hits); the backfill script is an offline ops tool never reached by the runtime or any test.

Net: matrix carries forward verbatim — 44 VALID / 1 STALE (test-settlement-cancel.sh) / 0 WRONG-SETUP / 0 FLAKY / 2 SUPERSEDED / 2 ON_HOLD / 0 UNKNOWN. VALID rows' last-verified bumped a9a3acb->bb02f02 (44 rows). One 🟢 coverage-gap row appended (override/confirm reference_id population + wallet-log index coverage — unverified by any test; a future assertion reference_id==payoutOID on the override+confirm rows, mirroring test-payout-admin-cancel.sh:261, would lock the link-back invariant).

Related: continues [[2026-06-01_w1-twenty-seventh-pass-amend-of-pr-506-509]] and [[2026-06-01_w1-twenty-sixth-pass-neutral-a011dafbf57c0e-9]].

---
*Added via Oracle Learn*
