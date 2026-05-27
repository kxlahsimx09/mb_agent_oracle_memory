---
title: CORRECTED R2 RULING (thread #244, supersedes the earlier "defer" learning) — Par
tags: [system-architect, repo:mb-next-payment-gateway, next, settlement, source-flows, scope, decision, drift, partner, adr-12, provisional]
created: 2026-05-27
source: thread #244 addendum msg 1120 (orchestrator gist) + dpay prod 2026-05-27 + next-writer #243; supersedes learning_2026-05-27_scope-ruling-thread-244-relayed-to-user-via-orc
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# CORRECTED R2 RULING (thread #244, supersedes the earlier "defer" learning) — Par

CORRECTED R2 RULING (thread #244, supersedes the earlier "defer" learning) — Partner-initiated settlement IS Phase-1 / IN-SCOPE. The deferral was based on a wrong channel model; the orchestrator addendum (#244 msg 1120) + dpay corroboration corrected it.

## What flipped the ruling
My first ruling deferred partner-self settlement, reasoning it was an expensive "third caller-shape" (human dashboard, tenant-scoped, approval-gated) distinct from the client-API machine path. That model was WRONG.

Corrected production model (orchestrator gist https://gist.github.com/kxlahsimx09/cc38fe0fd44543b60a41994f1dbdb738 + next-writer #243 + dpay 2026-05-27): settlement-create is a SINGLE uniform endpoint `POST /api/v1/settlements/`, authenticated by **dashboard JWT + RBAC `settlement:create`**, with **NO API-Key/machine route**. Initiator matrix is uniform — **admin / client-self / sub-client / partner-self** — all the same path, differing only by `entity_type` + tenant-scope; **approve = admin-only**. dpay corroborates: partners have no `api_key` (so they MUST initiate via JWT/dashboard, the same path clients use), and `partners.balance` exists (partners hold balance → have a wallet).

So partner-self is NOT a separate shape — it's the same JWT+RBAC+tenant-scope create path with `entity_type=partner`.

## Corrected ruling: Partner-initiated settlement = Phase-1 (IN-SCOPE)
Marginal cost is ≈ zero because every primitive already ships Phase-1: partner login (AUTH-001), the `partner` role + RBAC `settlement:create` from the verbatim production catalogue (AUTH-003), partner tenant-scope (AUTH-004), settlement create + admin review (SETTLE-001/002). Excluding partner would require an EXTRA carve-out branch on a uniform endpoint — i.e. deferral is MORE work than inclusion. It's also live behavior (140 records, real account). §ADR-12 M2 already addressed partner-settlement semantics (the "partner-entity lookup skip" bug not-inherited), so partner settlement was already treated in-scope.

## One genuine dependency to surface
Partner-self settlement Phase-1 ⟹ **partner wallet must be Phase-1** (the `partners.balance` field confirms partners hold balance; settlement reserves from the initiator's wallet). If the WALLET epic currently models only client wallets, partner wallet needs in-scope too. Flag, not blocker.

## Channel/taxonomy consistency — escalates beyond a writer doc-edit
The current §ADR-12 D1 ratified taxonomy classifies settlement-create as a MACHINE/API-key caller with Idempotency-Key ("Settlement (API)"). Production reality is HUMAN dashboard JWT + RBAC, no API-Key, no Idempotency-Key (browser double-submit instead), admin-approval-gated. That's a change to the RATIFIED §ADR-12 D1 taxonomy, not a deferred detail — so the #243 writer channel-fix should cite a **§ADR-12 §Amendment** (architect-drafted), not unilaterally contradict the ADR (P-004). Recommend one §ADR-12 §Amendment folding: (a) settlement caller = human dashboard JWT + RBAC `settlement:create` {admin, client-self, sub-client, partner-self}; (b) no API-Key route, no Idempotency-Key (browser double-submit); (c) admin-only approve; (d) partner-self in-scope Phase-1. This is money-movement scope (who can move money out) → route as #provisional / RATIFICATION_PENDING through orchestrator→user, same as the #236 M1/M2 amendments. Offered to draft.

Note: the original SETTLE-001 "machine caller + Idempotency-Key" framing likely traces to mis-reading `learning_2026-04-19_sub-client-tenant-scoping-pr-235` — which is actually about `resolveEffectiveClientIDFromJWT` (a JWT/dashboard tenant resolver), supporting the dashboard model, not API-key.

AUTH-005 ruling UNCHANGED by this addendum.

---
*Added via Oracle Learn*
