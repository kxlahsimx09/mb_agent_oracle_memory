# Handoff — Client Read/Poll API gaps CLOSED + LIVE on staging (campaign family `capi*`)

**From:** orchestrator (this session, branch `agents/28-close-gap-client-api`). **Date:** 2026-06-19 GMT+7.
**Re:** the `featweb` client-API-gaps handoff (`ψ/inbox/handoff/2026-06-18_00-26_client-api-gaps-featweb.md`) — the READ/POLL leg. Driven end-to-end via the doc→build→verify→seal→review→merge→staging workflow-2 chain, all under the orchestrator's own `capi*` slug family.

## Outcome: 7 of the merchant-integration parity gaps BUILT + VERIFIED + MERGED + LIVE
All to **parity with current maxpay**, EF tier (NOT gated on the deferred CF gateway):
- **CLIREAD-001** deposit status poll (public-by-UUID, 0-lag lazy-expiry via `effective_status`, no write-on-read)
- **CLIREAD-002** payout status poll (public-by-UUID)
- **CLIREAD-003** deposit+payout get-by-id (API-key `X-Client-Id`, own scope, cross-tenant→404)
- **CLIREAD-004** list deposits/payouts (API-key, keyset cursor + parity filters, narrow-within-own-rows)
- **CLIREAD-005** client wallet balance (`available = balance − frozen`)
- **CLIREAD-006** bank-code list (project-what-exists on decoration fields)
- **CLIREAD-007** merchant self-cancel deposit (API-key path; composes DEPOSIT-010; `cancelled`≠`expired`; 403 cross-tenant / 404 unknown write-contract; single-row audit, idempotent re-cancel)

## The chain (campaigns, all reaped clean except staging in-flight)
1. **`capidoc`** (next-architect) → **§ADR-26 Client Read/Poll API Surface** + `docs/requirements/epic-client-read-api.md` (CLIREAD-001..007, S2 parity) — **PR #609 MERGED** (reviewer-gated self-merge; parity-documentation, no new product decision).
2. **`capibuild`** (next-dev) → 1 additive RPC migration (`20260619000100`, 9 SECURITY DEFINER RPCs) + 7 thin EFs + `_shared/cliread.ts` + client-doc GAP→LIVE flips. SPEC-first (`docs/spec/client-read-api.md`). dev-1 self-verify 62/62. **PR #610 MERGED** (squash `70cfa55d0`).
3. **`capideploy`** (brew-ops) → pre-merge deploy of `campaign/capibuild` to tester + seal stacks.
4. **`capitest`** (next-tester, code-blind off SPEC) → **58/58 PASS** from DB ground-truth.
5. **`capiseal`** (next-investigator, own seal stack) → **SEAL: 59/59 ground-truth checks, ZERO contradictions** at run-sha `c169acc` (= merged HEAD).
6. **`capireview`** (next-code-reviewer) → **APPROVE** (body header) — leak-safe, service_role-only SECURITY DEFINER grants, stable keyset cursor; 2 non-blocking follow-ups.
7. **`capipm`** (next-pm) → marked **CLIREAD-001..007 DONE** on build+review+seal evidence; **§ADR-21 LIVE gate ruled N/A** (read-only/non-money epic; precedent = bene/`bank-accounts`). **PR #611 (DONE-marking) is OWNER-GATED** (DO NOT auto-merge, per the MDRWRITE #606 convention).
8. **`capistaging`** (brew-ops) → **all 7 EFs + migration LIVE on staging sinuw** (every EF returns its in-app code, not platform-404).

## OPEN for owner / follow-ups (none blocking the gap-close)
- **PR #611** (DONE-marking docs) — awaits owner merge per convention.
- **2 non-blocking review follow-ups** (recorded in-epic): (1) composite `(client_id, created_at DESC, id DESC)` index for high-volume CLIREAD-004 deep pagination; (2) garbage non-UUID id → clean 400/404 instead of 500.
- **DEFERRED future-drivers (§ADR-26 CR7, NOT built — genuine owner product-decisions):** webhook retry depth 3→7 · slip multipart upload · gateway day-budget caps · merchant self-cancel **payout** (no-gap, neither system has it) · merchant self-serve callback resend · `/jwt`+`/hash` signing helpers (intentional-drop).

## Gotchas (durable)
- **Staging PUSH auto-trigger did NOT fire for #610** — the running `w2-watcher.sh` was doing mobiz regression orchestration, not the mb-next staging-deploy. Had to manually dispatch brew-ops (`capistaging`) for the targeted go-live. If staging is still 404 ~15min after a gateway main-merge, deploy it manually (targeted, not push-all).
- **§ADR-26 CR2 auth reconciliation (code-is-truth):** the deployed EF-tier client credential is **`X-Client-Id` only**; the `X-Signature` HMAC is verified at the DEFERRED CF Worker (GW1b) tier, so the reads ship with `X-Client-Id` today like `deposits-upload-slip` (the SPEC §0.3 records this).
- **`featweb` doc branch** was unpushed/local-only — pushed to `origin/campaign/featweb` for durable grounding.
