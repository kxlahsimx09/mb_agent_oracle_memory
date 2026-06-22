---
from: next-live-tester
to: [next-investigator, brew-ops]
date: 2026-06-20T17:05:00+07:00
topic: LIVE all-journey run (A/B/C/D) on main 9c32aa8 — results + findings triage (3 RED, 11 AMBER)
status: reported — needs eyes; ownership tagged per finding (harness / fleet / investigator)
tags: [#repo:mb-next-payment-gateway, #live-tester, #handoff, #findings, #bbot, #fairrouter, #tri-epic]
---

# Handoff: LIVE all-journey run — results + what needs looking at

Ran every live-tester journey on the latest code, clean-slate, sequentially (staging lock serialized them).
The harness RUNS + records; **L3 owns PASS/FAIL** — below is the observed leg colour + evidence, not a verdict.

## Run context
- **Code:** main `9c32aa8` · **When:** 2026-06-20 09:09–09:56 UTC · **Flags:** `LIVE_DEDICATED_STACK=1` (wipe) on every run; **A** with `OWNER_GO_LIVE_ALL=1` (full money). **DEP skipped** (owner directive).
- Each launcher self-acquired the staging-env lock (#137) and released on exit.

## Result — 98 legs → 🟢 81 / 🟡 11 / 🔴 3 / ⚪ 3
| Journey | 🟢 | 🟡 | 🔴 | ⚪ | reqId / evidence dir |
|---|----|----|----|----|---|
| **A tri-epic** (59) | 49 | 8 | 2 | 0 | per-epic under `evidence/live/{auth,bbot,deposit,payout,mt,ktb}/<reqId>/` |
| **B automatch** (24) | 22 | 0 | 0 | 2 | `evidence/live/bbot/live-bbot-1781947114036-ff3051a9/` |
| **C restart** (6) | 6 | 0 | 0 | 0 | `evidence/live/bbot-restart/live-bbot-1781947838449-dcf878f6/` |
| **D fairrouter** (9) | 4 | 3 | 1 | 1 | `evidence/live/bbot-fairrouter/live-bbot-1781948280909-3ae19cfc/` |

A epic reqIds: AUTH `0a572887` · BBOT `f7917dc2` · DEP `651172ae` · PAY `663f5d59` · MT `e707c891` · KTB `0280a08c`.
A per-epic: AUTH 7🟢2🟡 · BBOT 7🟢 · DEPOSIT 16🟢3🟡2🔴 · PAYOUT 16🟢1🟡 · MT 2🟢1🟡 · KTB 1🟢1🟡.

---

# Findings to action (tagged by owner)

## F1 — [HARNESS · next-live-tester] tri-epic deposit faults RED — NOT a money bug
- **Legs:** `A · F-DEP-ii-callback-retry` (RED), `A · F-DEP-iii-dead-letter` (RED) — `evidence/live/deposit/651172ae…/`.
- **Seen:** both `leg errored: approve: expected 200, got 400 {"error":"V2_FRAUD … V2_PARTIAL_DATA … slip_receiver_last4":"", "deposit_promptpay_last4":""}`.
- **Cause:** the fault SETUP drives a deposit to `paid` via admin **approve**, but the approve hits the V2 receiver-match gate because it passes no `slip_receiver_proxy`/promptpay (empty last4 → `V2_PARTIAL_DATA`). The deposit never reaches paid, so the callback-retry / dead-letter fault can't run → the leg throws → RED.
- **Why we're confident the PRODUCT is fine:** the SAME dead-letter path is **GREEN in Journey B** (`L2c-deadletter-alert`: "P2.12 FIRED + Keep-confirmed", `evidence/live/bbot/…ff3051a9/`) — B reaches paid via the real bot auto-match, which doesn't go through the admin-approve V2 gate. So it's a tri-epic harness gap, not a money defect.
- **Fix:** in `poc/integration/src/live/faults.ts`, have the approve-to-paid setup supply `slip_receiver_proxy = deposit.promptpay_id` (same as `act-deposit.ts` II.3 does), or drive paid via the bot/feedStatement path. Then F-DEP-ii/iii will exercise the real callback-retry + dead-letter.

## F2 — [FLEET · brew-ops] fair-router account **scb3** under-performing this run
- **Legs (D, `evidence/live/bbot-fairrouter/…3ae19cfc/`):**
  - `FRD2-deposit-match-paid` AMBER — `paid 6/9` (the 3 stuck/expired are the scb3 slice).
  - `FRD2cb-deposit-callback-delivered` AMBER — scb1/scb2 callbacks `delivered+rcv`, **scb3 = `none`** (no deposit.paid fired → its deposits never settled).
  - `FRP1-payout-distribution` AMBER — `perAccount=[5,4,0]` → **scb3 routed 0** Mode-1 payouts.
- **Also:** `A · K.1-ktb-deposit-automatch` AMBER — routed-to-ktb=true but `status=pending` (KTB inbound scrape→match never completed).
- **Read:** scb1 lanes are perfect (B=22🟢, C=6🟢 all on scb1), so this is **per-account infra** — likely scb3's bot login / scrape (and the KTB inbound bot/portal) not fully live this run, not core logic.
- **Action:** check the scb3 bot task + its portal login on the shared multi-account portal, and the KTB inbound bot/portal. Confirm all 3 SCB bots + KTB are scraping.

## F3 — [INVESTIGATOR · next-investigator] fair-router isolation RED (correlated with F2)
- **Leg:** `D · FRD3-deposit-isolation` RED — `crossOk=false (matched-statement system_bank_id ≠ assigned account)`, `isolationOk=true`. See the FRD3 frame in `…3ae19cfc/`.
- **Read:** a matched statement's `system_bank_id` didn't equal the deposit's assigned account. This is a real correctness signal in the deposit fair-router lane, but it landed in the SAME run scb3 was partially failing (F2) — please confirm whether it's a genuine cross-account-match bug or fallout of scb3 not completing its matches. (Per-login `isolationOk=true`, so the leak is in the match→system_bank_id linkage, not the portal slice.)

## F4 — [INVESTIGATOR · lower] weigh-and-watch AMBERs
- `A · II.5-collision-park` AMBER — `credits d1=1/d2=0` (expect 0/0 refuse-to-guess). Note **B `L1g-multi-candidate-park` is GREEN** (both uncredited) — so likely a tri-epic timing/setup difference, but confirm the gateway didn't actually guess.
- `A · MT.2-second-client-lane-C2` AMBER — C2 deposit `paid=false/credits=0` (payout side success). The C2 slip deposit didn't reach paid (possibly the same V2-approve path as F1, or timing). MT.1 (SC1) is GREEN.
- `A · I.1-enrolment` AMBER — "enrolment signalled; fresh TOTP factor not verified."

## F5 — [INFO · by-design / honest-limit, no action]
- `A · I.8-step-up` AMBER — AUTH-007 has 0 deployed call-sites (Phase-2 deferred); EFs exercised, no false-green.
- `A · II.9b-callback-signed-replay` AMBER — full HMAC verify only in local-receiver mode (deployed-receiver = honest-limit).
- `A · II.3-slip-lane` AMBER — paid, but the approve step fell back to API (`upload=ui/verify=ui/approve=api`) → flag to harden the portal UI step.
- `A · F-PAY-iii-alerts` AMBER — `KEEP_ALERTS_API 200 but P2.16/P2.17 not found` (alerts not confirmed in Keep; the #mb-alerts-p2 page is the owner surface).
- `D · FRP3-payout-callback-delivered` SKIPPED — `CLAIM_MODE=drive` leaves rows `claimed` (never settle). Re-run with `FAIRROUTER_CLAIM=observe` or `FAIRROUTER_FORCE_SETTLE=1` to assert it.
- B skips: `L4-withdraw-realbot` (superseded by the L4b batch), `L3-rotate-stretch` (opt-in `ROTATE_STRETCH=1`).

---

# Confirmed solid (wins this run)
- **B `L4b-withdraw-batch` GREEN** — `payout.success callbacks 3/3` via ONE SCB batch → **fix #629 (callback_url→tunnel) works live** (was AMBER 0/3 before).
- **B `L2c-deadletter-alert` GREEN** — P2.12 dead_letter fired + **Keep-confirmed** (fingerprint `p2.12-0a828282…`).
- **C all 6 GREEN** — `BOT_RESTART_CMD` available; SP3 crash-restart dedup (dup-credit=0), III.5 stuck-reconcile, amount-mismatch never-auto-fail.
- **A enforce all GREEN** — II.E1–E5, III.E1/E2, and **III.E3 fair-router availability (ADR-30 AC-1)**; plus **III.11 whole-lane conservation** GREEN.
- A AUTH/BBOT/PAYOUT cores green; deposit golden (II.1/II.2-A/B) green.

# Evidence index
- Durable per-leg ledger: `poc/integration/evidence/live/<epic>/<reqId>/legs.json` (+ frame `*.json`/`*.png`). Dirs/reqIds in the tables above.
- Raw run logs (transient, this host): `/tmp/livetest-{A,B,C,D}-1781946557.log`.
- Per-test reference (what each leg means): `poc/integration/src/live/live-test-info.json`.

Questions on any leg → ping next-live-tester.
