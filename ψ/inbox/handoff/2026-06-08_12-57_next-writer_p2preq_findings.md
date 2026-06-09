# next-writer — p2preq handoff (P2P backend requirement)

**Campaign:** p2preq · **Date:** 2026-06-08
**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/354 — base `main`, branch `campaign/p2preq`, **MERGEABLE, NOT merged** (owner merges; CI = UNSTABLE/in-flight, no conflict).

## Done

Authored `docs/requirements/epic-p2p-matching.md` — the **backend** P2P product-requirement epic (the user-story layer the design pass `docs/design/p2p-matching/` implements). House-style-matched to epic-deposit/epic-payout; 249 lines (≤250 budget).

Ten stories, **all S3 (provisional)** → flip to **S2 when owner GO ratifies §ADR-17** (currently `#provisional`):
- P2P-001 P2P deposit (opt-in, matched + direct-transfer instruction, no QR) — PM1/PM5/DP1
- P2P-002 P2P withdrawal (p2p-wallet freeze → held-withdraw pool) — PM5/PM8
- P2P-003 1:N LOCK-then-PUBLISH matching, no money until complete — PM7/DP0-DP2/DP9
- P2P-004 Thunder-verified per-leg in-ledger settlement (`*_p2p` RPCs) — PM8/PM9/PM10/DP5
- P2P-005 leg-failure matrix forged/mismatch/timeout/over-underpay — DP3/DP4
- P2P-006 pool SLA/expiry release + unfreeze — DP6
- P2P-007 large-amount overflow → payout (Phase-1 upfront >X) — PM12/DP10
- P2P-008 P2P fee w/ partner split via FeeDistributor port — DP7
- P2P-009 client lifecycle callbacks (MatchSettled→callback_queue) — DP8
- P2P-010 normal↔p2p transfer + top-up destination — PM2/PM3/PM4

Deferred P2P Surfaces recorded: after-the-fact payout-fallback (PM12 trigger-2), N:1/M:N, deposit-splitting, dispute engine (PM-O6), pure-P2P secondary queue + remainder-migration (DP10b/DP11, out of gateway scope / PM11 seam).

Companion edits: INDEX.md (new `## P2P Matching` section — committed FIRST so next-ui appends P2P-UI ids after; broadcast sent), glossary.md (+5 terms: p2p wallet, P2P route, held-withdraw pool, LOCK/PUBLISH, destination-match), README.md (epic-index row).

## Serialization

writer → ui. My INDEX edit is committed/pushed (f3bda26); next-ui is clear to append its P2P-UI ids after my section, rebasing on campaign/p2preq first.

## For downstream

- Bump S3→S2 across the epic + README + INDEX when §ADR-17 ratifies (grep `S3 provisional (→ S2 on §ADR-17 ratification)`).
- Design-pass residuals the requirement leaves open: expiry-window numbers + sweep cadence (DP6/PM-O4), `TransferVerifier` port signature + two-ledger underpay reconciliation (DP3/PM-O1), `MatchSettled` payload schema (DP8), overflow X tuning (default 5,000, PM-O8).

## Scope boundaries (bounced)

ADR (§ADR-17 / docs/adr.md), design pass (PR #351), P2P UI requirement (next-ui), ratification (owner) — all out of my layer.
