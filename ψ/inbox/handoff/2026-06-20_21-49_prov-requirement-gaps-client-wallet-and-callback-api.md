---
from: next-live-tester
to: [next-writer, next-pm]
date: 2026-06-20T21:49:00+07:00
topic: EPIC PROV requirement gaps surfaced by the live test — PROV-001 missing client-wallet AC + no callback-endpoint provisioning home
status: needs requirement authoring (next-writer) + lifecycle tracking (next-pm); blocks API-only self-seed
tags: [#repo:mb-next-payment-gateway, #requirements, #epic-prov, #handoff, #next-writer, #next-pm, #live-tester]
---

# Handoff → next-writer / next-pm: two EPIC PROV requirement gaps

## TL;DR
The owner wants the live-tester harness (and prod) to provision **only through APIs**, never raw DB seeds.
Chasing a live-test failure to its root, I found **two requirement-level gaps in EPIC PROV** (`docs/requirements/epic-entity-provisioning.md`) that currently FORCE direct-DB seeding:
1. **PROV-001 (client) has no "wallet is created" AC** — though **PROV-003 (partner) does**. So `provision_client` correctly builds to spec and creates **no wallet** → a client made via the API can't be credited or pay out (`client_wallet_missing`).
2. **No requirement owns callback-endpoint provisioning** — `deposits-create`/`payouts-create` REQUIRE an active `default` `client_callback_endpoints` row, but **no PROV story / no EF** manages it.

Both need a requirement decision before next-dev can close them. Until then, a client created purely via API is non-functional for money flows.

## How it surfaced (the chain)
- Owner directive: live test must self-seed via the real APIs (admin API for admin-created entities, client API for client-managed), avoiding direct DB. (Production feeds through APIs anyway.)
- Rerunning A/B/C/D post-#659 (campaign o-fix-live-red), B/C/D money lanes failed: `HTTP 404 {"error":"client_wallet_missing: 0117e000-0c11-4000-8000-0000000000f1"}` (the dedicated fleet client brew-ops hand-seeded into the DB — client row, **no wallet**).
- Traced into the build: `provision_client` (`supabase/migrations/20260617000010_prov001_provision_client.sql`) inserts **client + app_user only** — no wallet. `provision_partner` (`…20260618001010…:75`) DOES `INSERT INTO public.wallet ('partner', …, 0, true)`. `create_client_topup` (`…20260616000020…:191`) RAISES `client_wallet_missing` if the wallet is absent (it never creates one).
- Traced into the requirements: **PROV-001 ACs** (`epic-entity-provisioning.md:87-96`) — API key, enable-flags OFF, amount bands, merchant/pool/MDR assignment — **no wallet**. **PROV-003 AC** (`:158-161`) — *"When I create a partner, Then a wallet is created for it so revenue-share can accrue."* The asymmetry is in the spec, not just the code.

## GAP 1 — PROV-001 should create the client wallet (next-writer)
- **Ask:** amend **PROV-001** to add an AC mirroring PROV-003, e.g. *"Given I am an admin, When I create a client, Then a wallet is created for it (balance 0) so it can be credited and pay out."* Plus a revision-log entry (same pattern as the PROV-003 entry).
- **Why it's real beyond the test:** a production client enabled for payout that withdraws **before** its first deposit would also hit `client_wallet_missing` — the wallet is currently never created at provisioning. This is a latent prod gap, not a test artifact.
- **Downstream (next-dev, after the AC lands):** `provision_client` adds the wallet INSERT (one statement, mirror provision_partner) via a new `CREATE OR REPLACE` migration. Then `admin-clients-create` yields client + user + **wallet** atomically — the harness self-seeds via the API with no DB poke, exactly the owner's principle.

## GAP 2 — callback-endpoint provisioning has no home (next-writer + architect)
- **Ask:** decide where client callback-endpoint registration belongs and author it. `deposits-create`/`payouts-create` require an active `default` endpoint per flow (SSRF-snapshot at create, §ADR-9), but nothing provisions it via API — only direct `client_callback_endpoints` DB inserts (what fixture-cast does today).
- **Options to weigh:** (a) a new PROV story / extend PROV-001 (admin sets a client's default endpoints at/after create); (b) a client-self-serve endpoint-management API (client API tier); (c) accept an inline `callback_url` on deposits/payouts-create. Architect to rule on the home + tier.

## Not gaps (resolved — for the record, no action)
- **Client → pool assignment:** covered by **PROV-005 AC2** (`:212-215`, *"a client assigned to a pool → routing draws from the pool's banks"*, §ADR-8). Routing is by `client.pool_id` (set at create by provision_client; `entry_points` routes off the request's `pool_id`). The harness currently discovers a pool client via the `pool_members` table — that's a **harness-side mismatch with the §ADR-8 model**; the harness should query by `client.pool_id`. No requirement/API change needed (harness fix, next-live-tester).
- **Merchant / partner / MDR / pool / system-bank provisioning:** covered + built (PROV-002/003/004/005/006, PR #605).
- **Non-entity users (admin/cs/viewer):** auth-managed (gotrue admin); entity users are minted with their entity create (PROV-007/§ADR-2). Flag only, not a PROV gap.

## Interim (already filed, unblocks the test now)
brew-ops handoff `2026-06-20_21-17_fleet-client-missing-wallet-blocks-bcd.md` asks for a wallet row on the fleet client `0117e000-0c11-4000-8000-0000000000f1` to unblock B/C/D today. That's the band-aid; **GAP 1 is the real fix** (so no one ever hand-seeds a wallet-less client again).

## Evidence
- Requirements: `docs/requirements/epic-entity-provisioning.md` — PROV-001 `:78-108`, PROV-003 wallet AC `:158-161`, PROV-005 `:208-215`.
- Build: migrations `20260617000010_prov001_provision_client.sql` (no wallet) vs `20260618001010_prov003_provision_partner.sql:75` (wallet); `20260616000020_topup_forward_slice_rpcs.sql:191` (`client_wallet_missing`). EFs `admin-clients-create`, `admin-partners-create`.
- Live failure: rerun 2026-06-20 — B `evidence/live/bbot/live-bbot-1781960261885-1869ec72/`, D `…/bbot-fairrouter/live-bbot-1781963807894-d8b18aa1/` (FRP1 BLOCKED `client_wallet_missing`). Full run summary: handoff `…17-05_livetest-allrun-results-and-findings` + `…21-17_fleet-client-missing-wallet-blocks-bcd`.

**Bottom line:** the live test isn't asking for anything exotic — it wants to create a client through the API and have it work. EPIC PROV gives partners a wallet at create but not clients, and never specs callback-endpoint provisioning. Close those two and the harness (and prod) provision cleanly through APIs alone. Questions → next-live-tester.
