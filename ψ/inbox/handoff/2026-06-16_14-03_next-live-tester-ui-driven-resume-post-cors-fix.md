# Handoff — next-live-tester · §ADR-21 UI-driven admin actions (resume, post-CORS-fix · 2026-06-16)

**Repo:** github.com/kxlahsimx09/mb-next-payment-gateway · **branch:** `campaign/ii3c-forged` (PR #531, owner-merge pending)
**Stack:** sinuw staging (`sinuwgsqqyqzlpaavimf`) · slot `.secrets/slots/staging.env` · APPEND mode (never `LIVE_DEDICATED_STACK=1` on a shared/in-flight run).

## One-line state
The owner directive "human admin actions walk the REAL portal UI" is now **unblocked for DEPOSIT**: the
EF-CORS gap is fixed+deployed, and `debug-portal-deposit.ts` confirms **upload-slip ✓ and verify-now ✓
fire through the portal UI**; only **approve** falls back to API (a documented SIM V2 limit). Next is
extending the same pattern to PAYOUT + AUTH-lifecycle.

## What just closed (the CORS loop)
- Finding (mine): every `/functions/v1/*` EF lacked CORS → the portal's cross-origin browser fetch was blocked.
- Fix (next-dev **PR #534**: `_shared/cors.ts` + `withCors()` on 20 portal-facing EFs, origin echo from
  `PORTAL_ALLOWED_ORIGINS`) + deploy (brew-ops **PR #536**, sinuw 51/51 EFs ACTIVE, OPTIONS preflight verified).
- Re-run repro (`bun run src/live/debug-portal-deposit.ts`, ~1 min): `UPLOAD ✓ FIRED`, `VERIFY ✓ FIRED`,
  `APPROVE → 400 V2_FRAUD` (CORS ok now; V2 receiver-match needs the test-only `slip_receiver_proxy` the
  portal UI doesn't expose → harness falls back to the API approve, which passes the proxy. Honest SIM
  limit; resolved at M2 with real slip OCR).

## PR #531 (this work — ready, owner-merge pending)
Commits: II.3c forged-slip negative · II.9b callback_attempts column fix · admin-portal UI (I.2b real
browser login → in the AUTH video) + deposit UI-first/API-fallback framework (`admin-portal-ui.ts`,
`admin-portal-deposit.ts`, `admin-actions.ts` via="ui"|"api") · `debug-portal-deposit.ts` (the fast driver).
No gateway/EF change. tsc clean.

## NEXT (prioritized)
1. **(optional, confirms end-to-end)** One gated run `OWNER_GO_LIVE_ALL=1 LIVE_DEDICATED_STACK=1
   ./run-live-tri-epic.sh` on a DEDICATED stack → DEPOSIT II.3 should now read `via upload=ui/verify=ui/
   approve=api` (the UI-first code auto-picks up the CORS fix — no harness change). ~15 min.
2. **Phase 2 — extend UI-driven to the other ~15 audited human actions** (PAYOUT: cancel/correct/
   reconcile/reverse-settle; AUTH-lifecycle: set-role/disable/enable/unlock/step-up/change-pw; client-key
   rotate/revoke). Build each portal-page driver with the **`/portal-ui-debug`** skill (~1 min/iteration,
   NOT 15-min runs) using `debug-portal-deposit.ts` as the template; wire UI-first/API-fallback like
   `admin-actions.ts`. The audit (all 18 human-action-via-API spots, with portal pages) is in the PR #531 thread.
3. **Approve-via-UI decision (route to owner/next-dev):** approve can't pass V2 in SIM via UI (no proxy
   field). Options: (a) accept approve-via-API fallback (honest SIM limit, AMBER-flagged); (b) add a
   `slip_receiver_proxy` field to the portal approve modal for test/SIM mode (portal change); (c) leave it
   for M2 (real slip OCR makes V2 pass without a proxy).
4. **Residual AMBERs** from the gated runs (run3/5/6, 0 RED): AUTH I.1 enrolment / I.8 step-up (structural
   honest-limits, not env-fixable); F-DEP-iii / F-PAY-iii (KEEP_ALERTS_API set but **unreachable from the
   run host** — network/brew-ops, conditions MET); KTB K.1 inbound match didn't finalize in the poll
   window (widen poll or next-dev MATCH look).

## L3/L5 (not mine)
The gated dedicated runs produced full evidence sets (`evidence/live/{auth,bbot,deposit,payout,mt,ktb}/<reqId>/`,
incl. real admin-portal UI video). L3 raw-table recount (next-investigator) + L5 owner sign-off still pending.

## Hygiene / tools
- **NEVER** launch a `LIVE_DEDICATED_STACK=1` run while another is in flight (`pgrep -f journey-tri-epic`
  first) — the `reset_runtime_state()` wipe clobbers it (learned the hard way this session).
- Fast UI debugging: skill **`/portal-ui-debug [page]`** (+ project memory [[fast-debug-loop-ui]] /
  [[live-test-harness-context]]). Verify a UI click FIRED by reading DB state, not "no exception".
