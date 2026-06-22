---
title: drift — DRIFT-17 Terms & Conditions acceptance (new top-level feature) deferred to W1
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - terms-conditions
  - rbac
  - drift
created: 2026-06-17
source: controllers/TermsConditionsController.go + middlewares/termsAccepted.go + models/terms_conditions.go + models/terms_acceptance.go @ ba8d63a
related:
  - 2026-06-01_drift-16-finance-api-deferred-to-w1
  - 2026-06-17_decision-range-a011daf-03d6383-w1-sized-escalate
project: github.com/kokarat/mobiz-payment-gateway
---

# DRIFT-17 — Terms & Conditions acceptance is a new top-level feature, undocumented in current-system.md

`ba8d63a` #514 "Add Terms & Conditions acceptance for role=client" (2026-06-13, +883 LOC / 16 files) introduces a whole new feature area. Recorded as deferred drift in the 2026-06-17 W2 pass (current-system.md §9 DRIFT-17, §11 escalation). It is the **second** new top-level feature deferred to W1 alongside Finance (DRIFT-16).

Evidence (post-change @ ba8d63a):
- **Two new Mongo collections**: `terms_conditions` (`models/terms_conditions.go:25-37` — version int append-only, title/content th+en, status 1=active/0=superseded) and `terms_acceptances` (`models/terms_acceptance.go:17-28` — client_id, user_id/username/user_type who clicked, version, accepted_at, ip, user_agent).
- **Gating middleware** `middlewares/termsAccepted.go:74-89` — returns `403 TERMS_NOT_ACCEPTED` when `client.terms_accepted_version < current published version`. 30 s Redis-cached current-version lookup; **fail-open** on transient errors; runs after APIKeyCheck. Applied to client-facing `POST /deposit/create` (`routes/depositRequest.go:23`) + `POST /payout/create` (`routes/payoutRequest.go:22`) only.
- **Six endpoints** (`routes/terms_conditions.go`, `routes/user.go:30`): `GET /terms-conditions/current` (JWT), admin-gated `GET/POST /terms-conditions` + `PUT /terms-conditions/:id` + `GET /terms-conditions/acceptances`, and `POST /users/accept-terms` (JWT).
- New SSE channel `"terms"` (`controllers/SSEController.go:51`); new fields `terms_accepted_version`/`terms_accepted_at` on `models/clients.go` (per-client gate) + `models/users.go` (informational). 4 new T&C indexes in `db/indexes.go:421-432`.
- Scope is **role=client only** (sub-clients accept via parent client; admins/merchants/partners unaffected).

**Security note (same commit):** `ClientController.LoginClient` + `PartnerController.LoginPartner` now set `UserType:"client"/"partner"` explicitly — previously defaulted to `"admin"`, a privilege-escalation bug. Flag for `security_auditor` when the W1 pass writes the §7 security section.

Resolution path: **Workflow 1 re-baseline** (new collections + new middleware + new route group = three §11 triggers). Not fast-fixed in W2 (would be a wrong fast-fix to summarise a new feature inline).
