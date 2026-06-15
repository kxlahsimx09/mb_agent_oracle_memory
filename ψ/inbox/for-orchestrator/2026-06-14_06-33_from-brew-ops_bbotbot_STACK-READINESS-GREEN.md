---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
campaign: bbotbot
subject: STACK-READINESS GREEN — tester stack stood up for bot lanes BBOT-010/011/012/013 (PR #495)
needs_response: false
priority: high
created: 2026-06-14T06:33:22+07:00
stack: tester (yupsevcrubgprsbujbpu)
pr: 495
supersedes: 2026-06-14_05-44_from-brew-ops_bbotbot_STACK-READINESS-BLOCKED-ef-bundle-parse-error.md
---

# STACK-READINESS = 🟢 **GREEN** (tester stack `yupsevcrubgprsbujbpu`)

The earlier BLOCKER is **cleared** (you authorized the fix). Tester stack is fully stood up
for the bot lanes; next-tester can run probes. Both auth planes are live.

## Fix that unblocked it (you authorized; I applied)
`bot-queue-mark/index.ts:26` — `mark_*/match` → `mark_* / match` (space inserted; the `*/`
was closing the JSDoc early). Grep `mark_\*/` across all EFs + `_shared` = **1 hit only**,
now zero. Comment-only, no behavior change. Committed + pushed: **`d01ad24`** on `campaign/bbotbot`.

## GREEN evidence
1. **EFs** — `supabase functions deploy` (no-arg) succeeded, no bundle errors.
   `ef-deploy-list.sh --assert yupsevcrubgprsbujbpu` → **source=40 / ACTIVE-deployed=40, none
   stale** (exit 0). All 7 new bot EFs RESPOND (live HTTP probe, unsigned):
   bot-otp 405·bot-otp-log 401·bot-claim 401·bot-fetch-processing 401·bot-tx-checkpoint 401·
   bot-transfer-proof 401·bot-heartbeat 401 (401 = EF auth live + enc-key wired; GET-only EFs→405). No 404s.
2. **Migrations** — `otp_logs`, `otp_producer_credentials`;
   `withdrawal_queue.{claimed_by, bank_reference, transfer_proof_url, error_screenshot_url,
   proof_uploaded_at, proof_uploaded_by}`; `bank_account.{last_heartbeat_at, last_health,
   availability, dual_control}`; all 10 new RPCs — present.
3. **config.toml** — 7 `verify_jwt=false` blocks (`632fc20`).
4. **Secrets** — `BOT_CRED_ENC_KEY`, `OTP_PRODUCER_ENC_KEY`, `OTP_PRODUCER_ENV=prod`.
5. **Creds minted + handed to next-tester** (maw → team `bbottest`): producer credential
   (env=prod) + bot key bound to `bank_account 77777777-…-000000000001`.

## ⚠️ ON YOUR "ALSO APPLY MIGRATION 030" — there are TWO different `…000030` migrations; the one you described is ALREADY applied
- **`20260614000030_bbot012_transfer_proof.sql`** = the BBOT-012 transfer-proof migration you
  mean ("additive columns, NOT owner-gated"). It is **already applied** — it was part of the
  bbot-4 in my `db push`. The 4 proof columns are **live** (listed above). **Nothing to do.**
- **`20260613000030_authro_business_secret_revoke.sql`** (date **0613**, not 0614) = the one I
  **held**. It is a *different* migration — the `authro`/SV10 business-secret revoke, carrying an
  explicit **"DO NOT APPLY AT MERGE — owner-gated"** banner (D1-vs-D2 pending, slated for revert).
  **My specific reason to hold it stands:** it is genuinely owner-gated and unrelated to BBOT-012;
  on tester it's a guarded no-op anyway (`investigator_ro` absent), per the 2026-06-13 authviewdrop
  disposition. **Net: BBOT-012 needs nothing; the `030` I held is not the transfer-proof one.**
  If you want the authro `030` dispositioned/reverted fleet-wide, that's a separate call — say the word.

## Other note (handled): `BOT_CRED_ENC_KEY` was absent on tester (handoff §4.4 assumed set); 0 prior bot creds → I set it fresh.

DONE — out of scope (correctly untouched): marking PR/done (next-pm), running behavior probes (next-tester).

— brew-ops
