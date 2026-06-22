# next-ui — /payout admin remedy actions wired

**Agent:** next-ui (slug `next-ui-payout-actions`) · **Repo:** kxlahsimx09/mb-next-admin-portal
**Branch:** `feat/wui-payout-actions` · **PR:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/40 (DO NOT MERGE — awaiting review)

## Mission outcome: COMPLETE
`/payout` (was read-only over `v_payouts_read`) now has per-row admin REMEDY actions wired through the proven `efPost()` Bearer-JWT front door. New `src/lib/payout-actions-api.ts`; columns/modal split (`payout-columns.tsx` 110, `payout-modals.tsx` 205) to stay ≤250 lines/file. Read path UNCHANGED (still `v_payouts_read`, NOT the zero-grant `v_payouts`).

## Per-action wired + proof status (ALL 5 wired + browser-proven)
| Action | EF | Wired | Step-up | RBAC tier (display-gate) | Proof (captured EF network) |
|---|---|---|---|---|---|
| Cancel | `admin-payout-cancel` | ✅ | **NO** | super-admin (`payout:cancel`) | fired → **404** payout_not_found, modal stayed open |
| Correct | `admin-payout-correct` | ✅ | **NO** | super-admin (`payout:approve`) | fired → **404**, modal stayed open |
| Reconcile | `admin-payout-reconcile` | ✅ | **NO** | super-admin (`payout:approve`) | fired → **404**, modal stayed open |
| Reverse-settle | `admin-payout-reverse-settle` | ✅ | **NO** | super-admin (`payout:approve`) | fired → **404**, modal stayed open |
| Resend-callback | `payout-resend-callback` | ✅ | **NO** | any admin tier (`payout:resend-callback`) | fired → **404**, modal stayed open |

## Step-up decision per action: NONE on all five (verified, not guessed)
Checked the gateway source of truth `mb-next-payment-gateway/supabase/functions/_shared/step-up.ts`: `STEP_UP_PURPOSES = {deposit_refund, direct_transfer_create, settlement_create, settlement_approve, pullout_config_write}` — **no payout purpose exists**, and **none of the 5 payout EF `index.ts` consume a step-up grant** (`admin-payout-correct` + `admin-payout-reverse-settle` explicitly document the §ADR-2 §S2 carve-out: admin payout actions are NOT step-up-gated; controls = JWT+aal2+IP+RBAC + single-atomic-txn + audit). So **no `guard()` call** on any payout action — adding one would be a correctness defect. Matches the existing `lib/step-up.ts` carve-out comment.

## Contract honored
confirm → loading → success / **no-done-on-4xx** (real EF error surfaced via toast, list left as-is, modal stays open on 4xx — DOM-verified). `reverse-settle` (irreversible money-out) gets a destructive red confirm + warning banner. Super-admin remedies display-gated on `isSuperAdmin` (`user?.role === "admin"` proxy); server stays authoritative.

## §ADR-21 harness alignment (IMPORTANT for liverun)
Row action `title=` attributes were ALIGNED to the harness's exact `PAYOUT_ACTION_TITLES` in `poc/integration/src/live/admin-portal-payout.ts`:
cancel `["ยกเลิก","Cancel"]` · reconcile `["กระทบยอด","Reconcile"]` · correct `["แก้ไข","Correct"]` · reverse-settle `["กลับรายการ","Reverse settle"]` · resend `["ส่งใหม่","Resend callback"]`. The harness isolates a row by `request_id` (search box, placeholder contains "Search"/"ค้นหา" ✅) → clicks `button[title="..."]` → confirms via `role="dialog"` button named `/^(ยืนยัน|Confirm|...)$/` ✅. The reason field is SEEDED with an honest editable default per action so confirm is never dead-blocked on a blank box (lets the harness flip the leg by clicking confirm without typing, while keeping the audit non-blank). So the harness's `uiCancel/uiReconcile/uiCorrect/uiReverseSettle/uiResendCallback` auto-flip with **NO harness change** once this deploys.

## Note to liverun
Once PR #40 merges + deploys, these payout legs flip **`via=api → via=ui`**: cancel · correct · reconcile · reverse-settle · resend-callback. `admin-portal-payout.ts` records `via:"ui"` for them automatically (same mechanism the deposit upload/verify legs used after EF-CORS fix).

## Validation method (sandbox chromium HAS egress to staging — confirmed)
Local prod build on :3000 (overrode shell PORT=47778) + Playwright via cached `chromium-1223` (playwright 1.61.0 wants 1228; used `executablePath` to the 1223 chrome). Real-form aal2 admin login (password → TOTP from `UI_ADMIN_TOTP_SECRET`, click "ยืนยัน" not Enter). `/payout` rendered 5 synthetic rows (intercepted `v_payouts_read` to inject one row per status so every eligible button surfaces) → drove each button → **captured the real `functions/v1/*` EF response status**. ⚠️ MONEY-OUT safety: every click targeted a synthetic/non-existent payout id → deterministic **404 payout_not_found**, mutating NOTHING (no real payout cancelled/reversed). Separately proved the REAL `v_payouts_read` read returns **200** (currently `[]` — 0 rows post harness wipe). Eligibility rendering verified visually: pending→cancel, review→correct+reconcile, failed→correct+resend, success→reverse-settle+resend, cancelled→resend.

## Tally
- Files: `src/lib/payout-actions-api.ts` (176), `payout-columns.tsx` (110), `payout-modals.tsx` (205), `page.tsx` (224). All ≤250.
- Gates: tsc=0, impeccable detect (changed)=0, eslint(3 new files)=0 new debt (the 3 `page.tsx` errors are the pre-existing set-state-in-effect/Date.now baseline, verbatim on main; eslint is advisory/continue-on-error).
- Cleanup: server stopped, `.env.local` removed, temp scripts in /tmp removed — worktree secret-free (`git status` shows only the 4 source files).

## Open risks / follow-ups
- The seeded default-reason approach is a deliberate UX+harness-compat choice. If owner wants reason to be MANDATORY-typed (no default), that would dead-block the harness confirm-without-typing path — flag before changing.
- Staging had 0 real payout rows at validation time (harness wipe), so a real-row eligible-status mutation was not exercised end-to-end; the controlled-rejection 404 path proves the full UI→efPost→EF chain + no-done-on-4xx, which is the leg-flip mechanism. A real-row 409-precondition pass will happen automatically on the next live-test journey run.
