---
title: ## next-dev GOTCHA + build record — bot-tier auth chain (BBOT-002/003/004, PRs #
tags: [next-dev, repo:mb-next-payment-gateway, next, bot-gateway-dispatch, edge-function, migration, auth, hmac, pgcrypto, search-path, gotcha, build, bbot-002, bbot-003, bbot-004]
created: 2026-06-11
source: PRs #398/#399/#400; dev-1 verification 2026-06-11
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## next-dev GOTCHA + build record — bot-tier auth chain (BBOT-002/003/004, PRs #

## next-dev GOTCHA + build record — bot-tier auth chain (BBOT-002/003/004, PRs #398/#399/#400)

**GOTCHA (substrate, will bite any pgcrypto-using migration):** on the Supabase stacks pgcrypto is installed in the `extensions` schema, NOT `public`. A PL/pgSQL function with the house-style `SET search_path = public` therefore CANNOT resolve `gen_random_bytes` / `hmac` / `pgp_sym_encrypt` / `pgp_sym_decrypt` — it errors 42883 at runtime even though `CREATE EXTENSION pgcrypto` ran in schema_floor. Fix: function-level `SET search_path = public, extensions`. (Checked: deployed `submit_statements_batch` is unaffected — it does not call pgcrypto; `gen_random_uuid()` is pg core, which is why DDL defaults work.) PostgREST requests are fine because the API's `extra_search_path` already includes `extensions` — the trap is exclusively SECURITY DEFINER functions that pin their own search_path.

**Build record (gateway side of the bank-bot lane, thread #13):**
- bot_credentials = row-per-slot two-slot (≤1 live active + ≤1 live retiring per account via partial unique index WHERE revoked_at IS NULL); secret pgp_sym-encrypted with an EF-held key (BOT_CRED_ENC_KEY env, passed per RPC call) — DB dump alone leaks nothing, EF env alone leaks nothing.
- verify_bot_request does the whole BK7 chain in SQL (key lookup both slots → WC3 window → HMAC → BK3 binding) so EVERY time read is app_now() — replay window + retire-expiry are virtual-clock drivable, zero EF-side wall clock. The EF (botKeyAuth) only parses headers + builds the canonical.
- Auth-before-body-400s pattern: read req.text() ONCE, JSON.parse from it, verify auth with whatever binding params parsed (nulls if garbage), THEN 400 — keeps 401/403 precedence while the signature covers exact raw bytes.
- Rotation needed NO verifier change: verify honors slot='retiring' until retire_at, so K1 overlap/expiry came free with the schema; rotate(overlap=0) is a clock-free way to self-verify the expiry path without mutating sys_clock on a shared stack.
- BK2 cutover = delete botAuth+BOT_SECRET and flip ALL FOUR bot EFs incl. the two Phase-2 ones (bot-balance/bot-queue-mark) — leaving them on the dead global secret would have kept the total-blast-radius surface alive.
- Residual: bot-queue-mark binding uses required_bank_account_id (Mode-2 only); withdrawal_queue has no claimed_by column for Mode-1 pool rows — Phase-2 bot-dispatch epic item, recorded in SPEC §6.

Source: PRs https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/398 /399 /400 @ dev/bbot002-botkey-auth 27efb7b; migrations 20260611000100 + 20260611000110; dev-1 live verification 2026-06-11.

---
*Added via Oracle Learn*
