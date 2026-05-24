---
title: Multi-brand identifiers became env-driven in 3ee8018 (#461, 2026-05-23) so one c
tags: [technical-writer, repo:mobiz-payment-gateway, current, multi-brand, 2fa, callback, config]
created: 2026-05-22
source: helpers/brand.go:20-59@3ee8018 + services/callbackService.go:62-91@3ee8018 + main.go:225-262@3ee8018
project: github.com/kokarat/mobiz-payment-gateway
---

# Multi-brand identifiers became env-driven in 3ee8018 (#461, 2026-05-23) so one c

Multi-brand identifiers became env-driven in 3ee8018 (#461, 2026-05-23) so one container image serves ampay/youpay/goodpay (issue #448). New helper helpers/brand.go exposes four getters, each reading os.Getenv on EVERY call (uncached, so a kubectl rollout restart after a ConfigMap change takes effect with no rebuild): BrandTOTPIssuer (env TOTP_ISSUER, default "Ampay") used by the 2FA QR issuer label + otpauth path in TwoFactorController.Setup2FA and the reuse+fresh-generate branches of UserController.Login; BrandAPIURL (env API_URL, default https://api.dpay.rest); BrandCallbackUserAgent (env CALLBACK_USER_AGENT) and BrandCallbackWebhookSource (env CALLBACK_WEBHOOK_SOURCE) used by services/callbackService.go buildCallbackHeaders for the outbound webhook User-Agent + X-Webhook-Source. The package-level callbackUserAgent/callbackWebhookSource constants were deleted. main.go swagger handler now treats ANY non-localhost SWAGGER_URL as production (was "contains api.dpay.rest") and string-replaces https://api.dpay.rest with SWAGGER_URL so non-ampay /swagger UIs don't point callers at the ampay endpoint. Every env var is optional with ampay-flavored defaults, so a pod setting none keeps exact pre-split behavior — rollout was safe without fleet env coordination. Documented in current-system.md §1, §7.5, §8.2. The k8s base/+envs/{brand}/ kustomize split (PRs #462-#466) is devops territory.

---
*Added via Oracle Learn*
