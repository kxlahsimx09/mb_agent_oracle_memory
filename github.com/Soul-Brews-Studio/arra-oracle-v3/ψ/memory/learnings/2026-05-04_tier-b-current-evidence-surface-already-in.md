---
title: ## Tier-B `#current` evidence surface — already-in-repo, not yet vault-indexed
tags: [brew-ops, repo:cross, repo:mobiz-payment-gateway, repo:bank-bot, vault, current, next, prior-art, fixture-source, evidence-mining, poc, decision, thread-72, parent-thread-69]
created: 2026-05-04
source: brew-ops sub-C analysis on parent #69 fan-out, thread #72 (2026-05-04 15:55 GMT+7); direct-read of mobiz HEAD + arra_concepts
project: github.com/soul-brews-studio/arra-oracle-v3
---

# ## Tier-B `#current` evidence surface — already-in-repo, not yet vault-indexed

## Tier-B `#current` evidence surface — already-in-repo, not yet vault-indexed

Title: Tier-B #current evidence surface — mobiz integration-tests + mock-bank/FIXTURES.md + docs/flows are the unindexed-but-free fixture source for #next PoCs

When mining `#current` evidence for `#next` PoC fixtures (e.g. `next-impl` W1 Step 2/3 cite-block requirement per parent thread #69 → sub-C thread #72), the vault is NOT the only zero-cost source. Direct-read of mobiz HEAD surfaces a substantial Tier-B layer that was missed in initial fan-out scoping:

**Tier-B inventory (mobiz `kokarat/mobiz-payment-gateway`, HEAD 2026-05-04):**

1. `docs/flows/*.md` — 10 files, pg-writer-curated reverse-engineered flows with `// impl:` line-anchors. Highest signal-density per byte.
2. `integration-tests/test-*.sh` — 30+ named real-case scenarios (deposit-collision-dual, deposit-fifo-dual, payout-bot-race, payout-auto-reconcile, multi-bank-stress-unique-amt, slip-fraud, idempotency, mdr-fee-distribution, dispatcher-stale-bot-skip, …). Each is a named fixture-shopping target.
3. `integration-tests/mock-bank/FIXTURES.md` — pre-curated inventory of "production-plausible bank quirks/bugs" seeded 2026-04-21 per Oracle thread #28. 6-field shape per entry (admin toggle / status probe / client behavior / mechanism / gate conditions / bot action). Already in fixture-shape.
4. `integration-tests/*.log` — 52,511 lines from real-ish runs (mock-bank.log = 4,324 lines; bank-bot-{ktb,scb,burst,fifo,late,gologin}.log family). Closest to "raw text logs from #current" without prod access.
5. `integration-tests/mongo-init/init-replica.sh` — locally-runnable Mongo replica bootstrap for PoCs that need real Mongo against synthesized-but-shaped data.
6. `tests/*.go` — flow-shaped Go tests (deposit_flow_test.go, payout_bot_race_test.go, payout_expiry_test.go, bank_rotation/, pullout/, withdrawal_queue/, testutil/setup.go + payoutSetup.go).

Bank-bot equivalent (`kokarat/bank-bot`): `docs/flows/*.md` (10 files) is the only Tier-B asset. `tests/cursor.test.js` is the only indexed test. Playwright archives are ephemeral (Tier-C gap).

**How to apply:**

- For `next-impl` W1 Step 2 (claim extraction) cite requirement: behavior-shaped claims should cite ≥1 source from Tier A (vault `arra_search ... #prior-art / #drift / #gotcha / #regression-candidate`) OR Tier B (the 6 sources above). Path-and-line cite for Tier B; learning-id cite for Tier A.
- For W1 Step 3 (test scaffold): docstring 2-line cite block — (a) ADR line-anchor + (b) source.
- Tag with `#fixture-source:vault-learning` (Tier A) or `#fixture-source:integration-test` / `#fixture-source:repo-flow-doc` (Tier B).
- Tier C (raw prod Mongo / Playwright trace archives / Telegram operator logs) is **not** required for Tier-1 day-1 PoCs (§ADR-3/4a/4b/4c — Postgres-only-floor). Surface as deferred-decision when Tier-2/3 PoCs name them load-bearing; do not preemptively escalate.

**Why this matters beyond next-impl:** any future agent (testers, writers, future PoC roles) auditing what `#current` evidence is free-to-read should hit this learning first instead of re-discovering the surface via direct-read.

Tags: brew-ops, repo:cross, repo:mobiz-payment-gateway, repo:bank-bot, vault, current, next, prior-art, fixture-source, evidence-mining, poc, decision, thread-72, parent-thread-69

---
*Added via Oracle Learn*
