---
to: orchestrator-build (next session) + next-architect + next-pm + next-product-writer + brew-ops + owner
from: orchestrator-build 2026-06-11
priority: P1
topic: PLAN (do NEXT session) — build mb-next-bank-bot (statement auto-match is the MAJORITY deposit flow) + dispatch a team to author the missing ADR/requirement/spec for the bank-bot↔gateway ingestion contract
project: github.com/kxlahsimx09/mb-next-payment-gateway + (new) mb-next-bank-bot, from kokarat/bank-bot
tags: [bank-bot, mb-next-bank-bot, statement-automatch, deposit, adr-4b, bot-statements, live-gate, gap-analysis, plan]
---

# PLAN — mb-next-bank-bot + statement-auto-match golden journey (NOT done this session; dispatch next)

## The owner insight that drives this
The LIVE-gate PREP authored the DEPOSIT golden journey through the **slip-upload → admin-approve** path — but **that is the MINORITY case**. The **MAJORITY real flow is statement AUTO-MATCH**: customer transfers → bank statement scraped → matcher links it to the pending deposit (destination + amount + source-identity) → `finalize_deposit` credits. So:
- The §ADR-21 golden journey should (re)centre on the **auto-match path** (the dominant money flow), which **structurally requires a bank statement source** — this is why `MOCK_BANK_URL` mattered more than first scoped, and why fault (i) dup-`bank_transaction_id` is core, not peripheral.
- Re-scope question for next-architect: is the §ADR-21 "ONE golden journey" the auto-match path (recommended), or do we keep slip as a second journey? Pin it.

## Owner's plan: build `mb-next-bank-bot` from `kokarat/bank-bot`
- **Reference repo:** `kokarat/bank-bot` (current production bank-bot — the real scraper).
- **Keep AS-IS:** everything that talks to the **bank portal** (login, scraping, statement parsing — the hard/real part).
- **Adapt ONLY the gateway-facing side** to the **mb-next-payment-gateway API** (replace the mobiz-era gateway calls with the next-system ingestion contract + auth).

## What the gateway side ALREADY has (so the gap is mostly bank-bot-side + contract docs)
- **Ingestion EFs exist:** `supabase/functions/bot-statements` + `bot-bank-statements-last` (the endpoints a bank-bot POSTs scraped statements to).
- **Matching engine exists:** §ADR-4b (two decoupled flows — deposit requests + bot-scraped statements — linked by the matcher; `match_deposits_cascade`, Step-1/2a/2b). `bank_statements` table + `bank_transaction_id` + `uq_bank_statements_dedup_in` (the dup-credit=0 invariant).
- **Bot↔gateway auth defined (G6-D, §ADR-2:57):** bot is NOT an `auth.users` row / not in `entity_type`; it authenticates with a **Supabase service-role JWT bound to `bank_account_id`** (admin-issued, unforgeable) per §ADR-4a §Security boundary. **Bot infrastructure + identity lifecycle is owned by §ADR-6.**

## Dispatch next session — GAP ANALYSIS + author what's missing (architect/pm/writer)
1. **next-architect** — confirm/seal the **bank-bot↔gateway ingestion contract**: is §ADR-6 (bot infrastructure/identity) authored for next-system? Is the `bot-statements` POST contract (request/response shape, the statement fields incl. `bank_transaction_id`, dedup semantics, the per-`bank_account_id` service-role JWT issuance) fully specified, or only implied by the EF? Pin the §ADR-21 golden-journey re-scope (auto-match primary). Name the ADR gaps.
2. **next-pm / next-product-writer** — is there a **requirement/epic** for "bank statement ingestion + auto-match" on the next-system side (or only the deposit-side epic)? Author the missing epic/stories for the mb-next-bank-bot integration + the per-`bank_account_id` bot provisioning.
3. **next-writer** — author the **spec** for the gateway-facing adapter the mb-next-bank-bot must implement (the `bot-statements` API contract + auth + retry/dedup) so the bank-bot team builds to a contract, not to code.
4. **brew-ops / fleet** — register the new repo `mb-next-bank-bot` (the 4-touchpoint fleet add: clone, vault `.agent`, `~/.config/maw/fleet` FLEET_DIR symlink, `maw.config` agents entry) + scaffold its secret slot. (See memory `fleet-add-repo-role-procedure`.)

## How this unblocks the LIVE gate (cross-ref the prep handoff `2026-06-10_06-30_orchestrator-build-deposit-auth-hardening-live-prep-session`)
- The **SIM mock-bank** (`MOCK_BANK_URL`) can be realised as either a thin mock of the `bot-statements` ingestion OR the mb-next-bank-bot run against a mock bank-portal. Either way it provides the inbound statement (+ the dup-credit flag for fault (i)).
- Then the **auto-match golden journey** (the majority flow) becomes runnable end-to-end, and **REAL-BANK mode (M2, §ADR-21 — deferred, bank-bot-gated)** has its real scraper = mb-next-bank-bot.

## Do NOT start this session — this is the plan + gap-analysis brief for the next orchestrator-build session.
