# Handoff (reply) — Client Read/Poll API: §ADR-26 + epic-client-read-api.md AUTHORED + MERGED to main

**From:** next-architect (campaign `capidoc`).
**Re:** the `featweb` client-API-gaps handoff (`ψ/inbox/handoff/2026-06-18_00-26_client-api-gaps-featweb.md`) — the READ/POLL leg.
**Repo:** `github.com/kxlahsimx09/mb-next-payment-gateway`. **Status:** DONE — DOCUMENTS ONLY, MERGED to `main`.

## What shipped (the build-chain input)

- **§ADR-26 — Client Read/Poll API Surface** (next free number; appended to `docs/adr.md`, append-only P-001 — canonical block + Revision-log entry).
- **Requirements epic** `docs/requirements/epic-client-read-api.md` — story prefix **CLIREAD**, wired into `docs/requirements/README.md` (epic-index) + `docs/requirements/INDEX.md` (new "Client Read/Poll API (CLIREAD)" section). Trust **S2** (port-fidelity, P-004).

### Story IDs ↔ parity items (one per in-scope item 1–7; all S2)

| Story | Item | Current endpoint (parity target) | Auth class |
|---|---|---|---|
| **CLIREAD-001** | deposit status poll (public, by id) — `{txnId,status,amount,paidAmount?,paidAt?,expiresAt}`, lazy-expiry, 404 | `GET /deposit/status/:txnId` | **public, capability-by-UUID (no auth)** |
| **CLIREAD-002** | payout status poll (public, by id) — `{txnId,status,amount,failureReason?,bankTransactionId?}`, 404 | `GET /payout/status/:txnId` | **public, capability-by-UUID (no auth)** |
| **CLIREAD-003** | deposit + payout get-by-id (own) | `GET /deposit/:txnId`, `GET /payout/:txnId` | §ADR-7 API-key, own `client_id` |
| **CLIREAD-004** | list deposits/payouts (filters + pagination) | `GET /deposit`, `GET /payout` | §ADR-7 API-key, own `client_id` |
| **CLIREAD-005** | client wallet balance (`available = balance − frozen`) | `GET /client/balance` | §ADR-7 API-key, own wallet |
| **CLIREAD-006** | bank-code list (validate codes pre-submit) | `GET /client/bank/list/code` + `GET /client/banks` | §ADR-7 API-key |
| **CLIREAD-007** | merchant self-cancel deposit (API-key path) | `POST /deposit/:txnId/cancel` | §ADR-7 API-key, own `client_id` |

## The one architectural decision (§ADR-26 CR2 — within architect authority, recorded)

- **Public status polls (CLIREAD-001/002): capability-by-UUID, NO auth** — the deposit/payout id IS the capability, the shipped `deposits-qr` public-EF precedent; parity with the current public polls.
- **API-key own-reads + self-cancel (CLIREAD-003..007): §ADR-7 `X-Client-Id` + `X-Signature` HMAC at the EF tier**, tenant-scoped to the caller's own `client_id` via §ADR-2 RLS / `effective_client_id`; parity with `deposits-create` / `deposits-upload-slip`.
- **NOT gated on the CF edge gateway** — GW1b's custom domain is unprovisioned/DEFERRED, so these reads ship at the **EF tier TODAY** like the creates, and move behind GW1b when the domain lands (orthogonal infra, not a precondition).
- **Deposit-poll lazy-expiry (CR3)** = observable parity via the deployed `v_deposits.effective_status` 0-lag view (§ADR-4c Decision #10) — **no write-on-read**; the physical flip stays the expire sweep's.

## Composition (re-decides nothing)

§ADR-7 (machine-auth) + §ADR-2 (RLS / `effective_client_id`) + §ADR-11 (per-client rate-limit at ingress) + §ADR-9 (terminal taxonomy — incl. the `cancelled` ≠ `expired` divergence) + §ADR-4c (`effective_status`) + the §ADR-13/22/23/24 leak-safe read-view pattern (`v_deposits`/`v_payouts_read`) + **DEPOSIT-010** (the cancel semantics CLIREAD-007 composes: 409 `NOT_PENDING`/`SLIP_PRESENT`, idempotent re-cancel, `cancelled` terminal). CLIREAD-004 is **distinct from DEPOSIT-013** (the operator/portal gotrue-session read surface) — different auth tier + persona; same `v_deposits` basis reusable.

## Deferred future-drivers (CR7 — recorded, NOT build-storied; do not build these)

1. **Webhook retry depth 3→7** — deliberate-divergence weigh (regression #1), owner product decision.
2. **Slip upload multipart vs string-URL** — new behaviour (regression #2), owner decision.
3. **Gateway day-budget caps** — PoC limitation, gated on the CF gateway.
4. **Merchant self-cancel PAYOUT** — **no-gap** (current route commented out; neither system offers it) — SAME, no work.
5. **Merchant self-serve callback resend** — operator-only in both today; optional API-key path.
6. **`/jwt/create` + `/hash/verify`** — intentional-drop (client computes its own HMAC); no work.

## Merge

- **PR #609** → `https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/609` — base `main`, **MERGED (squash `8828699`)**.
- **Authority:** parity-documentation + a technical auth-model decision, **NO new product decision** → **reviewer-gated + self-merge** (the bene/§ADR-22-follow-up carve-out). An independent conformance + parity-fidelity review passed (wire shapes verified verbatim against `featweb` spec-diffs 02/03/04; no BLOCKERs; one MINOR fixed — CLIREAD-007 cross-tenant error code aligned to the DEPOSIT-010 403-cross-tenant / 404-unknown cancel contract).
- **No owner gate / no blocked decision** — items 1–7 were clean parity; nothing required a handoff for a new product decision.

## For the build chain (next-dev SPEC input)

Build off **fresh `origin/main`** (now carries §ADR-26 + CLIREAD-001..007). Architecture-only items left to design/impl (§ADR-26 §Scope boundary): exact EF/RPC/view DDL + param/field names + error tokens; the pagination **cursor mechanism**; whether CLIREAD-004 **extends `tenant-read` or adds a dedicated API-key read EF** (architect lean = dedicated API-key EF over `v_deposits`/`v_payouts_read`, leaving `tenant-read`'s session contract untouched); the **bank-catalogue substrate** (which table/view + which decoration columns exist — CR4 project-what-exists); the public-poll rate-limit posture; the pgTAP TEETH. The client-facing HTTP docs to flip GAP→LIVE live in `docs/api-client/{status,balance-banks}.md`.

— next-architect, campaign `capidoc`, 2026-06-19 GMT+7.
