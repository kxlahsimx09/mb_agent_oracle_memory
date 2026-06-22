# [for brew-ops] staging.env slot — add 3 env keys to close the livepass env-AMBERs

**From:** next-live-tester · **To:** brew-ops · **Date:** 2026-06-16 · **Stack:** `mb-next-staging` / sinuw (`sinuwgsqqyqzlpaavimf`)
**Slot:** `.secrets/slots/staging.env` (the tri-epic launcher's default `SLOT`; sources ONLY this file)
**Why:** the FINAL livepass gated run (`OWNER_GO_LIVE_ALL=1`, APPEND mode, 2026-06-15, base reqId `ddee9065`) landed **37 GREEN / 5 AMBER / 0 RED**. **3 of the 5 AMBERs are pure slot/env gaps** (not harness bugs, not gateway defects). Closing them lets the next gated run exercise the alert + OTP-producer lanes in-harness and gives L5 a fuller surface. The other 2 AMBERs (AUTH I.1 enrolment, I.8 step-up) are structural honest-limits — **not** env-fixable, leave them.

Audited the slot directly (key names only): `SUPABASE_URL`, `CF_WORKER_URL`, `MOCK_MERCHANT_URL`, `PORTAL_BASE_URL`, `SIM_CONTROL_SECRET`, `GATEWAY_ASSERTION_*`, `BOT_*` = all SET. The 3 below are the gaps.

---

## ASK 1 — KEEP alerts query creds (closes F-DEP-iii + F-PAY-iii)
**Both MISSING from `staging.env`:** `KEEP_ALERTS_API`, `KEEP_API_KEY`.
- Today the slot carries Keep **ECS deploy** config, but **no query endpoint**. So the harness cannot confirm a fired alert in-band.
- The must-page **conditions ARE met** on the run (F-DEP-iii: `dead_letter` fires, 3 attempts, last=500; F-PAY-iii: P2.16/P2.17 exercised via III.8/III.9) — they AMBER **only** because there is no in-harness Keep query endpoint; the physical `#mb-alerts-p2` Telegram page is the current owner L5 surface.
- **Add:**
  ```
  KEEP_ALERTS_API=<keep alerts query base URL>
  KEEP_API_KEY=<keep read API key>
  ```
- The harness already wires these (`KEEP` → `keep:{api,key}` passed into the deposit/payout acts). Once set, F-DEP-iii / F-PAY-iii can flip AMBER→GREEN in-harness.

## ASK 2 — OTP-producer creds (closes BBOT B.8) — **a name/model mismatch, not just "missing"**
`OTP_PRODUCER_ENC_KEY` + `OTP_PRODUCER_ENV` **are present** in `staging.env`, but `mint_otp_producer_credential` returns **null** → B.8 AMBER (`bot-driver.ts:145,152`).
Root-cause picture (verified against migration `20260614000010_bbot010_otp_relay.sql`):
- `OTP_PRODUCER_ENC_KEY` = the **at-rest `pgp_sym_encrypt` key** for the producer secret (line 184). For mint+verify to round-trip, this MUST equal the value the **deployed** OTP-producer EF runs with, and `OTP_PRODUCER_ENV` (`prod`|`sim`) MUST match that deploy's env.
- There is a sibling slot file **`staging-otp-sim-producer.env`** (NOT sourced by the tri-epic launcher) carrying an **already-minted** producer credential under **different key names**: `OTP_PRODUCER_KEY`, `OTP_PRODUCER_SECRET`, `OTP_PRODUCER_ENV`. The harness does **not** read those names — it reads `OTP_PRODUCER_ENC_KEY` and self-mints.
- **Decision needed (brew-ops + next-live-tester):** which model is intended?
  - **(a) self-mint (current harness path):** put the *correct* at-rest enc key in `OTP_PRODUCER_ENC_KEY` (matching the deployed EF) + set `OTP_PRODUCER_ENV` to the deploy's env. No harness change.
  - **(b) consume pre-minted creds:** have the launcher also source `staging-otp-sim-producer.env` AND a small harness change to use `OTP_PRODUCER_KEY`/`OTP_PRODUCER_SECRET` directly (skip the mint). Harness change = next-live-tester.
- Recommend **(a)** (least change) unless the producer secret is owner-held mint-once and cannot be re-minted — then **(b)**.

## ASK 3 — FRONTEND_URL (not an AMBER cause, but enables admin/client UI video)
`FRONTEND_URL` **MISSING**. With it unset, `ctx.frontendUrl=null` → the harness skips every real-browser admin/client UI `.shot()` (admin `/login`, `/admin/deposits/:id`, client `/deposit`); evidence is API-beat frames only, no admin-portal UI in the video.
- **Add:** `FRONTEND_URL=<deployed admin-portal staging URL>` (the Nextra/portal staging host). Confirm routes `/login` and `/admin/deposits/:id` still match the harness's assumed paths.

---

## Verify (per ask, after the slot edit)
- ASK 1 → re-run a gated DEPOSIT+PAYOUT (`OWNER_GO_LIVE_DEPOSIT=1 OWNER_GO_LIVE_PAYOUT=1`) and confirm F-DEP-iii / F-PAY-iii frames carry a Keep alert hit.
- ASK 2 → re-run BBOT (`OWNER_GO_LIVE_BBOT=1`); B.8 should show `otp-producer-mint` with a non-null `producer_key_prefix` and a 200 producer-plane write.
- ASK 3 → re-run AUTH or DEPOSIT; confirm `evidence/live/{auth,deposit}/<reqId>/` contains the admin UI `.png` shots + the UI page in `video/`.

## Scope / ownership
- ASK 1 + ASK 3 = pure slot adds (brew-ops). No harness/gateway change.
- ASK 2 = slot value fix (a) OR launcher-source + small harness change (b) — needs the model decision first.
- **Do NOT set `LIVE_DEDICATED_STACK=1`** on sinuw — it is a SHARED stack; the wipe is `DELETE … WHERE true` across all tenants. Keep APPEND mode.
- Harness never verdicts — these env adds only let it produce richer evidence; L3 (next-investigator) + L5 (owner) still own PASS/FAIL.
