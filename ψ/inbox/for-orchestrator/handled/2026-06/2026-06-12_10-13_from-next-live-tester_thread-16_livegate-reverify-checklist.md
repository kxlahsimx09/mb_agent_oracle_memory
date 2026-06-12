---
from: next-live-tester
from_role: next-live-tester
to: orchestrator
to_role: orchestrator-buildteam
type: report
thread: 16
parent_thread: 16
parent_oracle: orchestrator
subject: "LIVE-gate re-verify (§ADR-21) — 4/5 prereqs CLOSED/MOOT, only OWNER GO remains; THE money-run = #404 automatch (L3 PASS + AR6 PASS); fault(i) channel = bank-bot SIM (YES); legacy slip-journey = PARK; 1 gate-design decision owed (pin L2-iii alert)"
needs_response: true
priority: high
created: 2026-06-12T10:13:00+07:00
---

# LIVE-gate prereq re-verification — read/verify only, no run, no deploy

**Checklist doc:** `poc/integration/src/live/LIVE-GATE-CHECKLIST-adr21-2026-06-12.md` (campaign/livegate worktree). Full citations there; summary below.

## (a) The 5 original prereqs (handoff 2026-06-10_06-30) — re-verified

1. **AR6 review — ✅ CLOSED (PASS-with-leans).** next-tester filed it this morning (`…10-08…ar6-bbot-automatch-pass-with-leans.md`): methodology/coverage PASS-with-leans, channel-realism PASS, "template VALIDATED, no blocker against #404." Deposit-era Q1 (slip/admin shape) → MOOT; Q2 (verify-now determinism) → resolved cleaner by the re-scope.
2. **MOCK_BANK_URL unset — ✅ MOOT/SUPERSEDED.** Still absent from gateway `slots/staging.env` (count=0) + `REPLACE_ME` on `tester.env`, but irrelevant: SP1 deleted the fixture-post; SP3 redefines fault(i) at the SIM-portal layer; the harness resolves the portal via `PORTAL_BASE_URL`/`SIM_CONTROL_SECRET` (Secrets-Manager/`bankbot-ip.sh`), not `MOCK_BANK_URL`.
3. **fault(iii) alert artifact — ✅ CLOSED.** Cadence leg MOOT (retry-exhaust ≈2min, 121 dead_letter rows verified). Alert half: Keep LIVE on Fargate, P2.12+P2.16 E2E to Telegram (#408/#410), **KF3 close-out ratified PR #414** (owner-merged `7cf1d25`) — "alert fired" surface RESOLVED (re-smoke: run#1=1 page, run#2=0, storm-guarded).
4. **L3 sinuw creds — ✅ CLOSED + exercised.** `investigator.env` has `SINUW_RO_DB_URL`/`SINUW_RO_SUPABASE_URL` (role `investigator_ro`, RO+BYPASSRLS); next-investigator L3 verdict = **PASS** (independent raw-table recompute, AR2).
5. **OWNER GO — ⏳ OPEN, the last item.** All §ADR-21 amendments are owner-ratified; the automatch run was campaign-accepted (thread #13). The per-epic **L5 `live_signoff` ACCEPT** (G2 teeth) is the procedural GO still owed. (Dispatch: "owner GO in-session.")

## (b) Is fault(i) mock-bank push channel satisfied by the bank-bot SIM? — **YES**

Superseded + strictly more faithful. Real bot scrapes the live SIM portal (`https://18-136-227-108.sslip.io`, runbook lane-b); harness injects via `POST /sim/inject`. fault(i)/dup-credit proven GREEN-for-real (SP3 steady-state + SS6 crash-restart) and L3 dup-credit=0. The static `MOCK_BANK_URL` is irrelevant to this gate.

## (c) THE money-run journey + legacy disposition

- **THE money-run journey = the re-scoped statement-automatch harness** `journey-bbot-automatch.ts` (#404 @ `11608d1`, MERGED). M1-SIM (SP1 real-bot/sim-portal; SS1–SS8 split). Certified: per-leg GREEN · L3 PASS · SP3 crash-restart real · CR2 APPROVE · AR6 PASS.
- **Legacy deposit-slip journey** (`campaign/livetester-adr21@1bcf83c`, 8 files, never run, pre-AR6, no PR) = **PARK.** Superseded for the bank-bot epic; **still OWED for the DEPOSIT epic** as a separate journey carrying (a) the slip/admin-approve settlement path + (b) **L2-iii**. Keep the branch as the seed; re-scope onto #404's validated patterns + its own (lighter) AR6 later. **Do not run, do not merge as-is, do not delete. Does not block the bank-bot epic GO.**

## (d) Exact remaining list before OWNER GO

1. **D1 (gate-design, decide first) — pin L2-iii must-page alert.** AR6 **F-C1** (escalated to me): #404 carries fault(i)+SP6 but NOT L2-iii; the surface is proven (KF3/#414) but the *alert selection* is unpinned. Decide: **(a)** pin **P2.12** callback-dead-letter (`.alerts/workflows/callback-dead-letter-rate.yml`) + add an alert-fires leg to the bank-bot run; **or (b)** rule the KF3 surface epic-sufficient and carry full in-journey L2-iii on the owed DEPOSIT slip journey. Owner/architect call.
2. **D2 — OWNER GO (L5 ACCEPT).** The final teeth. (`live_signoff` table/`/live` renderer are deferred impl items — flag if you want the formal artifact built vs. owner-direction acceptance.)
3. **D3 (optional, non-blocking) — fresh clean re-run.** GW4 is fixed (`…gw4-fixed-witness-green.md`, #409 BS-2), so a re-run clears the #404 closing-run's honest **L1b client-wire RED**; resets state → new X-Request-Id → re-trigger L3.

**Run command (informational — I did NOT run):** `cd poc/integration && ./run-live-bbot.sh` (AWS targets; structural L0 gate; no OWNER_GO env flag — GO is procedural).

**Non-blocking polish (next reuse, AR6 leans):** F-C2 (callback-count in dup leg), F-C4 (SS6(6) describe-tasks frame), F-CR1 (retire http-only IP resolver / cleartext-downgrade). **Standing residual:** Keep workflows are Phase-1-ephemeral (re-sync on every task replacement or the L2-iii surface silently blinds).

## Blockers / asks
- **No hard blocker.** One **decision owed (D1)** before a "complete-L2" owner GO, plus the GO itself (D2). If you want L2-iii ruled epic-sufficient via the KF3 surface (option b), say so and the bank-bot epic is GO-ready on owner ACCEPT.
- Routing: D1 → owner + next-architect; the owed DEPOSIT slip journey → a future next-live-tester lane.

— next-live-tester, 2026-06-12 10:13 +07

handled_at: 2026-06-12T10:40:00+07:00
handled_by: orchestrator-buildteam-wt26 (thread 16; D1/D2 escalated to owner in-session)
