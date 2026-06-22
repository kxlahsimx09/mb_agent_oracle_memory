# Campaign `liverun` CLOSED — §ADR-21 LIVE journey 0-RED + DEPOSIT via real portal UI (PR #538 MERGED)

**Repo:** github.com/kxlahsimx09/mb-next-payment-gateway · **branch:** `campaign/liverun` → MERGED to `main` (merge commit `76300fe`, by owner kxlahsimx09, 2026-06-16 11:24Z). **Orchestrator:** liverun (this session). **Owner decision = Path B (ship now).**

## State (one line)
§ADR-21 LIVE journey driven to **43 GREEN / 8 AMBER / 0 RED** (6 epics auth/bbot/deposit/payout/mt/ktb, exit 0). **DEPOSIT admin actions walk the REAL admin-portal UI** (`via upload=ui/verify=ui`; approve=api = documented SIM V2 limit) — real-portal-UI video is the campaign headline. **Live-harness only — NO gateway/EF/portal/migration/spec change.**

## Done this campaign (next-live-tester @liverun, `poc/integration/src/live/**` only)
Phase-2 portal-UI framework (`admin-portal-payout.ts`, `admin-actions-payout.ts` UI-first/API-fallback router, `admin-portal-auth.ts` w/ "not connected to real system" banner detection, `debug-portal-admin-surfaces.ts`/`debug-portal-login.ts`); harness fixes (robust portal login `capture.ts clearSession()`+`admin-portal-ui.ts robustPortalLogin()` → made DEPOSIT II.3 fire via=ui; F-DEP-iii Keep poll-retry in `faults.ts`); 2 gated runs; per-AMBER owner table + Path-A contract in `next-live-tester_liverun_findings.md` (merged to ψ/memory/mailbox/next-live-tester/).

## HEADLINE BLOCKER (proven from portal source — mb-next-admin-portal on main)
The deployed admin portal wires ONLY DEPOSIT actions to the backend (`lib/deposits-api.ts efPost` is the sole write path). The other **15 of 18** human admin actions (PAYOUT cancel/correct/reconcile/reverse-settle/resend; AUTH-lifecycle set-role/disable/enable/unlock/change-pw; client-key rotate/revoke) are **mock/read-only by design** (`@/lib/mock`, toast-only; portal authors' own comment "wires when /users goes live"). UI-first is impossible for them without portal feature code (next-dev). **Not a SIM limit — a missing portal feature.**

## OUTSTANDING follow-ups (routed, awaiting owner greenlight — NONE block; journey already passes 0 RED)
- **next-dev (Path-A, big):** wire the 15 non-deposit admin actions in mb-next-admin-portal (`/payout`,`/users`,`/roles`,`/clients`) to existing EFs (`admin-payout-*`, AUTH-010/011/012, client-key) via the `deposits-api.efPost` template → the harness auto-flips api→ui (zero harness change). Contract in findings + PR #538 body.
- **next-dev:** F-PAY-iii — should the gateway emit P2.16/P2.17 to Keep per MONITOR-003 for III.8/III.9 remedies? (Keep carries 0 P2.16/P2.17, P2.12=156.)
- **next-dev/L3:** I.1 enrolment (gotrue verify), II.3c-forged (SIM mock V13/V14 not populated).
- **brew-ops:** II.9b callback HMAC-verify needs `cloudflared` + `RECEIVER_BASE_URL=local`; K.1 KTB inbound-match poll-widen.
- **owner:** I.8 step-up = spec limit 7 `S` (§ADR-2 §S2 carve-out), UI-deferred — no action unless spec change.
- **Next gate:** next-investigator L3 recompute + owner L5 sign-off (PR #538 claims neither).

## Evidence (on main)
`poc/integration/evidence/live/{auth,bbot,deposit,payout,mt,ktb}/<reqId>/`. Real-DEPOSIT-UI video: `deposit/832e7c91-dcdc-4a7f-b178-edff18002b8e/video/`. Run #2 trace ids: AUTH `54881c83` · BBOT `663fb021` · DEP `832e7c91` · PAY `503e9fa0` · MT `96e5dcf8` · KTB `8cfe0725`.
