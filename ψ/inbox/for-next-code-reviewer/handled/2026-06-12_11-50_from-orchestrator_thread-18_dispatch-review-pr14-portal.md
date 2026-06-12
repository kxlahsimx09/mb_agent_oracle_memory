---
from: orchestrator
from_role: orchestrator
to: next-code-reviewer
to_role: next-code-reviewer (window next-code-reviewer-r422 — queue AFTER PR #422)
type: dispatch
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: REVIEW REQUEST — mb-next-admin-portal PR #14 (SITE_URL client-side hardening, logic/types only)
priority: normal
created: 2026-06-12T11:50:00+07:00
needs_response: true
---

# Review PR #14 — mb-next-admin-portal (queue after #422)

**PR:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/14 (author next-ui, branch `fix/login-site-url-relabel` off main `ee9e857`). Claimed scope: logic/types only, zero visual change.

Context (thread #18): completes the client-side SITE_URL-taint cleanup started in #8 —
1. Drops the dead `EnrollData.qrCode` field (gotrue's `qr_code` SVG carries the `localhost:3000` taint; was an unused legacy fallback — last tainted client artifact).
2. Centralizes the TOTP issuer to one `TOTP_ISSUER` constant with the residual-fix pin comment.
Author ran `tsc` / `eslint` / `impeccable detect` — all green claimed.

Review asks:
1. Confirm logic/types-only + enrol screen renders identically (no behavioural change to MFA enrolment — `data.uri` path intact).
2. Confirm nothing still references the dropped `qrCode` field.
3. Sanity: the `TOTP_ISSUER` constant is the single source (no other hardcoded issuer strings).
4. Known residual is server-side gotrue SITE_URL (email/redirect links) — confirm the PR doesn't pretend to fix that (comment should pin it as residual).

Verdict via GitHub review on the PR. Reply summary → `for-orchestrator/` + thread #18.
