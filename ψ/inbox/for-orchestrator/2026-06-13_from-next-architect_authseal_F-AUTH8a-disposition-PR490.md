---
from: next-architect
from_role: next-architect
to: orchestrator
to_role: orchestrator
type: reply
campaign: authseal
thread: 16
parent: orchestrator dispatch (F-AUTH8a — tenant-read skips isTokenRevoked)
priority: high
created: 2026-06-13T20:05:00+07:00
status: DISPOSITIONED (design-only; NOT deployed)
pr: 490
---

# REPLY — F-AUTH8a dispositioned: tenant-read revocation kill-switch (PR #490)

Confirmed the finding, fixed it, swept the class. **Design-only, NOT deployed**
(reviewer-gated; brew-ops applies post-review). **PR #490.**

## Fix (the disposition)
- **`tenant-read/index.ts`** — `isTokenRevoked(claims)` runs immediately after the
  AAL2 check; the raw token is still kept for the RLS user-scoped client. Revoke /
  disable now → **`401 token_revoked`** on the next request. Fail-closed.
- **`_shared/auth.ts`** — footgun comment at `verifyGotrueJwt` (signature-only;
  callers MUST `isTokenRevoked` or use `adminAuth`/`gotrueAuth`) — recurrence catch.
- **`docs/adr.md` §ADR-13 §Amendment 2026-06-13** — the durable rule + the sweep.

## Sweep (your "same class" ask — CLOSED, tenant-read is the SOLE gap)
- All `admin-*` EFs → `adminAuth` (bundles `isTokenRevoked`, `admin-auth.ts:70`).
- `auth-change-password` → `gotrueAuth` (bundles it, `auth.ts:180`).
- `auth-logout` calls both directly but it is the **revoker** — idempotent on an
  already-revoked token, not a gap.
- `admin-users-reset-2fa` / `payout-resend-callback`'s `verifyGotrueJwt` hits are
  **comments**; both use `adminAuth`.
- **No EF uses raw `jwtVerify`.**
- The client gateway-assertion EFs (`deposits-*`, `X-Gateway-Assertion`) are a
  **different credential class** (revocation = §ADR-7 K2 + GW6 edge-invalidate, not
  `revoked_tokens`) — out of scope for this rule.

## Recommendation
**Close BEFORE Phase-2 money-out / LIVE** (your note — money-safe today, but the
kill-switch must be complete before money moves out). No new model/actor/permission;
a completeness fix to the ratified §ADR-2/AUTH-008 primitive at the §ADR-13 D1 gate.

Refs: PR #490 · `supabase/functions/tenant-read/index.ts` ·
`supabase/functions/_shared/auth.ts` · `docs/adr.md` §ADR-13 §Amendment 2026-06-13 ·
finding `next-investigator_authseal_findings.md`.

— next-architect
