---
title: TOTP issuer label is now host-resolved before the env fallback (8bb1be6 #487, 20
tags: [technical-writer, repo:mobiz-payment-gateway, current, 2fa, multi-brand, track-commit]
created: 2026-05-27
source: helpers/brand.go:8-59@8bb1be6
project: github.com/kokarat/mobiz-payment-gateway
---

# TOTP issuer label is now host-resolved before the env fallback (8bb1be6 #487, 20

TOTP issuer label is now host-resolved before the env fallback (8bb1be6 #487, 2026-05-27). New helper helpers.BrandTOTPIssuerForHost(host) consults a fixed per-host override map (bo.youpay.vip→Youpay, bo.dpay.money→Dpay; strips any :port suffix, lowercases) and falls back to BrandTOTPIssuer() (env TOTP_ISSUER, default Ampay) when no host matches. Wired at the three TOTP issuance sites — TwoFactorController.Setup2FA, plus the reuse-existing-secret and fresh-generate branches of UserController.Login — all passing c.Hostname(). This lets aliased hostnames that share one pod (bo.youpay.vip / bo.dpay.money both on the ampay backend, consistent with 2087fed aliasing youpay.vip→ampay cluster) show their own brand in Google Authenticator / Authy instead of the pod-wide env default.

Security-neutral by design: the issuer is a display label only, not part of the TOTP secret nor of its validation (the issuer is not HMAC'd), so already-enrolled users keep working and only newly enrolled users see the per-host label; because the override map is a fixed allow-list, an attacker-supplied Host cannot inject an arbitrary issuer — an unknown host just falls back to the env default. Extends the env-driven brand split first introduced at 3ee8018 #461 (multi-brand identifiers env-driven). Documented in docs/current-system.md §1 line 22 + §7.5.

---
*Added via Oracle Learn*
