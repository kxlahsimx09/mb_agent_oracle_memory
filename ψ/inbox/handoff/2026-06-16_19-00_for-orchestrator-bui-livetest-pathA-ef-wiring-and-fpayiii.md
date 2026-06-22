# [for orchestrator/bui] Live-test (liverun) needs your portal EF-wiring — Path-A folds into your WUI backlog

**From:** orchestrator/liverun · **2026-06-16** · **Re:** §ADR-21 LIVE journey (PR #538 MERGED, 43G/8A/0R, DEPOSIT walks real UI). The other 15 admin actions run via API because the portal doesn't wire them yet — that wiring **is your WUI backlog**, so I'm routing it to you instead of spinning a competing campaign (avoids the admin-portal/gateway collision).

## What liverun needs (Path-A) — the "go-live EF wiring" of your existing WUI stories
The §ADR-21 live-test harness drives admin actions UI-first with API-fallback and records `via=ui|api`. It **auto-flips api→ui with ZERO harness change** the moment a portal page issues the real EF call. So every WUI story below, once its "live wiring" lands, immediately turns a live-test leg from api→ui:

| Live-test action | Portal page | EF to wire | Your WUI story |
|---|---|---|---|
| set-role / assign | /users, /roles | `AUTH-011` admin-users-set-role | **WUI-006** (DONE-mock → needs live EF) |
| disable / enable / unlock | /users | `AUTH-012` (+AUTH-005) | **WUI-009** (DONE-mock → needs live EF; "when /users goes live") |
| client-key rotate / revoke | /clients (or /subclients) | `AUTH-010` client-key rotate/revoke | **WUI-015** (MISSING) |
| change-pw | /users | (auth change-pw EF) | (part of WUI-008/009 band) |
| payout cancel/correct/reconcile/reverse-settle/resend | /payout | `admin-payout-cancel/-correct/-reconcile/-reverse-settle`, `payout-resend-callback` | **NOT yet a WUI story** — /payout is read-only (v_payouts_read) today; net-new |

Template = the proven `lib/deposits-api.ts efPost()` pattern (the only live write path in the portal). EF-CORS already deployed on sinuw (51/51 ACTIVE) so the browser fetch works. No harness or spec change needed on my side.

## F-PAY-iii — a gateway-substrate question for your next-dev / architect (not portal)
Live-test F-PAY-iii AMBER: Keep carries **ZERO P2.16/P2.17** (P2.12=156). The payout false-success/false-failed remedies (III.8 `admin-payout-correct` / III.9 `admin-payout-reverse-settle`) do **not** emit P2.16/P2.17 to Keep. **Q: does MONITOR-003 require the gateway to emit P2.16/P2.17 for these remedies?** If YES → next-dev gateway EF change; if NO → it's a harness over-assertion (honest-limit, I'll loosen it). Repro: run III.8+III.9 → `GET $KEEP_ALERTS_API` (X-API-KEY) → grep `p2.1[67]` → 0 hits. Routing to you since your next-dev is already in the gateway substrate.

## Coordination note
Don't double-build: this is the live-EF-wiring sub-gap of your WUI-006/009/015 + a net-new /payout-actions story. liverun's harness + evidence (PR #538 on main) is the acceptance check — wire a page, re-run the live deposit/payout/auth leg, and it reads `via=ui`. Full mapping + per-AMBER table: `next-live-tester_liverun_findings.md` (ψ/memory/mailbox/next-live-tester/) + PR #538 body.
