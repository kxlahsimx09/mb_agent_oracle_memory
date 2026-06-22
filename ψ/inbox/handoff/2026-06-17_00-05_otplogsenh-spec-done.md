## HANDOFF — campaign otplogsenh (next-architect) — DOCUMENTS ONLY, DONE

**Merged PR:** [#576](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/576) → `origin/main` `414cedc` (squash). Branch `arch/otplogsenh-ratify-spec` (deleted). **Only 4 files** landed (3 docs + 1 new SPEC); no code/migration touched (DOCUMENTS ONLY). Owner had already decided all 5 forks ⇒ no owner gate left ⇒ self-merged per brief.

### The 5 owner-resolved forks (FINAL, 2026-06-17) — all ratified append-only
| # | Fork | Decision | Build? |
|---|---|---|---|
| ① | `otp_logs` retention | **7 DAYS** (was 24h-post-expiry) — resolves §ADR-23 (c1) | **YES** |
| ② | `from_email` | **PORT** (reverse §ADR-23 P2 omission) | **YES** |
| ③ | method badges D/T/P/S | **DROP** (= shipped state; `bank_account_method` config → /system-bank, not the relay log) | no |
| ④ | parse-failure visibility | **SKIP** (= shipped; failures never land a row) — resolves §ADR-23 (c2) | no |
| ⑤ | §ADR-22 BENE-007 payout linkage | **ADVISORY (parity)** (enforced linkage NOT adopted) — resolves §ADR-22 (b1) | no |

✅ **③④⑤ ratified** (no-build, recorded). 🔒 **TEETH (§ADR-23 P2) UNCHANGED** — `v_otp_logs` never projects `otp_logs.otp`.

### ①+② BUILD SCOPE (for the next orchestrator-run build phase: next-dev → brew-ops → next-ui)
**SPEC = `docs/spec/otp-logs-retention-fromemail-enhancement-slice.md`** (full contract).
- **① retention:** new forward migration re-schedules pg_cron `purge-expired-otp-logs` DELETE interval `24h → 7 days` (orig at `20260614000010_bbot010_otp_relay.sql:322-333`; do NOT edit it in place). §ADR-6/BBOT-010-owned. Read gate unchanged. Split scheme (redact@24h+keep-metadata@7d) considered + NOT chosen (default = whole-row 7d; no owner re-confirm).
- **② from_email:** new forward migration — `ALTER TABLE otp_logs ADD COLUMN from_email text` + `save_bot_otp` overload `+ p_from_email text DEFAULT NULL` (SV8 REVOKE-from-public + GRANT service_role; NOT a view read-helper → off the execute_or_no_grants allowlist) + `bot-otp-log` EF pass-through + `CREATE OR REPLACE VIEW v_otp_logs` adding `o.from_email` after `o.source` (otp STILL absent) + portal UI column (WUI-212, cross-repo). pgTAP `v_otp_logs_read_surface_test.sql` re-run unchanged (TEETH + neg-matrix green) + extend.

### ② CROSS-REPO ANSWER (the critical scope question — RESOLVED)
**The next bank-bot (mb-next-bank-bot) does NOT relay email-source OTPs into the gateway today; it is the OTP CONSUMER, not the producer.**
- `core/otp_api.js::getOtpFromAPI` only READS `{otp,source}` via the bot-otp poll — never writes, never handles `from_email`.
- PRODUCER = out-of-tree `External:OTPService`; SIM = `sim/mock-portal/otp-service.js` posts `source:'sms'` ONLY (SMS-only).
- Email/IMAP producer write-path (`bot-otp-accounts` discovery) = **OR5-DEFERRED Phase-2** (not built). `core/otp_email.js` is the bot's own direct-IMAP login fallback (does NOT relay from_email to the gateway).
- ⇒ **from_email port = gateway + portal-UI scope ONLY; column NULL-for-now** (populates when the deferred email producer lands, Phase-2). **Bank-bot needs NO change.** Gateway substrate has NO from_email today (`otp_logs` / `save_bot_otp` / `bot-otp-log` EF all lack it).

### Files changed (PR #576)
- `docs/adr.md` — §ADR-23 §Amendment 2026-06-17 (①②③④⑤) · §ADR-6 §Revision 2026-06-17 (OR2 retention + OR4/OR5 from_email substrate) · §ADR-22 §Amendment 2026-06-17 (b1 advisory) · newest-first revision-log entry · P2 column-set (+from_email) · (c1)/(c2)/(b1) markers flipped to `[RESOLVED 2026-06-17:owner]`.
- `docs/requirements/epic-otp-relay-log.md` — OTPLOG-001/002 (+from_email) · OTPLOG-003 (retention 7d, S3→S2) · all open-decision markers RESOLVED.
- `docs/requirements/epic-beneficiary-bank-account.md` — BENE-007 → S2 advisory-ratified · markers cleared.
- `docs/spec/otp-logs-retention-fromemail-enhancement-slice.md` — **NEW** build SPEC.

### Notes for downstream
- Portal UI change (`from_email` column on /otp-logs, WUI-212) is **cross-repo** (mb-next-admin-portal) — handled by the portal writer/next-ui; the gateway contract (SPEC §2c) is what it binds to.
- Method-badge DROP (③) decision is recorded in §ADR-23 for the record; the portal writer should close any WUI-side badge open-question to match.
- Arra vector index is DEGRADED on this host (FTS5-only; `arra_search type=principle` returned 0) — onboarding rode AGENTS.md §3/§9 + the live ADR/migration/bank-bot source instead.

Done. next-architect stopping.