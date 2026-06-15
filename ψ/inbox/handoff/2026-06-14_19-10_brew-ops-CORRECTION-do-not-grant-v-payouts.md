＠brew-ops — ⛔ CORRECTION / RETRACTION of prior handoff (2026-06-14) · mb-next-admin-portal

This SUPERSEDES `ψ/inbox/handoff/2026-06-14_18-55_brew-ops-v-payouts-perms-and-prod-env.md` — **ISSUE 1 in that handoff was a MISDIAGNOSIS by next-ui. DO NOT act on it.**

## ⛔ DO NOT grant `v_payouts`
The prior handoff asked you to `GRANT SELECT ON v_payouts` / add RBAC to mirror `v_deposits`. **DO NOT.** `v_payouts` is the **zero-grant ENGINE view** — granting it to `authenticated` would expose **cross-tenant payout reads** to every authenticated user. The DB is already correct.

## Actual root cause: portal was reading the WRONG view
- DB is fine: **`v_payouts_read`** has `authenticated` grant + RBAC (migration **sv7c-P1**, deployed at wf7). ✅
- The payout read surface is intentionally **NOT symmetric** with deposits — owner settled this 2026-06-12: deposits = `v_deposits`, payouts = **`v_payouts_read`** (not `v_payouts`).
- next-ui's `payouts-api.ts` called `.from("v_payouts")` (the zero-grant engine view) → 42501 permission denied. I wrongly inferred symmetry and diagnosed a "grant gap." It was a portal bug.

## Fix (done, portal-side only)
`src/lib/payouts-api.ts`: `.from("v_payouts")` → `.from("v_payouts_read")` (+ corrected comment warning never to read the engine view). 1-line change, no DB action needed — `/payout` loads once the portal redeploys (DB already ready). PR in flight on repo next-ui (`fix/payout-view-name`).

## Still valid from the prior handoff
**ISSUE 2 (prod env) STANDS:** Production Vercel env for `mb-next-admin-portal` has empty `NEXT_PUBLIC_SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_ANON_KEY` (Preview/Dev have the real sinuw values). Set them before prod launch or `vercel deploy --prod` builds can't reach Supabase. (Prod not live yet, so not urgent.)

## Lesson logged (next-ui)
Verify the actual view/table name in the DB before diagnosing a permission error — do not assume read-surface names are symmetric across domains. `v_payouts` ≠ `v_payouts_read`.