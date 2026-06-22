---
from: orchestrator (campaign o-business-gap-2)
to: [next-live-tester]
date: 2026-06-21T (GMT+7)
topic: LIVE test-cases to author for the 3 fixes shipped this campaign — GW-X-02 (deployed staging), GW-REC-01 / MATCH-004 (merged, not deployed), BOT-D-02 + BOT-F-07 (merged, not deployed)
status: code merged for all 3; GW-X-02 deployed+GREEN on staging (runnable now), GW-REC-01 + BOT-D-02 NOT deployed yet (author now, run after deploy). PROD owner-gated for all.
tags: [#repo:mb-next-payment-gateway, #repo:mb-next-bank-bot, #live-tester, #o-business-gap-2, #gw-x-02, #gw-rec-01, #match-004, #bot-d-02, #bot-f-07, #test-authoring, #handoff]
---

# Handoff → next-live-tester: author LIVE test-cases for the 3 o-business-gap-2 fixes

This campaign closed 3 parity gaps (code+docs merged). Author live test journeys for each.
**Owner constraint that shaped all bankbot work:** the bankbot↔portal contract (incl. the mock portal) stays == current — none of these fixes changed it. Keep your harness aligned to current contract.

**Deploy / runnability (read first):**
- **GW-X-02** — DEPLOYED to staging, verified GREEN 2026-06-21 11:39Z (KTB + all-3-SCB). **Runnable on staging NOW.** (Your J1–J4 journey was paused mid-campaign; it can resume.)
- **GW-REC-01 / MATCH-004** — merged, **NOT deployed anywhere**. Author now; run after a staging deploy lands (owner-gated).
- **BOT-D-02 / BOT-F-07** — merged, **NOT deployed**. Author now; run after deploy. (Reliability/fault-injection style — see notes.)

---

## 1) GW-X-02 — Withdrawal over-draw, Model-B reserve-at-claim
**Already has a journey spec:** `ψ/inbox/handoff/2026-06-21_13-25_livetest-gwx02-overdraw-journey.md` (J1–J4). This is the canonical source — resume it. Summary of what to prove (now runnable on staging):
- **Model:** `available = balance − reserved`. Claim **reserves**; settle is a **no-op**; fail/sweep/cancel **release** the reservation; a bot scrape **overwrites** `balance` + **resets** `reserved`.
- **J1–J4 over-draw cases:** concurrent/batch claims cannot exceed `available`; an attempt to over-draw against a stale or absent balance is **rejected** (fail-closed) and raises a `monitoring_alert` (`stale_balance`).
- **Freshness guard:** once `balance_updated_at` ages past the threshold (≈300s), claims on that account are rejected until a fresh bot push lands.
- **Bot-clock trust boundary (regression test):** `balance_updated_at = LEAST(scraped_at, app_now())` — a bot sending a **future** `scraped_at` must NOT be able to keep the guard "fresh" forever. Worth an explicit adversarial case.
- **Genuine-0:** an account scraped at a real 0 balance pushes `ok:true` (not a miss) → over-draw guard sees 0 headroom.
**Evidence:** gateway PR #682 (`ff216fe`, migration `20260621000900`), bankbot PR #35 (`403c2c9`); ADR §ADR-4a §Amendment 2026-06-21; spec `docs/spec/withdrawal-balance-reservation-slice.md` (AC-1..9); parity GW-X-02.

---

## 2) GW-REC-01 / MATCH-004 — Backend self-healing source-recovery parser
**Spec (your AC source):** `docs/spec/recovery-source-parser-slice.md` (11-row AC table) + req `docs/requirements/epic-statement-matching.md#match-004`. Code: gateway PR #696 (`18f31011`, migration `20260622000100`).
**What it does:** when the bot scraper landed an inbound credit row **without** `source_bank_code`, the gateway re-parses the raw statement `description` server-side, recovers source bank + account, persists them, recomputes the V1 `match_hash`, so the deposit auto-matches instead of stranding for manual settlement.

**Journey to author (end-to-end):** a real deposit whose statement description the bot parsed WITHOUT source fields → previously stranded unmatched → now auto-matches and credits the client. Concrete cases (from the spec AC):
- **Headline (AC1):** inbound SCB row, `description = "รับเงินจาก SCB x4440 …"`, `source_bank_code` arrives **empty** (the `รับเงินจาก`/`transaction_code=X1` verb the bot misses) → gateway recovers `SCB` + `x4440`, persists, recomputes hash → matches.
- **Common verb (AC2):** `"รับโอนจาก KBANK x3511 …"` empty source → recovers `KBANK`/`x3511`.
- **KTB uniform API (AC3):** description carries `…014-4102508550…` → prefix `014` → `SCB` + full account.
- **Unparseable (AC5):** description with no recognizable shape → recovery writes **nothing**, row left as-is, flows to the existing amount-only / review / retry-sweep path (NOT an error).
- **No-op when bot populated source** — recovery never overwrites a bot-supplied sender field.
- **Gap-fill not clobber** — recovers bank but does not overwrite an already-present account number.
- **IN-direction only** — `direction='out'` rows untouched.
- **Idempotent backfill** — `repair_missing_source_bank_code` run twice = same result (heals stranded historical rows); verify the satang/integer hash parity (integer baht `'6744700'`, fractional `'10050.00'`).
**Note:** gateway-side only; zero bankbot change. Run after the migration deploys to your stack.

---

## 3) BOT-D-02 + BOT-F-07 — SCB browser-recycle safety nets (bankbot)
**Code:** bankbot PR #38 (`6500c9a`), in `core/payout-batch.js` `runScbBatch`. Ports current's SCB recycle self-heal (the 2026-04-14 incident: a stuck `MuiDialog` popup burned 24 payouts / 70k baht on an unfixable DOM).
**What to prove (reliability / fault-injection style — harder to live-test, see note):**
- **Popup-stuck recycle (BOT-D-02):** during an SCB payout batch, when the page wedges (popup/`MuiDialog` stuck, `intercepts pointer events`), the bot marks the **remaining** batch items failed and **recycles the browser** — it does NOT keep burning the queue. After recycle, the next batch processes normally (self-heal).
- **Consecutive all-failed recycle:** N (=`MAX_FAILED_BATCHES_BEFORE_RECYCLE`, default 2) consecutive all-failed SCB batches → recycle.
- **Memory recycle (BOT-F-07):** after `MAX_ITEMS_BEFORE_RECYCLE` (default 20) items → recycle (long SCB day).
- **Negative (no false recycle):** a single non-stuck per-item error still just marks-failed-and-continues; the batch does NOT recycle.
- **Money-safety:** recycle never re-runs an already-transferred item (no double-transfer); the all-failed streak counter resets on a successful/`review` batch.
**Note for you:** this triggers on an induced wedged-session state. The unit tests inject the popup-stuck error at the bankModule boundary (no mock-portal change). For a LIVE test you'd need the SIM to produce/stub a stuck-popup state — **if you touch the mock portal to do this, keep it faithful to real SCB (owner hard-rule: contract incl. mock == current); bounce to the orchestrator if a contract change seems needed.** KTB path is unchanged; scope your scenario to SCB payout.

---

## Suggested order
Resume GW-X-02 J1–J4 first (runnable now). Author GW-REC-01 + BOT-D-02 cases now; flag the orchestrator when you need the staging deploys to run them. Report RED/GREEN per case as usual.
