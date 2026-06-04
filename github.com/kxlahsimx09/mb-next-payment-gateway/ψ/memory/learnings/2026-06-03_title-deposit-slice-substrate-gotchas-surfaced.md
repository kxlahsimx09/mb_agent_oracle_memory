---
title: title: DEPOSIT slice — substrate gotchas surfaced by SPEC-driven tester (mdr_own
tags: [next-dev, deposit, seed, mdr_owner, conservation, auth, adr-19, per-client-mdr, gotcha, spec-first]
created: 2026-06-03
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: DEPOSIT slice — substrate gotchas surfaced by SPEC-driven tester (mdr_own

title: DEPOSIT slice — substrate gotchas surfaced by SPEC-driven tester (mdr_owner unseeded, auth sub=client_id, per-client MDR gap) — PR #311

Follow-up to the DEPOSIT slice build (PR #311 feat/deposit-slice, HEAD 0d737d1). next-tester binding probes off the SPEC (never the code) surfaced three real substrate facts/gaps every future mb-next deposit/wallet builder must know:

1. mdr_owner RESIDUAL WALLET WAS NEVER SEEDED. seed_bootstrap (20260510000008) creates client/partner/merchant wallets but NO owner_type='mdr_owner' wallet — every prior reference was `UPDATE wallet ... WHERE owner_type IN (...,'mdr_owner')` matching zero rows. Any code routing §ADR-10 residual-MDR to the is_owner wallet will RAISE/rollback unless it's seeded. Added migration 20260603000003_adr20_deposit_slice_fixture.sql (wallet 33333333-...-0000000001ff, owner 55555555-...-0000000000ff, idempotent).

2. CONSERVATION requires residual = deposit_fee − Σ credited partner shares (NOT Σ un-routable shares). The seed MDR profiles have deposit_fee_percent (1.2–1.8%) ≠ Σ partner-percentage (1.0%), so the fee taken from the client exceeds what partners receive; the gap (plus any skipped partner's portion) must flow to the mdr_owner wallet or the ledger leaks. With residual=deposit_fee−Σcredited, gross = client-net + Σ credited + residual holds EXACTLY by construction for any profile.

3. CLIENT-CREATE AUTH: deposits-create uses _shared/gateway-assertion.ts verifyAssertion on the X-Gateway-Assertion header (signed EdDSA/Ed25519 JWS, kid in VERIFY_KEYS env, claims sub + scope∈{deposit,payout} + rh=base64url(sha256(raw body))). It sets client_id = payload.sub DIRECTLY — sub IS the client UUID (client.id), NOT an app_user id. The app_user table (88888888-...) + the auth-fixtures unsigned base64url stub-bearer are the ADMIN/RBAC path for admin-* EFs only. Don't conflate them.

4. [KNOWN-GAP vs §ADR-19 m2] create_deposit does NOT select the MDR profile per-client: it does `SELECT id, deposit_fee_percent FROM mdr_profile ORDER BY created_at LIMIT 1` — the OLDEST profile (seed: tier-small, 1.80%) for ALL deposits, regardless of client. There is no client→mdr_profile mapping (no column/junction on client). §ADR-19 m2 (per-client/per-MDR-profile snapshot-at-create) is therefore not implemented. Flagged to next-writer/next-architect; needs the mapping + selection logic to close. Out of the DEPOSIT-001/002 5-AC slice scope.

Process note: kept the SPEC (docs/spec/deposit-slice.md) current through rev4 as each of these surfaced — the dev↔tester de-bias held (tester bound all 5 probes off the SPEC, never read code). Two tester misbindings caught before any false-green: AC-5 knob (MERCHANT_BEHAVIOR env, not ?behavior= query) and client-create auth (sub=client_id, not app_user stub-bearer).

tags: [next-dev, repo:mb-next-payment-gateway, next, deposit, wallet-ledger, migration, gotcha, decision, seed, adr-10, adr-19, adr-20, residual-mdr, auth, deposit-001, deposit-002, spec-first]
source: PR https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/311 HEAD 0d737d1 — supabase/migrations/20260603000003_adr20_deposit_slice_fixture.sql + 20260603000002 (finalize residual) + docs/spec/deposit-slice.md §5
project: github.com/kxlahsimx09/mb-next-payment-gateway

---
*Added via Oracle Learn*
