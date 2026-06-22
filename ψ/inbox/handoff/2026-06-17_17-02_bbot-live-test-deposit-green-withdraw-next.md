# Handoff — bbot LIVE test: deposit GREEN, withdraw is next (salvage #545)

**Role:** next-live-tester. **Date:** 2026-06-17. **Stack:** sinuw staging (`sinuwgsqqyqzlpaavimf`).

## Status
`journey-bbot-automatch` (epic bank-bot, **deposit/ขาฝาก only today**) now **PASSES**: full remote run
exit 0, deposit auto-match GREEN end-to-end (L1b/L1c/L1d/L1e/L2b), L3 SKIPPED (remote opt-in), L2a/L2c
AMBER but sound (dedup holds, P2.12 dead-letter alert fires). Harness RUNS+frames; never verdicts.

Run: `cd poc/integration && ./run-live-bbot.sh` (sources `../../.secrets/slots/staging.env`, BOT_MODE=remote,
~11 min, chromium capture). Worktree `.wt-4-olive3` is on branch `bbot/clean-slate-and-pool-pin` (fixes committed).
DB introspection (psql is IPv6-unreachable here): Supabase **Management API** `POST api.supabase.com/v1/projects/<ref>/database/query`
with `SUPABASE_ACCESS_TOKEN`; plain reads via PostgREST + `SUPABASE_SERVICE_ROLE_KEY`.

## What this session fixed (the clean-slate was broken on 3 layers)
A true §ADR-21 clean run needs all three; reset_runtime_state alone was NOT enough:
1. **DB reset v3** — old reset (last touched 2026-05-12) missed `bankbot_activity_log` (5,878 stale rows,
   no_delete trigger), `otp_logs`, `revoked_tokens`, `step_up_*`, `fleet_command_log`, + forward-slice tables.
   v3 clears them, KEEPS `audit_log`/`sys_clock`/`*_config`, and deletes only DEAD `bot_credentials` (keeps live
   so the deployed bot stays authenticated). Migration `20260617000040_reset_runtime_v3_full_runtime_wipe.sql`.
2. **Per-bank append-only sim portals** — each is a SEPARATE service (SCB EC2 i-0d96a92a…; KTB EC2 i-0d14cd9f…)
   the DB wipe can't reach. After a wipe the bot's gateway-side cursor (`app.js:92`) resets → standing bot
   re-ingests the portal's stale backlog. Fix: `POST /sim/reset` per portal; harness clears all before the wipe.
3. **Pool-correct deposit pinning** — deposit must land on the bank the bot scrapes (`4102508550`, in main_pool).
   The first-client-by-id was an olive-pool client whose SCB bank differs → L1d RED; a blanket deactivate emptied
   that pool → NO_BANK_AVAILABLE 503. Fix: pick a client IN the bot SCB account's pool + deactivate other banks
   in that pool; restore at teardown.

## PRs
- bank-bot **#19** (SCB portal `/sim/reset`) — MERGED + deployed.
- bank-bot **#21** (KTB portal `/sim/reset`) — OPEN.
- gateway **#559** (v3 migration + journey pool-fix + multi-portal clear) — MERGED.

## Brew-ops still owes (for KTB clean slate)
1. Merge #21 → deploy KTB portal: Actions `deploy`, `bank=ktb component=portal` (only when no LIVE run in flight).
2. Add **`KTB_PORTAL_BASE_URL`** to the slot (KTB EC2 endpoint, same `SIM_CONTROL_SECRET`). Until then harness logs
   `ktb_portal_reset_skipped` and old KTB statements re-ingest.

## ⚠️ #545 — already has the WITHDRAW lane; SALVAGE, don't rebuild
Gateway PR **#545** (`campaign/botscrape`, title "DEPOSIT+WITHDRAW PROVEN GREEN … DO NOT MERGE") is a
parallel/earlier effort. Its only code change is `journey-bbot-automatch.ts` (+214) and it CONTAINS the full
withdraw lane `leg("L4-withdraw-realbot")`: payout via real wire (`/payouts-create` + GW4 lever fallback) → the
DEPLOYED bot polls `claim_withdrawal_items` itself + transfers + scrapes the outbound debit (harness never calls
the OUT-lane RPCs) → reconcile. Also has its own deposit pool-routing (re-points client `pool_members` into the
SCB pool — DIFFERENT from #559 which selects an in-pool client) + single `/sim/reset`. Based off PRE-#559 main,
~100 evidence files, now CONFLICTING. **DO NOT MERGE.**
Disposition: (1) salvage the `L4-withdraw-realbot` block (+ wallet frozen/balance reader ~line 331) from
`origin/campaign/botscrape`, port onto current main reconciled to #559's `clientRow`/`scbPoolId`; (2) open a
clean withdraw-lane PR; (3) THEN close #545. Read its findings first: `next-live-tester_botscrape_findings.md`,
`next-live-tester_simreset_findings.md`. Lane needs BOT_MODE=remote + a `SKIP_WITHDRAW` gate.

## NEXT TASK
Add the withdrawal (ขาถอน) leg to journey-bbot-automatch (it's deposit-only today) by salvaging #545's L4 lane
onto main. OPEN DECISION to ask the owner at start: happy-path withdrawal first (create→settle→re-scrape→reconcile)
then layer failure/cancel/clawback/reversal — OR build the fuller act-payout III.1–III.11-style set in one go.
Read for faithful wiring: `act-payout.ts` / `act-payout-more.ts`, `entry-payout.ts`, `payout-db.ts`.

(Mirror of Claude Code memory `bbot-live-test-status-and-next.md` + `clean-slate-three-layers.md`.)
