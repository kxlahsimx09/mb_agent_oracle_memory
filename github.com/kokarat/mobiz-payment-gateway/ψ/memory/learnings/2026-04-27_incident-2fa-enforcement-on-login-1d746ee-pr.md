---
title: INCIDENT — 2FA enforcement on login (`1d746ee` PR #245) silently broke all 35 VA
tags: [tester, repo:mobiz-payment-gateway, current, login-break, 2fa, setup-infra, incident, w1-fifth-baseline, thread:48, generate-totp, totp, rfc6238]
created: 2026-04-27
source: integration-tests/helpers/setup-infra.sh + controllers/TwoFactorController.go + controllers/UserController.go @ 1d746ee (PR #245, 2026-04-26 23:15 GMT+7)
project: github.com/kokarat/mobiz-payment-gateway
---

# INCIDENT — 2FA enforcement on login (`1d746ee` PR #245) silently broke all 35 VA

INCIDENT — 2FA enforcement on login (`1d746ee` PR #245) silently broke all 35 VALID integration tests at once

tags: [tester, repo:mobiz-payment-gateway, current, login-break, 2fa, setup-infra, incident, w1-fifth-baseline, thread:48]
created: 2026-04-27

## What happened

Commit `1d746ee` (PR #245, 2026-04-26 23:15 GMT+7) enforced 2FA setup on login. For users without 2FA configured, `POST /api/v1/auth/login` now returns:

```json
{
  "requires_2fa_setup": true,
  "temp_token": "...",
  "data": { "qr_code_url": "...", "secret": "BASE32SECRET", "user": {...} }
}
```

instead of the prior direct-JWT response:

```json
{ "data": { "token": "JWT..." } }
```

The committed `setup_test_data()` in `setup-infra.sh` read `json_val "['data']['token']"`, which returned `None` after `1d746ee`. JWT_TOKEN was set to empty string. Every subsequent API call got HTTP 401 → all 35 VALID tests failed in 1-2s at Step 2 "Logging in".

Three nightly watcher runs (00:26, 02:26, 04:31 GMT+7, 2026-04-27) died with Claude auth 401 before diagnosis. No W1 PR was produced overnight.

## Fix (included in W1 fifth-baseline PR)

Two new files in `integration-tests/`:

**`helpers/generate-totp.js`** — RFC 6238 TOTP (SHA1, 30s step) from base32 secret:
```js
const counter = Math.floor(Date.now() / 1000 / 30);
const counterBuf = Buffer.alloc(8);
counterBuf.writeBigUInt64BE(BigInt(counter));
const key = base32Decode(secret);
const h = crypto.createHmac('sha1', key).update(counterBuf).digest();
// ... truncate to 6 digits
```

**`helpers/setup-infra.sh`** — added `login_user()` function:
1. Try `data.token` directly (for already-configured users at T+N logins)
2. If `requires_2fa_setup == "True"`: extract `data.secret` from response
3. Generate TOTP code: `node "$HELPERS_DIR/generate-totp.js" "$secret"`
4. Call `POST /api/v1/auth/2fa/verify` with `{code, temp_token}` → extract final JWT

**Replaced** the bare `curl` login block in `setup_test_data()` with `login_user "$ADMIN_USER" "$ADMIN_PASS"`.

## Key invariants to preserve

- `generate-totp.js` must use `writeBigUInt64BE` (not split into lo/hi) to correctly encode the 64-bit counter. Node.js Buffer supports `writeBigUInt64BE` since v10.4.
- `login_user()` relies on `2549308` (#318) — 2FA setup reuses stored secret. If a test admin account completes 2FA setup during `setup_test_data()`, subsequent `login_user()` calls for the same account will receive the same stable TOTP secret (not a new random one), making TOTP generation consistent within and across test runs.
- The test admin accounts are created fresh per test run but the 2FA secret persists in MongoDB. After the first run, the account already has 2FA configured → login returns `data.token` directly (branch 1). Only the first-ever login for a new account hits the `requires_2fa_setup` branch (branch 2).

## Coverage gap filed

No integration test exercises the 2FA endpoints as standalone contract assertions (wrong TOTP rejection, TOTP window boundary, already-configured direct-JWT path). Filed in `docs/test-coverage-gaps.md` at `1d746ee`.

## Thread #48 resolved

---
*Added via Oracle Learn*
