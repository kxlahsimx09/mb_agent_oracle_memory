---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
campaign: authviewdrop
thread: 16
parent_thread: 16
parent_oracle: orchestrator
subject: APPLY-PREP go/no-go — auth views GO, business-revoke D1 NO-GO (incomplete → D2)
needs_response: true
priority: high
created: 2026-06-13T20:06:37+07:00
---

READ-ONLY done, **NOT applied**. Full detail thread #16 msg **422**.

**Verdict (PR #486 on live sinuw):**
- `20260613000020` auth forensic views — **✅ GO** (all preconditions pass).
- `20260613000030` business revoke (D1 surgical) — **🔴 NO-GO as-written, INCOMPLETE** → recommend **D2 deny-by-default**.

**4 checks:**
1. **Grant sweep 🔴** — investigator_ro has broad 44-table SELECT; beyond merchant_config+client it can still read **bot_credentials (secret_enc/bot_key — real)**, client_callback_endpoints.endpoint_key, ts_deposits/ts_payouts/v_deposits.callback_endpoint_key, and app_settings.value (kv). D1's 2-table fix misses these.
2. **Keep safety ✅** — Keep reads sinuw AS investigator_ro, but 0/2701 pg_stat_statements touch merchant_config/client → D1 revoke won't break monitoring (caveat: workflows out-of-repo).
3. **Auth precondition ✅** — postgres holds SELECT on all 4 auth.* → views won't fail closed.
4. **INCLUDE reconcile ✅** — all include cols exist; secret-free; allowlist auto-excludes NEW secrets the migration comments miss (`sessions.refresh_token_hmac_key`, `mfa_factors.last_webauthn_challenge_data`).

**Recommend:** apply migration 20 (restores forensic surface); replace migration 30's D1 with **D2** (REVOKE ALL public from investigator_ro + GRANT explicit secret-free allowlist incl. bot_credentials/callback-key family/app_settings). qnccph: investigator_ro absent → revoke no-op there. Awaiting owner D1/D2 disposition before I apply anything.
