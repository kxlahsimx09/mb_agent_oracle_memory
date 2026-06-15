## Handoff — #next gateway bot-otp relay (gate for realistic KTB OTP login)

**For:** next-architect / next-dev. **From:** brew-ops 2026-06-14. **Thread:** #19.

**Ask:** build the #next Supabase gateway OTP relay so the KTB staging SIM bot can do a REAL OTP login (owner directive). Design ratified in `mb-next-bank-bot/docs/flows/bot-otp-relay.md` (thread #39); handler exists only on #current mobiz (Go) — #next has no `bot-otp` EF.

**Build (gateway, mb-next-payment-gateway — payment-auth, de-bias workflow):**
- `bot-otp` EF (read): `GET /functions/v1/bot-otp/:acc/:ref`, X-Bot-Key/Signature auth, per-bank_account_id; returns latest unexpired `otp_logs` row or 404.
- `bot-otp-log` EF (write): OTPService producer path → insert otp_logs.
- `otp_logs` migration: `(acc_number, reference_code, otp, source, otp_expires_at, created_at)`, idx `(acc_number, otp_expires_at, reference_code)`, TTL 5min. **Architect rule needed:** single-use/consume-on-read vs expiry-only (replay).

**bank-bot side (brew-ops, in parallel, no gateway dep to author):** `core/api.js getOTP` impl + `sim/mock-portal/ktb-server.js` OTP-form rework + SIM-OTPService write + fidelity test vs a stub. **Live KTB realistic-OTP deploy is gated on the gateway EF.**

**Interim:** OTP-less SIM KTB bot deployed (service `mb-next-bankbot-ktb`, ECS `mb-next-bankbot`) for nav/scrape testing only — NOT the realistic target; reworked once the relay lands.

Plan: `~/.claude/plans/dynamic-beaming-sonnet.md`. Related: [[ktb-mock-portal-buildspec]], [[deploy-currency-initiative]].