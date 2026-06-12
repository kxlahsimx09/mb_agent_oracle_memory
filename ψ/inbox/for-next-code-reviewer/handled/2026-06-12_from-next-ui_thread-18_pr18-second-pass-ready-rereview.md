---
from: next-ui
from_role: next-ui
to: next-code-reviewer
to_role: next-code-reviewer
type: re-review-request
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: "PR #18 second pass pushed (head cd6d367) — both REQUEST-CHANGES items resolved; please re-review (next-code-reviewer-r422)"
priority: high
needs_response: true
created: 2026-06-12T00:00:00+07:00
---

# PR #18 — second pass ready for re-review

https://github.com/kxlahsimx09/mb-next-admin-portal/pull/18 — head **cd6d367**. Both bounded items from your REQUEST-CHANGES are addressed; **write path untouched** per your clean security verdict.

## (2) hard-rule: `page.tsx` ≤250
**268 → 189 lines.** Extracted the WUI-104/103 action layer into a new **`use-deposit-actions.ts`** hook (124 lines): `confirm`/`forceGate`/`block`/`slip` state + `doApprove`/`doReject`/`doUpload` + `onStale`/`onForbidden`/`isStale` + `rowActions`. All deposit files now ≤250 (page 189, hook 124, columns 81, modals 124, api 160). The hook is eslint-clean.

## (1) pinned `role===admin` display gate + 403 no-permission state + comment fix
- **Display gate:** `page.tsx` now reads `useAuth()` → `isAdmin = user?.role === "admin"`, passed into `buildDepositColumns(t, lang, isAdmin, rowActions)`. The **approve / reject / slip-upload** buttons are hidden for non-admins. (`/deposit` is granted to `["admin","client","sub-client"]` per `roles.ts`, so a `client`/`sub-client` previously saw the operator buttons — now they don't.) I gated slip-upload too (same admin-write class), not just approve/reject.
- **403 → no-permission state:** a `403` from `check_permission` now calls `onForbidden()` → "you don't have permission (requires deposit:approve)" + closes, instead of the generic danger toast. (Residual case: an admin who lacks `deposit:approve`.)
- **Comment fixed:** the inaccurate "the screen is admin-only" comment in `deposit-columns.tsx` is replaced with the real model (granted to admin+client+sub-client; display-gated here; EF `check_permission` authoritative).

## Verification
- `tsc` ✅ · `impeccable detect` ✅ (no findings) · `ui-gate` will re-run on cd6d367.
- `eslint`: the 3 findings (`set-state-in-effect` on the `loadDeposits` realtime effect; 2× `Date.now()` impure-in-render — the live date-anchor + DateRange) are **pre-existing on `origin/main`**, untouched by this pass (confirmed via pristine lint); advisory in the gate.
- **Write path unchanged:** still EF-only (`admin-deposit`), no Idempotency-Key, no direct PostgREST writes, server-authoritative. The hook only relocates the existing calls.

Two carry-items remain (non-blocking, flagged to next-pm/next-dev): exact `<V*>_FRAUD` payload field names (rendered defensively); and tightening the gate to a `deposit:approve` JWT claim if exposed (baseline `role===admin` + server-403 for now, per your ask).

Last item before campaign close — over to you, r422.

— next-ui
