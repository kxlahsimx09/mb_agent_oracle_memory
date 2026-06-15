# 2026-06-14 — from next-pm — BBOT-010 Bot OTP relay PROMOTED (campaign bbotp, Phase A step 2/2)

**Verdict:** ✅ DONE-WHEN met. Bot-OTP relay promoted from a Deferred-Phase-2 one-liner into a build-ready requirement story. Phase-B build team can bind off **BBOT-010**.

## Committed (append-only on architect design-pass)
- branch `campaign/bbotp`; commit **`0ba380e`** on top of architect **`2ffd53a`** (PR #494, both commits now on the PR). No rebase/amend/force.
- Files: `docs/requirements/epic-bank-bot-integration.md` (+71/−1) + new `next-pm_bbotp_findings.md`.

## BBOT-010 content (1:1 with architect handoff, README §6.2)
- **Read EF `bot-otp`** — `GET /:acc/:ref`; per-account §ADR-7 **BK7** bot key (`botKeyAuth`, query keys off the key's `bank_account_id` not the path arg); fidelity-binding `{success:true,data:{otp,source,reference_code,expires_at}}`; **404 `{success:false}` collapses expired vs never-posted** (info-leak hardening); 401 family + 403 `bot_account_mismatch` + 405.
- **Write EF `bot-otp-log`** — `POST`; **fleet-scoped `otpp_` producer credential** (§ADR-9 WC1/WC3/WC8 HMAC, NO per-account binding, distinct from bot key AND BBOT-007 sim-inject secret); `bank_code` required (UNIQUE(system_bank_code,account_number)); append-only, no Idempotency-Key, latest-wins; 401 producer / **no 403** / 404 `unknown_account`; ships in BOTH SIM+PROD (distinct cred rows).
- **`otp_logs`** — FK `bank_account_id`, **no `user_id`** (epic:36); `source` CHECK(sms|email|unknown); `otp_expires_at`; index `(bank_account_id, otp_expires_at DESC, reference_code, created_at DESC)`; TTL 5 min on **§ADR-20 T1 `app_now()`** (virtual-clock drivable); RLS-on-no-policy + REVOKE ALL (SV7b) + SECDEF execute-revoke (SV8).
- **OR2 expiry-only single-use** — idempotent non-consuming reads; consume-on-read REJECTED (breaks unmodified-bot reread/BBOT-006 + unrecoverable lost-OTP/§ADR-6 BF5); controls C1 per-account binding · C2 short TTL+bank backstop · C3 `reference_code` shadow-scoping · C4 optional `last_read_at`.
- **Deferred-table line-36 row** moved to active (struck + `→ BBOT-010`); story-shape table row added with **† trust caveat**.

## Trust posture (do not over-read)
- Pull-forward = **owner-GO'd** (orchestrator `bbot`, 2026-06-14, orchestrator-relayed). OR1/OR2/OR3 = **architect-authored, ratification-pending / reviewer-gated**. Story header `[S2 … reviewer-gated]`, NOT `[S2 ratified]`. §ADR-6 §Amendment (adr.md L2015–2031) still needs **next-code-reviewer confirm + owner merge**.
- Per authority-attribution rule: only the pull-forward is owner-attributed; OR specifics are not.

## Phase B (fires now)
- **next-dev:** migration (`otp_logs` + `otp_producer_credentials`) + `bot-otp`/`bot-otp-log` EFs + `_shared/otp-producer-auth.ts` + 24h `pg_cron`; open call `OTP_PRODUCER_ENC_KEY` (new) vs reuse `BOT_CRED_ENC_KEY` (pin in migration header). Build off README §8 + `docs/design/bot-otp-relay/schema.sql`.
- **next-tester:** virtual-clock expiry (app_now() advance → 404); ref-scoped vs `_` wildcard; 401/403 read binding + 401 producer; append-only dup collapse; cross-account read denial.
- **next-code-reviewer:** confirm OR1/OR2/OR3 → owner merges §ADR-6 §Amendment.
- **brew-ops:** bank-bot `getOTP` to §1.4 envelope + SIM OTPService sim-scoped producer cred.

## Out-of-scope (held)
- No EF/migration code · no architect ruling changed (none needed) · no build step marked done · not folded into `epic-bot-dispatch`; not a new epic.

Findings file: `next-pm_bbotp_findings.md` (worktree `mb-next-payment-gateway.wt-c-bbotp`).
