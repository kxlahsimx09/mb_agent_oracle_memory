---
title: SCOPE RULING (thread #244, relayed to user via orchestrator) — Partner-INITIATED
tags: [system-architect, repo:mb-next-payment-gateway, next, settlement, source-flows, scope, decision, trade-off, partner, adr-12]
created: 2026-05-27
source: thread #244 ruling R2; dpay prod settlements/partners 2026-05-27; docs/requirements/epic-source-flows.md SETTLE-001
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# SCOPE RULING (thread #244, relayed to user via orchestrator) — Partner-INITIATED

SCOPE RULING (thread #244, relayed to user via orchestrator) — Partner-INITIATED settlement is DEFERRED to Phase-2; partner is NOT dropped as a settlement entity.

## Question
SETTLE-001 carried `[open question: whether partner-initiated settlement is Phase-1 — pending architect confirmation]`. Production `settlements`: entity_type client 2,859 / partner 140 (total 2,999).

## Production grounding (dpay MCP 2026-05-27, verify-not-assert)
- Partner settlements are genuinely **partner-initiated**, not admin-proxied: `created_by_type="partner"` (97/140 typed; 43 null are older pre-field records, same population), `created_by_username="ownner-mdr"` maps to a real partner account. Admin "Tiger" appears only as `approved_by_username` (approval, not creation).
- Partners have **NO machine API credentials** — the `partners` collection has only username/password (no `api_key`/`api_key_secret`, unlike `clients`). So partner settlement is a **human dashboard login → create → admin-approve** path.
- **Single active partner, negligible volume**: all 140 lifetime records (≈4.7%) come from ONE partner account ("Owner MDR").

## Ruling
Partner self-initiated settlement create is **Phase-2**. Phase-1 settlement = client-API (SETTLE-001) + admin create/review (SETTLE-002). Partner is NOT excluded: (a) partner stays a Phase-1 auth/identity/tenant entity (AUTH-001/003/004 unchanged); (b) the one active partner's settlements are served in Phase-1 via **admin-create** (SETTLE-002 with `entity_type=partner` permitted).

## Rationale
The partner caller is a THIRD shape the §ADR-12 D1 taxonomy does not model — a human dashboard caller (like admin, no Idempotency-Key) but tenant-scoped to its own partner id (like a client) AND admin-approval-gated. Building a self-service partner settlement surface (endpoint + UI + `settlement:create` on the partner role + self-scoped validation + partner wallet) is not justified for a single tenant / 140 lifetime records. Deferral carries zero architectural risk — the money-movement machinery (wallet freeze → withdrawal queue → bank-bot) is shared, so the Phase-2 partner path slots into existing rails. Mirrors the DTR-002 "deferred Phase-2, not dropped" pattern.

## No ADR amendment required
Deferring does not change the Phase-1 taxonomy; it records a deferred future row (SRCFLOW-001 AC#4 already anticipates "a new flow forces an explicit revision of the taxonomy"). This is a scope-sequencing ruling within architect authority, relayed to the user via #244.

## Epic-edit implication → next-writer follow-up (epic-source-flows.md)
- SETTLE-001 edge: replace the open-question marker with the ruling (partner self-create deferred Phase-2; Phase-1 partner settlement served via admin-create), cite the single-tenant/140/partner-dashboard+admin-approved/no-API-key grounding.
- SETTLE-002: note `entity_type=partner` permitted on admin-create so the one partner is served Phase-1.
- SRCFLOW-001: note the partner-dashboard caller as an explicit Phase-2 future row (do not add to the Phase-1 5-row taxonomy).
- Optional S4 do-not-lose note for the partner self-create path (DTR-002 style).
Foldable into the #243 sub-A doc-refresh (already touching epic-source-flows.md for B1/B2).

---
*Added via Oracle Learn*
