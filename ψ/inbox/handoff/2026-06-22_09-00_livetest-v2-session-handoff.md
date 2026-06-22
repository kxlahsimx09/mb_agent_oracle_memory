---
from: next-live-tester (session 2026-06-21)
to: [next-live-tester]
date: 2026-06-22T09:00:00+07:00
topic: Session handoff — LIVE test journey v2 (readable rewrite): framework done, D1 implemented + GREEN, cast provisioned 100% via admin API; next = build more cards
status: PR #679 + #707 MERGED to main; D1 runs GREEN on staging end-to-end; the v2 doc is published in docs-site as "LIVE Test Journey" (v1 trio marked obsolete). Pick up the next card.
tags: [#repo:mb-next-payment-gateway, #live-tester, #live-test-journey-v2, #d1, #reseed-cast, #handoff]
---

# Handoff → next-live-tester: continue the v2 LIVE test journey

## TL;DR of where things stand
- **The doc:** `docs/requirements/live-test-journey-v2.md` is THE live-test journey now (readable rewrite,
  owner-driven). Published in docs-site as **"LIVE Test Journey"**; the v1 trio (`live-test-journey.md`,
  `bbot-live-journey.md`, `bbot-coverage-matrix.md`) carry an **OBSOLETE banner** and are reference-only.
- **D1 (golden deposit, real-bot auto-match) is built + GREEN on staging.** `journey-d1.ts` +
  `run-live-d1.sh`. Run it: `cd poc/integration && OWNER_GO_LIVE_D1=1 ./run-live-d1.sh`.
- **The cast is provisioned 100% through the real admin API** (`reseed-core-cast.ts` / `run-reseed-cast.sh`),
  captured to a **manifest** `.secrets/slots/v2-cast.json`. Only `reset_runtime_state` + `mint_bot_credential`
  remain as declared non-API RPCs (no EF wraps them).
- **All work is in `main`** via PR #679 (squash) + #707 (the bank-counter reset that landed after #679).
  The branch `agents/23-revise-live-test` is closed + 37 behind main → **start new work on a branch off main.**

## The v2 framework (read §0–§1.2 + Appendix B of the doc first)
- **Test Card format:** `### <ID> · title` / **Covers** (story+AC) / **Status** / **Speed** / **Cast** / (Setup) /
  **What it does** / **Passes when**. IDs: `A`=AUTH `B`=BANK-BOT `D`=DEPOSIT `P`=PAYOUT; faults `F-`.
- **Speed → regression (§1.1):** every card is FAST or SLOW. **Regression list = FAST only** (§7.6); SLOW
  (real bot / real money / waiting / virtual clock / tunnel callback) runs in a separate set, never mixed.
- **Isolation & realism (§1.2):** staging only, **under a single-writer lock** (`staging-lock.sh`); the **cast
  is created once and kept**, but every card **resets all cast STATE** first (txn tables via
  `reset_runtime_state`, mock-portal `/sim/reset`, login users pruned to keep-cast, **per-bank daily counters**
  `daily_deposit_count`+`deposit_count`); setup via the **real API** (declared DB only where no EF exists).
  `assertCoreCastReady` BLOCKs (never fake RED/GREEN) if the cast isn't reseeded.
- **Coverage tracker (§7)** tracks every Phase-1 story of the 4 core epics → fill in card-by-card. The owner
  reviews **every card** before the next; write docs, then build the harness, then run.

## Canonical cast (Appendix B) — provisioned via API into the manifest
`reseedCoreCast` (super_admin AAL2 front-door login → admin-EFs) creates: **2 merchants** (MERCHANT-MAIN
Siam Megastore, MERCHANT-OTHER Lanna Trading), **7 clients** (CLIENT-MAIN..FAIRROUTER incl. the CLIENT-SUB
sub-client), **3 partners** (PARTNER-A/B active, PARTNER-INACTIVE via `admin-partners-disable`), **2 MDR
profiles**, **5 pools**, **7 banks**, all wiring + callbacks → **manifest** `.secrets/slots/v2-cast.json`
(ids/keys server-generated; cards read from the manifest, NOT a hardcoded namespace). Then it **prunes** every
non-manifest entity. **`BANK-SCB-BOT` (account 0117000001) + `BANK-KTB-BOT` (0117000002) are deployment-fixed**
(the deployed Fargate bots scrape those) — never recreated, only moved into their pool.

## How to run (staging)
```bash
cd /home/ubuntu/Code/github.com/kxlahsimx09/mb-next-payment-gateway.<worktree>/poc/integration
./run-reseed-cast.sh            # (re)provision the cast → manifest. Idempotent (no-op if manifest complete).
OWNER_GO_LIVE_D1=1 ./run-live-d1.sh   # D1 golden deposit (real bot). Holds the staging lock; ~1–2 min.
```
- **Receiver:** the deployed **mock-merchant EF** (`$SUPABASE_URL/functions/v1/mock-merchant`) — `run-live-d1.sh`
  defaults `RECEIVER_BASE_URL` to it (the local cloudflared quick-tunnel does NOT route on this host).
- **Lock:** `~/Code/github.com/Soul-Brews-Studio/arra-oracle-v3/scripts/staging-lock.sh` (acquire/release auto;
  STOP if another agent holds it — owner decides wait/steal).
- **Roles (ADR-35 DB-driven RBAC):** provisioning = `super_admin` only (or `super_cs`); perms live in the DB
  `role_permissions` table now, not a code map.

## Contract gotchas learned (so you don't re-hit them)
- **`admin-clients/merchants/partners-create` SERVER-GENERATE ids** — you can't pass your own → that's why the
  manifest exists; the client `api_key`+`secret` are returned **once** (in the manifest).
- **`admin-mdr-create`** needs all THREE fee%s non-null in [0,100] (pass `topup_fee_percent:0`).
- **MDR cascade semantics:** partner `percentage` is a **percent of the GROSS deposit**, and Σ ≤
  `deposit_fee_percent` (else `match_deposits_cascade` RAISEs `mdr_over_allocated`). So "60/40 of a 3% fee" =
  `1.8 / 1.2`, NOT 60/40.
- **`admin-pools-set-client`** (PROV-010, deployed) writes client↔pool membership — use it (no more direct
  `pool_members` insert).
- **Prune FK chains:** client → {app_user, client_profiles} by client_id AND parent_client_id + callbacks +
  pool_members + wallet (+2-pass for sub-clients); merchant → merchant_profiles; bank → {bot_credentials,
  bank_account_method}; mdr → mdr_profile_partners.

## What's NEXT (suggested order)
1. **Build more DEPOSIT cards** — D2/D3 (FAST front-door rejections; start the regression roster), then the
   SLOW slip lane + expiry + faults. Cards D1–D7 are already designed in §6.
2. **Captured journeys ready to build** (parked PLANNED in the doc):
   - **P-OVERDRAW** (GW-X-02, ACT 4) — Model-B reserve-at-claim; **fix DEPLOYED+GREEN on staging → runnable
     now** (J1–J7). Strong money-safety card to build next.
   - **D-REC** (GW-REC-01/MATCH-004, ACT 3) — self-healing source-recovery parser; PR #696 merged, **run after
     a staging deploy** (ping orchestrator).
   - **B-RECYCLE** (BOT-D-02/F-07, ACT 2) — SCB browser-recycle; **live-test-hard** (induced wedged-session;
     owner hard-rule: mock-portal contract frozen → may stay unit/integration tier; bounce to orchestrator).
   - **P-MAINT-SWEEP** (GW-SCH-02, ACT 4) — system-wide maintenance lockdown sweep (cancel-all-pending-payouts
     →refund incl. the UNROUTED one + expire-all-pending-deposits); clock-driven; PR #711 merged, **run after
     deploy**. Captured via **PR #714** (docs-only — merge it to land the card in main).
3. **Expand the cast use:** D5/D7 use CLIENT-SECOND/SUB; KTB lane uses CLIENT-KTB + BANK-KTB-BOT; enforcement
   uses CLIENT-ENFORCE; fair-router uses CLIENT-FAIRROUTER — all already in the manifest.

## Open flags / residuals (not blocking)
- **Prod gap — MDR not merchant-bound:** `create_deposit` picks the MDR profile as "first `mdr_profile` by
  `created_at`", not by the client's merchant (code says "PoC: first one. In prod this would be merchant-bound").
  v2 only works because reseed prunes all other profiles so PROFILE-MAIN is first → PROFILE-OTHER never runs.
  **Worth a RED-first card** (Appendix B has the write-up). 
- **`reset_runtime_state` doesn't clear `bank_account.daily_deposit_count`** — the harness zeroes it per-card
  (journey-d1), but the gateway RPC arguably should too (so the admin-portal "reset" matches). Possible
  gateway handoff to dev/brew-ops.
- **2 inert fairrouter fleet banks** (`0117000005/0117000006`) linger after prune (FK); harmless.
- Memory files (this session's context): `live-test-journey-v2-revision`, `live-deposit-receiver-and-run`,
  `gwx02-overdraw-journey` under the project memory dir.
