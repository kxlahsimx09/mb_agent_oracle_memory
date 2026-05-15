---
title: DEPOSIT-012 authored — admin manual resend-callback Phase-1 (thread #93 closed).
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic, epic-deposit, deposit-012, admin-resend-callback, callback-dispatcher, adr-9-amendment-2026-05-12, thread-93-closed, writer-flagged-unratified-surface-instance-3, production-grounded-promotion, s2-ratified, phase-1-ratified, 3-actor-matrix, append-not-destructive, 202-fire-and-forget]
created: 2026-05-12
source: docs/requirements/epic-deposit.md DEPOSIT-012 + docs/adr.md §ADR-9 §Amendment 2026-05-12 + arra_thread #93 + PR #76 + dpay MCP audit_trail 17,797 calls / 27 days
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DEPOSIT-012 authored — admin manual resend-callback Phase-1 (thread #93 closed).

DEPOSIT-012 authored — admin manual resend-callback Phase-1 (thread #93 closed).

## Story shape

Manual resend of a terminal deposit callback by client, sub-client, or admin. Story file: `docs/requirements/epic-deposit.md` DEPOSIT-012 (S2 ratified). Anchored to §ADR-9 §Amendment 2026-05-12 AM1-AM7 (PR #76, commit `20fc6ce`).

**Key invariants:**
- 2 endpoint paths: client-tier (`POST /clients/:id/deposits/:txnId/resend-callback` — client + sub-client JWT) and admin-tier (`POST /admin/deposits/:id/resend-callback` — admin JWT)
- 202 fire-and-forget for ALL tiers (no inline delivery wait)
- Append semantic per AM4: new `callback_queue` row + companion `callback_attempts` row with `triggered_by='manual_resend'` + actor triple per §ADR-13 amendment F2
- Status pre-condition: terminal-only (paid / expired / rejected) per AM5; race-guard 409 if `callback_queue` row in-flight for same `event_id`
- Layer-1 tenant scope check per §ADR-13 amendment F4 coordination-rule for non-admin paths
- RBAC: NEW `deposit:resend-callback` action under `deposit` resource (flat namespace per F3, split-for-granularity per D3)
- Customer NOT in the actor matrix — callbacks deliver to the client business, not the depositing customer; structurally distinct from DEPOSIT-004 slip-upload 4-actor matrix
- Symmetric payout-side endpoint exists (future PAYOUT epic)

## Workflow pattern lesson

**Writer-flagged unratified surface during user-story authoring is now durable architectural rule** — instance #3 reached today.

Three same-day instances (all 2026-05-12) all production-audit-grounded:

| Thread | Surface | Production signal | Architect decision |
|---|---|---|---|
| #91 | §ADR-4b D6 admin manual re-match | 0 successful matches / 27d | DEFER Phase-2 |
| #92 | §ADR-4d D8 verify-slip-now call shape | p50 ≈ 600ms / 88% < 2s | SYNC default Phase-1 |
| #93 | §ADR-9 admin resend-callback | 17,797 calls / 27d (~659/day) | PROMOTE Phase-1 |

**Common DNA:** writer surfaces an ambiguity or deferral during user-story authoring → opens arra_thread with production-audit evidence baked into the option matrix → architect runs the same dpay MCP queries + ratifies grounded in production reality. Pattern AM8 in §ADR-9 amendment 2026-05-12 names it explicitly.

**Self-discipline applied today:** the production-evidence-before-priority rule I learned in instance #2 (call-shape, framing-vs-production-latency) was applied here BEFORE opening thread #93 — I ran the audit_trail aggregate first and presented the 17,797-call evidence as the lede of the thread opening. That's why architect was able to ratify quickly with the same evidence base.

## §H3-Fix bundle (peripheral note)

Architect's amendment also bundled §H3-Fix: §ADR-4d D1 amendment H3 had `client:deposit:upload-slip` / `admin:deposit:upload-slip` prefix format (authored 2026-05-07 pre-F3-revise), corrected to flat `deposit:upload-slip` per F3 ratify 2026-05-08. No writer-side update needed in `epic-deposit.md` — the prefix-format strings only lived in ADR text, not in any story body.

## Story-completeness state post-pass

| Story | Status |
|---|---|
| DEPOSIT-001 → 005 | S2 ratified |
| DEPOSIT-006 | Removed (Phase-2) |
| DEPOSIT-007 / 008 / 012 | S2 ratified |

Phase-1 epic-deposit now has **8 S2-ratified stories** plus 1 deferred-Phase-2 record. Remaining gap-analysis candidates (per pre-author audit):
- DEPOSIT-009 (client cancel) — **0 production rows** in `cancelled` state; same risk pattern as DEPOSIT-006; verify-before-author
- DEPOSIT-010 (client status poll) — apilogs sample inadequate; needs better data source
- DEPOSIT-011 (refund flow) — 9 + 1 production calls; 2 `refunded` rows with `refund_reason` Thai text + `refunded_at` timestamp; rare but real; creates `direct_transfer` per §ADR-12 D1; ADR coverage absent — needs architect thread

## arra trace

- Thread #93 closed 2026-05-12 08:55 UTC
- Architect learning: `learning_2026-05-12_w1-amendment-ratify-adr-9-admin-resend-callback-phase-1-thread-93-closed`
- This learning: DEPOSIT-012 writer-side artifact + workflow pattern at instance #3

---
*Added via Oracle Learn*
