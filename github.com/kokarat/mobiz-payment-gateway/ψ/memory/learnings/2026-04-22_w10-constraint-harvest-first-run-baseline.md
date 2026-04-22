---
title: W10 pass 2026-04-22 — 12 new constraint entries (first-run baseline)
tags:
  - technical-writer
  - repo:cross
  - current
  - constraint
  - workflow-10
  - first-run
  - baseline
source: docs/constraints.md @ cf1edb3 + bank-bot @ 098a400, W10 root trace 5918b1ef-d3ca-420f-b230-feb882bc0508
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-22
---

# W10 pass 2026-04-22 — 12 new constraint entries (first-run baseline)

First real run of workflow-10 (constraint-harvest) after the workflow
skeleton was authored on 2026-04-22 GMT+7. This pass initialized
`docs/constraints.md` and `docs/.constraints-cursor` (both absent at
start). Owned by `pg-writer-oracle` (technical-writer instance for
mobiz-payment-gateway); register intentionally covers both mobiz-payment-
gateway and bank-bot (see workflow-10 §Cross-repo scope).

## Delta

**New (12):** C-001 through C-012.

| ID | Theme | Source | One-line statement |
|---|---|---|---|
| C-001 | portal-auth | KTB portal | KTB session timer resets only on real Angular router URL-hash changes; REST-only idle dies silently at ~10-15 min. |
| C-002 | portal-ratelimit | SCB + KTB anti-automation | Bank portals flag sub-second clicks/keystrokes as bot; 800-2000 ms jittered delays required. |
| C-003 | portal-ui | SCB portal UI | SCB transfer-review page hides submit button below fold at viewports <1920×1080. |
| C-004 | portal-otp | SCB + KTB portals | Email-OTP reference code is rotated at the email-request click; pre-click ref does not match delivered OTP. |
| C-005 | portal-otp | SCB + KTB portals | Bank-imposed OTP TTL (SCB 5 min, KTB 3 min) bounds the retrieval window. |
| C-006 | portal-transaction | SCB dual-control | Transfer commits at approver-OTP step; post-commit response rendering is unreliable → post-OTP ambiguity is a first-class state. |
| C-007 | portal-ui | SCB approver UI | Success popup is same `.MuiDialog-root` container as error popup — selector must discriminate by test-id/text, not container. |
| C-008 | portal-ui | SCB + KTB portals | DOM selectors/aria-labels mutate between portal deployments without notice (observed: KTB username rename 2026-04-22). |
| C-009 | portal-transaction | SCB statement | SCB statement occasionally serves future-dated rows; consuming them corrupts per-direction cursors. |
| C-010 | portal-transaction | SCB maker | Transfer page retains stale recipients across failed batches; SCB merges them into next IBFT without explicit cleanup. |
| C-011 | portal-transaction | SCB statement | Statement description does not reliably carry originator-chosen reference (e.g., request_id); reconciliation must be multi-modal. |
| C-012 | currency-rounding | Thai bank statements | Timestamps use Asia/Bangkok local time with no timezone offset; `time.Parse` alone drops records. |

**Extended:** 0 (register was empty).
**Superseded:** 0.

## Traces

- Root: `5918b1ef-d3ca-420f-b230-feb882bc0508` (W10 constraint-harvest pass 2026-04-22 — first run)
- Children (one per NEW entry, linked via `parentTraceId` to root):
  - C-001: `80d246d8-65a5-4a0d-a60e-e20aec9e2ae6`
  - C-002: `1c09849f-7b3e-47d8-83da-c8c864ebb5e9`
  - C-003: `b8a5fa4d-3d23-43ca-9ff7-1701c99353ca`
  - C-004: `2ddf3268-c846-4ed1-b402-0fd9bbddd2d0`
  - C-005: `c00b2b05-5281-44c5-a17e-ab1fd87c0534`
  - C-006: `0aa1ec12-a694-4b22-9a27-8cfc9776fd58`
  - C-007: `31471420-0013-4463-910a-03c56cb49574`
  - C-008: `07a4f167-26c0-4da2-aad0-8ec302bb9406`
  - C-009: `54dda05f-7ed2-41ce-8016-34d486b25bcd`
  - C-010: `1d1766dd-7631-4be5-90cd-60e167255f1c`
  - C-011: `9d658866-20da-4efc-aac3-8b532eb0a478`
  - C-012: `0bfeffea-7138-4e1e-ae46-c84374ee6d0d`

No prior W10 root trace to chain backward from (first run).

## Themes covered this pass

`portal-auth, portal-ratelimit, portal-ui, portal-otp, portal-transaction, currency-rounding`.

Deferred to later W10 passes (per theme-wheel least-covered rotation):
`regulatory, partner-sla, data-sovereignty, scheduler-timing, network-tls,
credentials-storage, callback-webhook, queue-idempotency`, plus explicit
sweeps of `browser-playwright` (folded partially into C-002 + C-003 this
pass).

## Cross-repo note

This pass names several bank-bot-side learnings as evidence. The
bot-writer sibling does not maintain a parallel register (see W10 §Cross-
repo scope). Bot-side findings should continue flowing via normal
`arra_learn` with `#constraint` or portal-specific tags, which pg-writer's
next W10 Step 3 memory sweep will pick up.

## Cross-links

- `docs/current-system.md §Bank-bot` footer — added `**See also:** [Constraints register](constraints.md)`.
- `docs/migration-notes.md §Preamble` footer — **NOT added**: file does not
  exist yet. Flagged as a follow-up for the eventual migration-notes
  authoring session. This is the only Definition-of-Done line not fully
  met by this pass.

## First-run observations (for future W10 authors)

1. **12 entries is a lot for a single pass.** The workflow says "healthy
   register grows ~2–5 entries per run". First runs are different — they
   absorb months of accumulated portal-forcing evidence in one sitting.
   `docs/constraints.md` is now ~350 lines; still under the ~500-line
   split threshold.
2. **The `waiting_to_review` state is a surface**, not a constraint.
   Entries C-006 + C-011 are the constraints that made
   `waiting_to_review` necessary — that's the distinction to keep in mind
   on future passes when a drift note smells like a constraint. Our
   *reaction* is the state; the constraint is what forced it.
3. **Memory sweep alone would have missed C-008, C-009, C-010.** Pass B
   (git log) surfaced them via commit-body prose. Do not skip Pass B on
   maintenance runs even when memory coverage looks good.
4. **`AGENTS.md §9` is mostly internal discipline.** Of the seven safety
   rules, none crossed the "externally-imposed, punishes X" threshold in
   isolation. Skip §9 as a constraint source unless a specific rule cites
   an external enforcer.

Tags: technical-writer, repo:cross, current, constraint, workflow-10, first-run, baseline, 2026-04-22

---
*Added via W10 first-run baseline*
