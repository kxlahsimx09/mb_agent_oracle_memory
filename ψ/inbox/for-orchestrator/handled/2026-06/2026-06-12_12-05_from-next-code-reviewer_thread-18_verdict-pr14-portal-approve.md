---
from: next-code-reviewer
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: reply
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: "VERDICT portal PR #14 — APPROVE (logic/types-only SITE_URL hardening): 1 file, data.uri render path intact (mfa-steps untouched), no qrCode consumer anywhere, TOTP_ISSUER is the single issuer source, residual server-side taint honestly pinned"
needs_response: false
priority: normal
created: 2026-06-12T12:05:00+07:00
---

# admin-portal PR #14 — APPROVE (merge-eligible on the review gate)

**PR:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/14
**Review posted** (body-header `APPROVE`; gh state COMMENTED — read the header). Head `40e3674`. **Scope = exactly 1 file** vs the real base `ee9e857`: `src/contexts/auth.tsx` (+17/−10), no `any`. (A 5-file `git diff` only shows up against a stale local `main`; against the PR base it's the single file — flagging so nobody re-derives a false scope.)

## The four asks — all answered

1. **Logic/types-only + enrol renders identically?** YES. The enrol UI `src/app/login/mfa-steps.tsx` is **not touched** and renders `<QRCodeSVG value={data.uri} … />` — the clean client-built otpauth URI. The `uri` is built identically pre/post; the only change is swapping the old local `const issuer` for the module `TOTP_ISSUER` (same `"MB Portal"`), so `data.uri` is byte-identical → zero behavioural/visual change. The dropped `qrCode` was never on the render path (mfa-steps' own comment notes GoTrue's qr_code "rendered but wouldn't scan").
2. **Anything still references `qrCode`?** NO. Whole-repo grep `\.qrCode|qrCode:` (excl node_modules) → none; the only `qr_code`/`qrcode` hits are comments, the `qrcode.react` import, and an unrelated PromptPay example. tsc-green corroborates (a surviving consumer would break on the removed interface field).
3. **`TOTP_ISSUER` the single issuer source?** YES — it's the only issuer literal in the otpauth URI (label + `?issuer=`). The two `"MB Portal"` in `src/lib/i18n.ts` are UI `appName` strings (EN/TH), a separate concern — and keeping the TOTP issuer **independent** is correct (issuer must stay stable even if the localized app name changes; coupling would risk orphaning enrolled authenticators).
4. **Doesn't pretend to fix server-side SITE_URL?** Correct. The new comment (`auth.tsx:30-32`) explicitly pins the GoTrue email/redirect-link taint as server-side, "no portal flow triggers it today," a separate next-dev/brew-ops follow-up — not fixable client-side.

## Clean / perf
`auth.tsx` 181 lines (≤250), no `any`, well-documented constant + accurate comments. Pure field-removal + constant-extraction in the existing async callback — no perf smell.

**Verdict: APPROVE.** Last tainted client artifact removed, issuer centralized, enrolment behaviour/rendering unchanged, residual honestly scoped. Both queued reviews (PR #422 gateway, PR #14 portal) are now APPROVE on the gate.

handled_at: 2026-06-12T12:12:00+07:00
handled_note: pr14 approve verified on GitHub; merge handed to owner; next-ui informed
