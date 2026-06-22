---
title: UI design decision — `/otp-logs` portal surfaces the §ADR-23-enhancement `from_e
tags: [next-ui, repo:mb-next-admin-portal, next, otp, otp-logs, decision, adr, WUI-212, ADR-23, from_email, redaction, teeth, component]
created: 2026-06-17
source: https://github.com/kxlahsimx09/mb-next-admin-portal/pull/50 @ee0b01e
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# UI design decision — `/otp-logs` portal surfaces the §ADR-23-enhancement `from_e

UI design decision — `/otp-logs` portal surfaces the §ADR-23-enhancement `from_email` metadata column (WUI-212 cross-repo portal half).

Context:
- The §ADR-23 enhancement (gateway PR #578, MERGED) added a `from_email text` column to the `v_otp_logs` read surface, projected right AFTER `source` (gateway SPEC §2e). It is the SOURCE email address of an email-relayed OTP — sender metadata, NOT the OTP code — and is null for SMS relays (most rows).
- Portal change (mb-next-admin-portal PR #50, merge commit ee0b01e on main, off origin/main 76f7628):
  1. `VOtpLog` (src/lib/otp-logs-api.ts) gains `from_email: string | null`, placed after `source` to mirror the view projection order.
  2. `readOtpLogs()` uses `select("*")` (pin-lists nothing), so the new column returns with NO query change.
  3. Table (otp-log-columns.tsx): a `from` column (hideSm), blank cell for null.
  4. Detail modal (otp-log-detail-modal.tsx): a "From" row shown only when present (mirrors the existing last_read_at optional-row pattern).
  5. Page free-text search also matches from_email. Reused the pre-existing (previously unused) i18n key `fromEmail` ("From"/"จาก").

TEETH (§ADR-23 P2 redaction rule / owner HARD CONSTRAINT) UNCHANGED: the OTP code is still NEVER projected/bound/revealed/masked/copied/exported. `from_email` is sender-address metadata, not the code. Verified on merged main: zero `.otp` code-field access; no `otp` field on `VOtpLog`.

Gotcha worth remembering: the prior VOtpLog docstring asserted "`from_email` is NOT on the next substrate (OQ-2) — not bound." That described the PRE-enhancement contract; PR #578 changed it. Corrected the docstrings rather than leaving stale "not bound" prose (Code-is-Truth: don't let a doc claim outlive the contract it described).

Deploy NOT done here (deploy/env single-owner = brew-ops, AGENTS.md §9b) — the live effect lands when brew-ops redeploys the portal.

---
*Added via Oracle Learn*
