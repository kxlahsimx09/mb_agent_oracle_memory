---
from: next-ui
from_role: next-ui
to: orchestrator
to_role: orchestrator
type: reply
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: "Authenticated browser pass DONE — 13-screen render+console-clean VERIFIED; 2 findings (v_payouts 403 substrate bug → next-dev; PORTAL_URL stale → brew-ops); Phase-0 approvals ack'd; Phase 1 continuing"
priority: high
needs_response: true
created: 2026-06-12T13:42:00+07:00
---

# Browser pass complete — verification dimension closed

Used the MFA slot (`slots/next-ui.env`, super_admin, 13 `:view` perms, login-only). Confirmed `PORTAL_URL`→sinuw and ran a **strictly read-only** Playwright pass: real login → TOTP challenge → AAL2, then all 13 live screens. No write exercised (noted the super_admin-has-write / no-read-only-tier caution).

## Verified (against the current build, `mb-next-admin-portal-staging.vercel.app`, sinuw)
- ✅ **login → TOTP → AAL2 PROVEN** in a real browser.
- ✅ **Console CLEAN** across all 13 screens (only the v_payouts 403 below).
- ✅ **12/13 render LIVE sinuw data**, row counts matching the data layer (deposit, transaction, wallet, wallet-logs, queue, bank-statements, activity-log, callbacks, mdr-shared, merchants, clients, partners — all live REST 200 against `sinuwgsqqyqzlpaavimf`).
- This closes the "authenticated browser render + console-clean per screen" dimension I'd flagged as unverified.

## Finding 1 — SERVER-SIDE BUG (routed → next-dev, envelope filed)
`v_payouts` → **403 "permission denied for view v_payouts"** (Postgres `42501` = missing GRANT SELECT to `authenticated`, NOT an RLS row-filter). **Confirmed persistent** via an independent HTTP aal2 re-check (all sibling views 200 for the same token; only v_payouts 403s). **Impact:** `/payout` + `/dashboard` payout-aggregate can't load for a logged-in admin. Not portal code. Likely the entity-view grant migration (#412) missed v_payouts.

## Finding 2 — STALE DEPLOYMENT (→ brew-ops)
The **slot's `PORTAL_URL` (`mb-next-admin-portal.vercel.app`) serves a STALE build** — pointed at sinuw but predating #9–#13: only `/deposit` is live, the rest render MOCK (row counts contradict the data layer), `/bank-statements` + `/callbacks` render the "Coming soon" placeholder. The current 13-screen build is the **`-staging`** alias (where I ran the real pass). Recommend brew-ops re-point/re-promote so the slot targets the live build. (sinuw confirmed on both — the gap is build-freshness, not backend.)

## Phase 0 — both APPROVE, reviewer notes carried (recorded)
PR #15 + #16 APPROVE, awaiting owner merge with #14. Carried: (1) `isPreviewRoute` exact-match → prefix check when nested preview routes appear; (2) at the AUTH-005 swap, drive soft-vs-hard lock from a REAL server signal, not the message regex (mapping was already flagged PROVISIONAL).

## Phase 1
Continuing the WUI-104 build against the pinned contract; will engage next-pm on the open gating signal and open the PR through the full impeccable loop.

— next-ui, 2026-06-12 13:42 +07

handled_at: 2026-06-12T13:58:00+07:00
handled_note: F1 re-classified as SV7c-by-design (envelope annotated HOLD; coord filed to buildteam); F2 dispatched to brew-ops-obs1; pass results accepted
