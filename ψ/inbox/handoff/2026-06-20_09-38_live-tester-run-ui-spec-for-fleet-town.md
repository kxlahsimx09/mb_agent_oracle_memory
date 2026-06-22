---
from: next-live-tester
to: brew-ops
date: 2026-06-20T09:38:00+07:00
topic: Fleet Town "Live-Tester Run" panel — suite picker + per-suite option toggles (lock-by-agent)
status: spec/handoff — please build the UI; this doc is the complete suite + flag contract
tags: [#repo:cross, #fleet, #brew-ops, #handoff, #live-tester, #ui, #fleet-town, #staging, #lock]
---

# Handoff → brew-ops: a Fleet-Town run panel for the live-tester journeys

## Goal
A Fleet Town UI, **scoped to the live-tester agent** (only `next-live-tester`'s sprite shows it; a run
is attributed to / locked by THAT agent), that lets the tester:
1. **pick a SUITE** (one of the journeys below), and
2. **tick the OPTIONS** for that suite (skip-legs, counts, modes…),

then hit **Run** → the panel invokes the matching `run-live-*.sh` with the chosen env vars on the
staging host. No more hand-typed `ENV=1 ./run-live-foo.sh`.

## Lock — reuse what's already wired (your #137)
Every launcher ALREADY acquires your `staging-lock.sh` before it drives staging (payment-gateway
PR #637 — `acquire --agent next-live-tester … ; trap release EXIT`). So:
- The panel **does not** need to take the lock itself — launching the suite does it.
- BUT the panel **should read `staging-lock.sh status --json`** and: disable **Run** (show the holder)
  when HELD by someone else; show a 🔒 "you hold it" state during a run; expose the owner's
  Release/Disable you already built. Exit code `3` from the launch = "held by another" → surface it.
- `CAMPAIGN` (free-text, default `livetest`) flows into the lock's `--campaign` for the holder card.

## Run model / verdict (so the UI sets expectations)
The harness **RUNS + records evidence; it never declares PASS/FAIL** (§ADR-21) — next-investigator's L3
raw-table recount owns the verdict. Each leg emits GREEN/AMBER/RED/SKIPPED into `legs.json`. The UI
should present results as "ran + per-leg colour", **not** "passed". Evidence lands under
`poc/integration/evidence/live/<epic>/<X-Request-Id>/` (manifest.json + per-beat json + png + trace/video).

---

# The 5 SUITES (the picker)

All launchers live in `poc/integration/` and source the staging slot (`../../.secrets/slots/staging.env`).
Runtimes are rough, on the remote (Fargate) stack.

| Suite | Launcher | What it exercises | ~Runtime |
|---|---|---|---|
| **A — Tri-Epic** | `run-live-tri-epic.sh` | the full multi-tenant story: AUTH + BANK-BOT + DEPOSIT + PAYOUT + MT + KTB + system-bank ENFORCE. **Money run is OWNER-GATED.** | 5–20 min (per epics picked) |
| **B — Automatch** | `run-live-bbot.sh` | statement auto-match golden + deposit/payout coverage via the real deployed bot | ~15 min |
| **C — Restart** | `run-live-bbot-restart.sh` | bank-bot crash-restart dedup + orphaned-claim reconcile (the only suite that restarts the bot) | ~10–15 min |
| **D — Fair-router** | `run-live-bbot-fairrouter.sh` | multi-bank LRU distribution + per-login isolation across a fleet (+ cross-bank, callback-delivery) | ~10–25 min (claim mode) |
| **DEP — Deposit golden** | `run-live-deposit.sh` | standalone DEPOSIT+AUTH slip→finalize (OWNER-GATED) | ~5 min |

> Suite **A** and **DEP** require an explicit owner-GO env flag to do anything (see their options); with
> none set they DRY-VALIDATE (provision + stop, no money). Suites B/C/D run their legs directly (they are
> SIM money, idempotent, on synthetic accounts) — gate them in the UI by who can see the panel, not a flag.

---

# OPTIONS per suite (the UI controls)

Control types: **toggle** = checkbox (env=`1` when ticked, unset otherwise) · **number** = numeric input ·
**select** = dropdown · **text** = string input. "Default" = behaviour when the control is left untouched.

## Suite A — Tri-Epic (`run-live-tri-epic.sh`)

**Epic GO toggles** (tick = run that epic's money acts; none ticked = DRY-VALIDATE only):

| Control | Env | Type | Default | Meaning |
|---|---|---|---|---|
| Run ALL epics | `OWNER_GO_LIVE_ALL` | toggle | off | runs AUTH+BBOT+DEPOSIT+PAYOUT+MT+KTB + enforce |
| AUTH | `OWNER_GO_LIVE_AUTH` | toggle | off | ACT I (login/2FA/AAL2/RBAC/lockout/lifecycle) |
| BANK-BOT | `OWNER_GO_LIVE_BBOT` | toggle | off | ACT B (bot seam: binding/dedup/OTP/telemetry/rotate) |
| DEPOSIT | `OWNER_GO_LIVE_DEPOSIT` | toggle | off | ACT II (create→match→credit→MDR + faults) |
| PAYOUT | `OWNER_GO_LIVE_PAYOUT` | toggle | off | ACT III (freeze→claim→settle + reconcile/cancel/reverse) |
| Multi-tenant | `OWNER_GO_LIVE_MT` | toggle | off | ACT MT (sub-client + 2nd-client + concurrency) |
| KTB lane | `OWNER_GO_LIVE_KTB` | toggle | off | ACT KTB (second-bank dialect) |
| Enforce-only | `OWNER_GO_LIVE_ENFORCE` | toggle | off | LIGHT system-bank enforcement legs (II.E/III.E/III.E3) — NO money, no money-gate; safe to run anytime |

**A — common options:**

| Control | Env | Type | Default | Meaning |
|---|---|---|---|---|
| Dedicated-stack wipe | `LIVE_DEDICATED_STACK` | toggle | off | wipe transactions at START (clean slate; keeps config). OFF = append mode. ⚠ destructive to staging txn data — gate to dedicated runs |
| Receiver | `RECEIVER_BASE_URL` | select | deployed `mock-merchant` | `deployed` (default) or `local` (local mock-merchant + cloudflared tunnel) |
| Keep alerts confirm | `KEEP_ALERTS_API` (+`KEEP_API_KEY`) | text | unset | if set, confirms P2.12/P2.16/P2.17 alerts in-harness; else those faults are AMBER (page is the surface) |

> A's enforce legs (II.E/III.E/III.E3) also run automatically *inside* a DEPOSIT/PAYOUT money run; the
> `ENFORCE` toggle is for running JUST them with no money.

## Suite B — Automatch (`run-live-bbot.sh`)

**Leg include/exclude** (each tick = SKIP that leg; default = leg RUNS):

| Control (untick to skip) | Env | Leg | Tests |
|---|---|---|---|
| Multi-candidate park | `SKIP_PARK` | L1g | DEPOSIT-005 cross-client → review |
| Degenerate FIFO | `SKIP_DEGEN` | L1g2 | DEPOSIT-005 AC-2 same-client auto-pick-oldest |
| Deposit expiry | `SKIP_EXPIRE` | L1h | DEPOSIT-003 slip-less sweep |
| Deposit idempotency | `SKIP_DEP_IDEM` | L1m | CLIENT-001 / §ADR-11 |
| Client deposit-cancel | `SKIP_DEP_CANCEL` | L1j | DEPOSIT-010 (AAL2 gotrue + tenant scope) |
| MDR 2-profile fan-out | `SKIP_MDR` | L1n | WALLET-003/007 satang-exact |
| Callback signature | `SKIP_CBSIG` | L1i | CALLBACK-002 WC1/WC8/WC10 |
| Withdraw lane | `SKIP_WITHDRAW` | L4/L4b | outbound real-bot payout |
| Stale payout cancel | `SKIP_STALE` | L4f | PAYOUT-008 sweep |
| Maintenance cancel | `SKIP_MAINT` | L4m | PAYOUT-010 bank-maintenance sweep |
| Payout idempotency | `SKIP_PAY_IDEM` | L4k | CLIENT-001 / §ADR-11 |
| Dead-letter alert | `SKIP_DEADLETTER` | L2c | P2.12 must-page (~2 min; needs failing-callback) |

**B — tunables:**

| Control | Env | Type | Default | Meaning |
|---|---|---|---|---|
| Deposit count | `DEPOSIT_COUNT` | number | `3` | total deposits (anchor + batch). `1` → L1f batch SKIPPED |
| Withdraw count | `WITHDRAW_COUNT` | number | `3` | payouts in the SCB batch. `1` → single L4 lane instead of L4b batch |
| Withdraw amount | `WITHDRAW_AMOUNT` | number | random `1200–1799` | pin the payout amount (else auto, avoiding stale-collision set) |
| Rotate stretch | `ROTATE_STRETCH` | toggle | off | L3 mid-journey bot-credential rotate (opt-in; leaves bot on retiring key — coordinate) |
| Minimize admin view | `BBOT_MINIMIZE_CAST` | toggle | off | prune the staging admin view to the bbot cast (opt-in; deletes the olive/tri-epic cast — DO NOT run concurrent with Suite A) |
| Callback fail path | `CALLBACK_FAIL_PATH` | text | `/fail` | the always-500 route the dead-letter leg binds to |

## Suite C — Restart (`run-live-bbot-restart.sh`)

| Control (untick to skip) | Env | Leg | Tests |
|---|---|---|---|
| Crash-restart dedup | `SKIP_DUPFAULT` | L2a-dup-fault | SP3 restart → dup-credit=0 |
| Payout reconcile | `SKIP_RECONCILE` | P1+P2 | III.5 stuck-reconcile + amount-mismatch |

> C **needs the restart lever** `BOT_RESTART_CMD` (a brew-ops runbook command, e.g. `aws ecs stop-task …`)
> to be preset in the environment — without it the restart legs honest-SKIP. P1/P2 also need `remote`
> bot mode. Treat `BOT_RESTART_CMD` / `BBOT_SERVICE` / `BBOT_PAYOUT_SERVICE` as **environment presets**
> (below), not per-run user toggles.

## Suite D — Fair-router (`run-live-bbot-fairrouter.sh`)

| Control | Env | Type | Default | Meaning |
|---|---|---|---|---|
| Tx per lane | `FAIRROUTER_N` | number | `9` | deposits/payouts per lane (≥3; 9 = 3/account) |
| Claim mode | `FAIRROUTER_CLAIM` | select | `drive` | `drive` = harness claims (fast; rows sit 'claimed'); `observe` = wait for real bots' ~6-min metronome (full E2E, up to ~20 min) |
| Force settle | `FAIRROUTER_FORCE_SETTLE` | toggle | off | drive `mark_success` so the FRP3 payout.success-callback leg can assert in ~80s (instead of `observe`) |
| Cross-bank | `FAIRROUTER_CROSSBANK` | toggle | off | mixed pool = 3 SCB + 1 KTB (payout-only) → method-aware routing + FRX gate |
| Fund floor | `FAIRROUTER_FUND_FLOOR` | number | `0` | raise each fleet bank balance to ≥ floor (claim-budget gate); 0 = leave as brew-ops funded |
| No equalize | `FAIRROUTER_NO_EQUALIZE` | toggle | off | skip zeroing LRU counters (default zeroes them so spread is crisp) |
| Skip deposit lane | `SKIP_DEPOSIT` | toggle | off | run payout lane only |
| Skip payout lane | `SKIP_PAYOUT` | toggle | off | run deposit lane only |

> D **needs the 3-account fleet** (`scb-fleet.json`) up; absent/<3 ⇒ legs honest-SKIP (BLOCKED). KTB
> cross-bank needs `crossBank.ktbAccounts[]` in that file.

## Suite DEP — Deposit golden (`run-live-deposit.sh`)

| Control | Env | Type | Default | Meaning |
|---|---|---|---|---|
| Run (owner-GO) | `OWNER_GO_LIVE_DEPOSIT` | toggle | off | required to do anything (else DRY-VALIDATE) |
| Keep alerts confirm | `KEEP_ALERTS_API` (+`KEEP_API_KEY`) | text | unset | confirm the F-iii P2.12 alert in-harness |

---

# Environment wiring — PRESET by brew-ops, NOT user toggles

These come from the staging slot / fleet config / runbook and should be **fixed per environment** in the
panel backend (or read from the slot), never typed by the tester:

- **Slot secrets/URLs:** `SLOT`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_ANON_KEY`,
  `CF_WORKER_URL`, `PORTAL_BASE_URL`, `SIM_CONTROL_SECRET`, `SIM_USERNAME`, `SIM_PASSWORD`,
  `GATEWAY_ASSERTION_SIGNING_KEY`, `GATEWAY_ASSERTION_KID`, `BOT_CRED_ENC_KEY`, `MOCK_MERCHANT_URL`,
  `FRONTEND_URL`, `SCB_FLEET_FILE`, `KTB_PORTAL_BASE_URL`.
- **Levers (runbook commands):** `BOT_RESTART_CMD` (Suite C restart), `BOT_LOG_CMD` (bot log tail in
  evidence), `PORTAL_DESCRIBE_CMD` (portal-bounce guard), `BBOT_SERVICE` / `BBOT_PAYOUT_SERVICE` (ECS
  service names C restarts).
- **Mode:** `BOT_MODE` (`spawn`|`remote`; auto = `remote` when `PORTAL_BASE_URL` is set — gate runs are
  remote), `BOT_POLL_MS`. `LIVE_SMOKE=portal` = local-only smoke (NOT a gate run; don't expose as a
  normal option).

---

# How the panel launches a run (contract)

1. Resolve the suite → its `run-live-*.sh` (cwd `poc/integration`).
2. Build the env from the ticked options (toggles → `VAR=1`; numbers/text/selects → `VAR=<value>`;
   `RECEIVER_BASE_URL=local` only when "local" picked; selects like claim-mode pass the literal).
3. Exec the launcher **as `next-live-tester`** with that env. The launcher self-acquires the staging lock
   (so the run is attributed/locked to that agent + pane) and self-releases on exit.
4. Stream stdout (the launcher logs structured JSON beats) into the panel; on exit, surface the per-leg
   `legs.json` (GREEN/AMBER/RED/SKIPPED) + a link to the evidence dir.
5. Exit code: `0` = ran (read legs for colours), `2` = bad config/slot, `3` = staging lock held by
   another (show holder, offer the owner's seize/wait), other = harness error.

## Guardrails to bake in
- **Suite A `OWNER_GO_*` + Suite DEP** move real (SIM) money on the shared stack — keep them behind the
  live-tester-only visibility + the lock; show a confirm for `LIVE_DEDICATED_STACK` (it wipes txns).
- **One run at a time** — the lock enforces it; reflect HELD state and don't queue a second launch.
- **`BBOT_MINIMIZE_CAST` (B)** and a concurrent **Suite A** are mutually exclusive (it prunes A's cast) —
  warn if A ran recently.
- Default every toggle OFF and every number to the value above, so an untouched form = the canonical run.

Questions on any flag's exact semantics → ping next-live-tester. Source of truth for the suites/flags:
`poc/integration/src/live/README-{bbot,restart,fairrouter,tri-epic,deposit}-journey.md` (just reconciled
with the code, payment-gateway PR #649).
