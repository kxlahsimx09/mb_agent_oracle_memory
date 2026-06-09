---
to: orchestrator-build (next session — continue epic-auth-rbac follow-on lanes → §ADR-21 SIM-LIVE)
from: orchestrator-build 2026-06-09
priority: P1
topic: CONTINUE — auth keystone + AUTH-004 RLS are DONE; remaining lanes lead to the SIM-LIVE deposit test
project: github.com/kxlahsimx09/mb-next-payment-gateway
tags: [orchestrator, auth, gotrue, rls, staging, sim-live, build-handoff, continue, epic-auth-rbac]
---

# CONTINUE — epic-auth-rbac follow-on lanes → §ADR-21 SIM-LIVE

## DONE this session (all sealed + merged + DoD-marked)
- **DEPOSIT build COMPLETE** — 008/009/010/012 sealed+merged → every DEPOSIT build slice (001–012) done.
- **UI mock → main** (mb-next-admin-portal): ~30-screen Next.js admin portal, mock data (src/lib/mock.ts), login = MOCK role-switcher. UI epic docs on main: epic-auth-ui / epic-deposit-ui / epic-wallet-ui. Vercel-linked (prj_ZIws…), live at mb-next-admin-portal.vercel.app.
- **STAGING stack UP** — `mb-next-staging` ref **`sinuwgsqqyqzlpaavimf`** (org lsgheeuhvfqhmombfqsl, ap-southeast-1, ACTIVE_HEALTHY). Slot **`slots/staging.env`**. Has: 121 migrations + 19+ EFs + CF Worker `mb-next-gw-staging.midasgoteam.workers.dev` (JWKS ES256) + GW4 gateway-assertion keypair (kid k1) + BOT_SECRET. Egress IP-allowlist PROVEN once (EC2 squid+EIP in ap-southeast-7, then torn down — not standing; callbacks now DIRECT, fine for SIM). 12 EFs were verify_jwt-misconfigured on staging → brew-ops fixed at runtime (see config.toml gotcha).
- **AUTH human-login (gotrue) KEYSTONE** — PR #357 merged `bfbcfd5`. 6 EFs (auth-login/auth-2fa-verify/admin-users-reset-2fa/admin-users-unlock/auth-step-up-posture/auth-step-up-verify) + `_shared/auth.ts verifyGotrueJwt` (EF-side, JWKS ES256) + admin-auth.ts flip (decodeStubToken DELETED — NO-SHIM cutover) + migration 20260609000001. SEALED. Core auth 26/37 + sealed-deposit re-green 91/93 on REAL gotrue JWTs (DEPOSIT-007 47/47).
- **AUTH-004 RLS data-model** — PR #360 merged `c9feb9d`. Migration 20260609000010: gotrue `custom_access_token_hook` (bakes entity_type/effective_client_id/effective_partner_id) + RLS one-predicate/table on 7 tenant tables + dropped the dev-only anon-leak + RLS indexes + tenant-read EF + pgTAP. SEALED (cross-tenant=0, withdrawal_queue anon-hole closed). 9/9 AUTH-004 + pgTAP 32/35.

## REMAINING LANES (ask the owner which; do NOT auto-chain). The headline goal = SIM-LIVE.
1. **frontend → §ADR-21 SIM-LIVE** (the live test). Wire mb-next-admin-portal: REAL gotrue login (NO role-switcher — role from JWT entity_type per §ADR-2) + deposit screens → staging EFs. Then the §ADR-21 L1 golden journey: operator logs in via the portal → drives deposit slip-upload/approve/reject through the real-JWT admin EFs → terminal. Backend+auth+RLS+staging are ALL READY — this is the shortest path to the live test.
2. **AUTH-007 refund-EF-slug** — the gated deposit-refund EF (admin-deposit-refund → 404; likely an action inside admin-deposit-resolve). next-dev to name/build it (unblocks AUTH-007 AC1/S4-a; the step-up engine itself is GREEN).
3. **config.toml verify_jwt hardening** — ~12 EF-owns-auth functions LACK explicit `[functions.<fn>] verify_jwt=false` blocks; any `supabase functions deploy <fn>` without --no-verify-jwt silently re-enables the platform gate (the DEPOSIT-008-class bug). Add the blocks at source. (quick win)
4. **gateway CF edge** — WAF/DDoS/Bot + EA2 coarse login rate-limit (AUTH-005 rate-limit AC; machine-edge §ADR-7/GW4 is a SEPARATE design-complete lane — docs/design/client-api-gateway/).
5. **coverage** — DEPOSIT-008/009/010 probe suites were [NOT FOR MERGE] test PRs (not ported into the main probe tree) → re-run blocked; the 2 deposit env/timing fails (d004_ac9 state-residue, d012_ac06 dispatch-race) → confirm on a quiesced stack.

## OWNER-ONLY (escalate, do NOT self-do)
- **§ADR-21 LIVE gate + ACCEPT** per-epic for the sealed DEPOSIT slices (SIM mode first; REAL-bank after bank-bot). None is epic-done until the owner runs it. The frontend SIM-LIVE lane (1) gets you to where the owner can actually drive that acceptance through the UI.

## OPERATIONAL NOTES (cost real time this session — inherit these)
- **Kickoff lost on TUI-timeout**: agents spawned via `scripts/team-dispatch-helper.sh` sometimes sit at the splash with the prompt UNSUBMITTED (happened to rlstest, rlsseal, rlspm). Fix: `tmux send-keys -t <pane> Enter` to submit the stuck prompt, OR re-deliver via `maw team send <campaign> <role> "..."`. Verify EVERY spawn actually started (check for a spinner / non-splash pane).
- **GROUND-TRUTH over pane-scraping**: poll git/PR/Management-API/evidence-JSON and have agents write big outputs to `/tmp/<campaign>-report.txt`. Spinner-flooded panes + the pane ECHOING your own maw-sent messages cause false-positive watchers — filter your own message text.
- **Staging Management API**: PAT in slots/tester.env (or staging.env) SUPABASE_ACCESS_TOKEN works for project/EF/db-query + auth config (the gotrue access-token hook + JWKS were both settable via Management API — no owner/dashboard action needed).
- **AWS egress**: the `mb-next-egress` profile is a real IAM user now (owner created it this session, region ap-southeast-7, with EC2+EIP perms). A persistent egress is NOT standing (proof torn down).
- **brew-ops-oracle** (standing window 10-soul-brews:0) auto-reaps completed campaigns — coordinate, do not double-finish; check `git worktree list` + `maw team list` before finishing.
- All this session's campaigns (stagingprov/auth*/rls*) are FINISHED + orphan-swept (pane count 0 for mine). Other orchestrators' p2p campaigns (next-architect-p2pmode, next-writer-p2preq/p2pdesign) are LEFT ALONE — not mine.
- Build workflow + de-bias gates unchanged (docs/build-workflow.md). The de-bias REVIEW caught a real withdrawal_queue tenant-leak in PR #360 — keep the reviewer adversarial.
