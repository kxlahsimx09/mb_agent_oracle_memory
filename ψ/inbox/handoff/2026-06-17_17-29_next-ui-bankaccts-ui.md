# next-ui — WUI-201..205 /bank-accounts UI built (pending BENE backend)

**Agent:** next-ui (slug `next-ui-bankaccts-ui`) · **Date:** 2026-06-17 GMT+7
**Repo:** `mb-next-admin-portal` · **PR:** #45 (`feat/wui-201-205-bank-accounts-ui` → main) — **DO NOT MERGE** (awaiting review)
**Scope:** UI LAYER ONLY (owner-scoped). Did NOT build the gateway substrate.

## What was built (per story)
The `/bank-accounts` UI for the client/partner **beneficiary bank-account registry**, replacing the scaffolded mock with a contract-wired surface that degrades gracefully against the not-yet-built backend.

- **WUI-201** Operator console — admin read-only list + status/owner_type/purpose/search filters + detail modal; cross-tenant via the leak-safe view; full `account_number` (parity, no mask).
- **WUI-202** Client/partner self-service register → `pending`; partner=settlement-only / client=topup+settlement (`allowedPurposes`); per-owner limit (client 5 / partner 3) surfaced; 2FA-if-enrolled = owner's OWN login TOTP (optional field, EF re-prompts on 4xx) — **NOT** step-up; **admin REFUSED at create** (no create button for admin tier; EF is the authority).
- **WUI-203** Admin approve / reject — pending-only; reject requires reason; no-done-on-4xx; terminal rows not re-decidable (EF guard).
- **WUI-204** Owner set-default — approved-only, 2FA-if-enrolled.
- **WUI-205** Edit / delete — owner own-pending; super_admin any (EF-authoritative bypass).

## Files (split by concern, each ≤250 lines)
- `src/lib/bank-accounts-api.ts` — read + 5 writes + `bankAccountAccess()` four-tier posture + `bankAccountError()` mapper.
- `src/app/(portal)/bank-accounts/page.tsx` — four-tier RBAC display, filters, loading/empty/load-error/deny states.
- `.../bank-account-columns.tsx`, `.../bank-account-form-modal.tsx`, `.../bank-account-action-modals.tsx`.
- `src/lib/i18n.ts` — `ba_*` keys (en + th).

## §ADR-22 contract names bound to
- **Read view:** `public.v_bank_accounts` (P3, `security_invoker`+RLS; mirrors `v_deposits`; serves both owner-self + admin cross-tenant; `account_number` FULL within RLS-visible rows — no column mask, parity).
- **Write EF:** `bank-account` (P2 action-dispatch `create|approve|reject|set-default|update|delete`, mirrors `admin-deposit` via `deposits-api.efPost()`), gated by the §ADR-22 P4 RBAC resource `bank-account` (`view/create/approve/update/delete/set-default`).
- **Row shape:** §ADR-22 P1 `beneficiary_bank_account` parity columns; `purpose[]` `{topup,settlement}` (OQ-1 — NOT the drifted mock `deposit|payout`); status `pending|approved|rejected`.

## Reality / honesty posture
- **§ADR-22 / BENE-001..006 are RATIFIED but UNBUILT.** Every data call **404s at runtime** until the substrate deploys (expected). The page degrades to a clean **unavailable / empty / deny** state — **confirmed it does NOT crash** (full `next build` passes; `/bank-accounts` prerenders as static; load-error panel reads "the beneficiary registry (BENE) backend is not deployed").
- **`/bank-accounts` STAYS in `PREVIEW_ROUTES`** (`src/lib/roles.ts` line 227 — untouched) — preview banner stays honest. Did NOT de-preview it (unlike /system-bank).
- **NOT live-smoked** (would 404 — no backend). Validated via gates + render-without-crash.

## Gates (all green on changed files)
- `tsc --noEmit` clean · `impeccable@2.3.2 detect` clean · `eslint` clean (no new debt) · `next build` passes.

## Goes LIVE only once
BENE-001..006 substrate (the `beneficiary_bank_account` table + RLS + the `bank-account` write EF + the `v_bank_accounts` leak-safe view + the `bank-account` RBAC seed) is **built + deployed**. THEN: de-preview `/bank-accounts` from `PREVIEW_ROUTES` (a future PR, like #44 did for /system-bank) + live-smoke.

## Open questions carried (owner, not guessed)
OQ-1 purpose enum resolved by parity to topup/settlement. OQ-2 (enforced payout linkage) MATERIAL `[ESCALATE_TO_HUMAN]` — registry stays advisory. OQ-3 admin create-on-behalf = no (UI surfaces no admin create). OQ-4 24h approval cooldown unverified (likely UI-tier, not built). OQ-5 single-approver.
