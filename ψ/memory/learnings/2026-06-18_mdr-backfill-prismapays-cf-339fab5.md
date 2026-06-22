---
title: ops — MDR fee backfill for Prismapays CF8/CF9/LO8 (#541/#544, data-side counterpart to DRIFT-21 guard)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - mdr
  - deposit
  - payout
  - wallet
  - backfill
  - out-of-territory
created: 2026-06-18
source: scripts/backfill_mdr_prismapays_cf.go@339fab5
related:
  - 2026-06-17_drift-21-dangling-mdr-profile-guard
  - 2026-06-18_flow-drift-542-dangling-mdr-deposit-payout-create
project: github.com/kokarat/mobiz-payment-gateway
---

# MDR fee backfill — Prismapays CF8/CF9/LO8 (one-off operational remediation)

`339fab5` #544 (merges #541) "Backfill MDR fees — Prismapays CF8/CF9/LO8" (2026-06-18). Adds a single file `scripts/backfill_mdr_prismapays_cf.go` (577 LOC, `//go:build ignore` → standalone `go run` script, never compiled into the server binary). **Out of pg-writer W2 territory** (`scripts/` is not in the W2 territory map — same class as prior one-off backfill scripts #498/#510) so no `current-system.md` content was fast-fixed; this learning captures the durable operational fact only.

**This is the DATA-side counterpart to the code-side [[2026-06-17_drift-21-dangling-mdr-profile-guard]] guard** (`0897541` #542, DRIFT-21). The guard prevents NEW fee-less transactions going forward (delete-block 409 + create 422); this backfill repairs the HISTORICAL gap the guard could not undo.

Root cause (verified against the script header, not just the commit message): clients **CF8** (`6a283f87…`), **CF9** (`6a2840167…`), **LO8** (`6a284071…`) under merchant **Prismapays** pointed at a **deleted** `mdr_profile` (`6a255158…`). Since **10/06/2026** (`lowerDateBKK = 20260610000000`) every paid deposit / completed payout for them charged **0 fee** and wrote **no `mdr_shared`** — partners Owner-MDR / YP / TTWD168 / Bitly received nothing.

What the script does (per `scripts/backfill_mdr_prismapays_cf.go@339fab5`):
- Reads percentages **live** from the correct profile `6a284719…` ("TTWD - 2.6/0.4", 4 partners) — `deposit (paid) → amount × partner.deposit_percentage`, `payout (completed) → amount × partner.payout_percentage`.
- Per transaction: credits each partner wallet its share, **debits the client wallet by the total fee** (CF9/LO8 may go negative — merchant then owes; CF8 has balance), writes `mdr_shared` (`status:1`) + one `wallets_change_logs` row per movement.

Money-safety (binding facts for any future re-run / audit):
- **DRY RUN by default**; `--apply` to write.
- Each transaction's writes run inside **ONE MongoDB transaction** (all-or-nothing) — a crash never leaves a half-applied transaction.
- **Idempotent**: a transaction that already has an `mdr_shared` row is skipped (re-run never double-charges). Note: `mdr_shared.transaction_id` has **no unique index** — the in-memory pre-check (one up-front scan of the three clients' existing `mdr_shared` keys) is the only guard.
- **Name guard fails closed**: refuses to run unless the profile + all three clients resolve to their exact expected names (a cosmetic profile rename `TTWD - 2.6/0.4 → TTWD 2.6/0.4` is tolerated via normalized comparison; identity still pinned by exact `_id` + status + fees + 4-partner check).
- **Cluster**: data lives on the **AMPAY** cluster; the repo `.env` may point elsewhere (maxpayplus/whitelable), so `MONGODB_URI` must be set to the ampay public RW host before `--apply`. The name guard makes a wrong-cluster run fail closed (clients won't resolve).
- `--cutover` bounds the upper window at the profile-repoint time; a post-apply reconcile re-counts change-logs (= partner credits + client debits) and `mdr_shared` (= processed) from the DB and aborts on any mismatch.

Doc impact: none in territory (one-off script). Operationally significant because it explains a deliberate discontinuity in CF8/CF9/LO8 wallet ledgers + partner wallets dated 2026-06-18 (back-credited fees for the 10/06 → cutover window). Baseline stays held at `a011daf` (outstanding Finance W1 + DRIFT-17..21 re-baseline still owed).
