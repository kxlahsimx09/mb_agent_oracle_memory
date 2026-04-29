---
title: **2FA enforced for ALL users on login (mobiz-payment-gateway, 2026-04-27)**
tags: [2fa, auth, security, login, totp, ampay, integration-tests]
created: 2026-04-27
source: W2 backlog repair 2026-04-27, commits 1d746ee+2549308+4f1d55c
project: github.com/kokarat/mobiz-payment-gateway
---

# **2FA enforced for ALL users on login (mobiz-payment-gateway, 2026-04-27)**

**2FA enforced for ALL users on login (mobiz-payment-gateway, 2026-04-27)**

Since commit `1d746ee` (#245), 2FA is **mandatory** for every user login — not opt-in. The `Login` handler in `controllers/UserController.go:258-395` never returns `access_token` directly; every login path returns a `temp_token` first.

Two branches:
- `two_factor_enabled=false` → `requires_2fa_setup: true` + `temp_token` + `secret` + `qr_code_url` (issuer: **"Ampay"**, rebranded from "Mobiz"). If a `TwoFactorSecret` is already stored on the user record it is **reused** (commit `2549308` #318) — no regeneration on each login. Client completes setup via `/verify-setup`, then calls `/auth/2fa/verify` with the first TOTP code.
- `two_factor_enabled=true` → `requires_2fa: true` + `temp_token`. Client calls `/auth/2fa/verify` immediately.

`Verify2FALogin` (`controllers/TwoFactorController.go:181-250`, commit `4f1d55c` #319) accepts `user_type ∈ {"user","partner","sub_client","sub-client"}` — the hyphen variant `"sub-client"` was added for consistency with the rest of the codebase.

**Cross-repo impact:** All bank-bot integration tests break at login because they expect `access_token` directly. As of 2026-04-27 all 23 tests fail — see Oracle thread #48.

---
*Added via Oracle Learn*
