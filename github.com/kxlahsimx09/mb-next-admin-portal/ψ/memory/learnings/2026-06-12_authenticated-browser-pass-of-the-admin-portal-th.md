---
title: Authenticated browser pass of the admin portal (thread #18, 2026-06-12) — verifi
tags: []
created: 2026-06-12
source: thread #18 browser pass 2026-06-12 (slots/next-ui.env); Playwright + HTTP aal2 re-check; reviewer verdicts on PR #15/#16
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# Authenticated browser pass of the admin portal (thread #18, 2026-06-12) — verifi

Authenticated browser pass of the admin portal (thread #18, 2026-06-12) — verification dimension CLOSED, + 2 findings + 2 reviewer carry-forward notes.

METHOD: Playwright (chromium) + the MFA slot fleet-secrets/.../slots/next-ui.env (super_admin next-ui-admin@probe.local, 13 :view perms, login-only). TOTP computed in-script (RFC6238). Drove real login→TOTP-challenge→AAL2, then visited the 13 live screens; captured console + supabase response status + render markers. STRICTLY read-only (no writes; super_admin carries write perms — catalogue gap, no read-only tier — so a write would have been possible but none was exercised).

RESULTS (vs current build = https://mb-next-admin-portal-staging.vercel.app, sinuw): login→TOTP→AAL2 PROVEN; CONSOLE CLEAN across all 13 screens except the v_payouts 403 below; 12/13 render live sinuw data with row counts matching the data layer (deposit/transaction/wallet/wallet-logs/queue/bank-statements/activity-log/callbacks/mdr-shared/merchants/clients/partners all fire live REST 200 against sinuwgsqqyqzlpaavimf).

FINDING 1 (server-side substrate BUG, route next-dev/secres): v_payouts → 403 "permission denied for view v_payouts" (Postgres 42501 = missing GRANT SELECT to the `authenticated` role; NOT an RLS row-filter — that would be 200/0). Confirmed persistent via an independent HTTP aal2 re-check (v_deposits/wallet/v_merchants/withdrawal_queue/transactions all 200 for the same token; only v_payouts 403). Impact: /payout AND /dashboard (payout aggregation) cannot load for a logged-in admin. NOT portal code — the portal queries v_payouts correctly; the view is missing the grant the sibling views have.

FINDING 2 (stale deployment): the slot's PORTAL_URL = https://mb-next-admin-portal.vercel.app serves a STALE build — pointed at sinuw but predating #9–#13: only /deposit is live, the rest render MOCK data (row counts contradict the data layer), and /bank-statements + /callbacks render the "Coming soon" PlaceholderPage (catch-all). The CURRENT 13-screen build is the -staging alias. brew-ops should re-point/re-promote PORTAL_URL.

REVIEWER NOTES to carry forward (Phase 0 #15/#16 both APPROVE): (1) isPreviewRoute() is EXACT-match — switch to a prefix check when nested preview routes appear. (2) At the AUTH-005 contract swap, drive soft-vs-hard lock from a REAL signal (a server field), NOT the "in N min" message regex in auth-errors.ts — it's on the swap checklist (the mapping was already flagged PROVISIONAL).</pattern>
<parameter name="concepts">["next-ui","repo:mb-next-admin-portal","next","live-verification","browser-pass","gotcha","v_payouts","403","staging","reviewer-note","thread-18"]

---
*Added via Oracle Learn*
