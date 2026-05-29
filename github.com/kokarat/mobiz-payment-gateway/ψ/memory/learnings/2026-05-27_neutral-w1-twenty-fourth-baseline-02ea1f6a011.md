---
title: NEUTRAL — W1 twenty-fourth baseline `02ea1f6..a011daf` — 5 production-surface co
tags: [tester, repo:mobiz-payment-gateway, current, w1-twenty-fourth-baseline, no-op-neutral, 2fa, totp, bot-ops, bank-account, cors]
created: 2026-05-27
source: docs/test-index.md (baseline a011daf) + helpers/brand.go::BrandTOTPIssuerForHost@8bb1be6 + main.go ErrorHandler@a011daf + controllers/BankAccountController.go:115-122@99ba05d
project: github.com/kokarat/mobiz-payment-gateway
---

# NEUTRAL — W1 twenty-fourth baseline `02ea1f6..a011daf` — 5 production-surface co

NEUTRAL — W1 twenty-fourth baseline `02ea1f6..a011daf` — 5 production-surface commits, zero status flips.

W1 validate pass on 2026-05-28 (GMT+7). Range `02ea1f6..a011daf` (HEAD = #492) carried 5 production-surface commits, ALL NEUTRAL across the 49-test suite; matrix unchanged: 44 VALID / 1 STALE / 0 WRONG-SETUP / 0 FLAKY / 2 SUPERSEDED / 2 ON_HOLD / 0 UNKNOWN.

LOAD-BEARING finding — #487 `8bb1be6` (2FA TOTP issuer resolved from Host header): this looked dangerous (2FA on login is the surface that broke all 35 VALID tests in the #245 incident, `1d746ee`, 2026-04-27). Verified against code (P-004, not just the commit message): `helpers/brand.go::BrandTOTPIssuerForHost(host)` only feeds the `Issuer:` LABEL field of `totp.Generate` / the otpauth URL (host→override table: bo.youpay.vip→Youpay, bo.dpay.money→Dpay, else env `TOTP_ISSUER`/Ampay). `user.TwoFactorSecret`, the TOTP RFC6238 validation, and the login 2FA enforcement gate are byte-for-byte unchanged. This is categorically NOT a #245-class enforcement break — it is a QR display string. `grep -lnE "TOTP_ISSUER|BrandTOTPIssuer|otpauth|issuer|Setup2FA" → 0`; the only 2FA-exercising test `test-deposit-refund.sh` derives codes from `db.users.two_factor_secret` via `generate-totp.js` (label-independent). Future sessions: a Host-header / issuer-label change is safe for the suite; only an *enforcement* or *secret/validation* change is a #245-class hazard.

Other four — all NEUTRAL: #486 `99ba05d` (sub-client bank-account owner_name → parent client) — 0 tests create a sub-client or call `POST /api/v1/bank-accounts`. #490 `83a2513` + #491 `a4b23fb` (bot-ops per-cloud SSH user, `PUT /api/v1/bot/cloud-provider` registration, systemctl `sudo -n` wrap) — 0 tests touch the remote host-locator/SSH path; the suite runs a local bot (Pattern 7). #492 `a011daf` (re-land kustomize AWS infra + `main.go` CORS ErrorHandler) — k8s/region are infra; the new Fiber ErrorHandler keeps Fiber's default status-code logic and fires only on propagated errors (controllers write their own `c.Status().JSON()`); 0 tests assert on 5xx body/CORS/AWS region.

Net: zero status flips; matrix carries forward verbatim. New 🟢 coverage-gap rows appended for all four production surfaces (a QR label, a denormalized owner field, ops tooling, browser error surfacing — none touch a money path). PR branch `feat/tester-validate-2026-05-28`. The non-production-surface in-range commits (#484 k8s rename, #482 seed scripts, #481 k8s secret, docs/track + flow-track + prior tester-validate merges) touch zero Go production code.

Related: prior W1 twenty-third baseline `02ea1f6` (PR #479, 2026-05-24); the #245 2FA-enforcement incident learning (`2026-04-27_incident-2fa-enforcement-on-login`).

---
*Added via Oracle Learn*
