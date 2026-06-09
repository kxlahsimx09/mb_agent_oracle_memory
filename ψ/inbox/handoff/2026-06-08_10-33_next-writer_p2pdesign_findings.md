# next-writer — P2P design pass (campaign p2pdesign) findings

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/351 (base `main`, MERGEABLE, NOT merged — owner merges)
**Branch:** `campaign/p2pdesign` · **Commit:** `b500e5c` · **Date:** 2026-06-08

## Deliverable
Authored `docs/design/p2p-matching/` — the design pass §ADR-17 explicitly defers (`adr.md:4150`). 7 files split by concern, each ≤250 lines, each cites the PM/DP id it elaborates. Did NOT re-author the ADR (done, PR #333) or touch `adr.md`.

- README.md (64) — overview, decision→impl map, composed-substrate table
- data-model.md (114) — PM2 wallet_kind, PM3 change-log ops, PM6/PM-O3 SPLIT pool tables, PM12/DP10a queue flag, DP7 p2p MDR rates, DP0 state columns
- schema.sql (180) — full Postgres DDL (provisional, not applied)
- matching-engine.md (125) — DP0 LOCK/PUBLISH, DP1/DP2 FIFO-primary, PM7 concurrency, DP10 overflow, DP11 migrate/truncate
- settlement-rpcs.md (138) — PM3 transfer_between_wallets, PM9/DP5 *_p2p per-leg settle, 3 ports, DP8 MatchSettled payload, PM4/PM5 EF wiring, PM11 extractability
- failure-and-expiry.md (109) — DP4 leg-failure matrix, DP3 over/underpay, DP6 windows+sweep
- data-validation.md (95) — sim-grounded defaults (reproduces match_sim.py)

## Pinned within ADR-17 scope
- Pool = SPLIT (confirms PM-O3 architect lean).
- DP0 counter = p2p_withdrawals.remaining; PUBLISH iff remaining=0; lock_best_fit = greedy largest-that-fits, amount≤remaining (DP3), FIFO tie-break.
- Concurrency ported from p2p-hub: single-shot status guard + FOR UPDATE SKIP LOCKED + D5 wallet.id ASC lock-order.
- TransferVerifier signature + MatchSettled payload pinned (both OPEN in ADR-17).
- Global p2p_config defaults (DP6): grid=50, min=50, X=5000, SLA=15m, transfer=45m, deposit_ttl=30m, T_large=90m, retries=2.

## Sim re-run (seed 42): grid-50 w50=0 → 88.4%; +5% 50-baht → ~100%; X=5000 → 12.7% routed @95.3%; SLA flat 10→60m → short-fail-fast confirmed.

## OPEN (flagged, owner/policy — NOT decided)
DP3 two-ledger underpay reconciliation (PM-O1); FeeDistributor GROSS/NET base (DP7); KYC/penalty/dispute (PM-O6, Phase-1 notify-only); sweep cadence; Phase-2 PM12 items.

## Coordination
Unstaged next-ui's `docs/design/p2p-matching/ui/` before committing — only my 7 core files in b500e5c. Broadcast sent; next-ui commits UI on top.

DISREGARD prior "p2pdoc" handoffs — built on a stale duplicate-ADR premise; this campaign supersedes them.