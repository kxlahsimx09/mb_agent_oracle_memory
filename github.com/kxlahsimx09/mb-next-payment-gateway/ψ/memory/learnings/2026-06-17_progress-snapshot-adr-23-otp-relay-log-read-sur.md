---
title: progress snapshot — §ADR-23 OTP-Relay Log read surface (OTPLOG-001..003) marked 
tags: [next-pm, repo:mb-next-payment-gateway, next, progress, dod, sealed, otplog, epic-otp-relay-log, adr-23]
created: 2026-06-17
source: docs/requirements/epic-otp-relay-log.md@d4f7f7c + PR #566 + next-tester_otplogsbuildt_findings.md + next-investigator_otplogsseal_findings.md
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# progress snapshot — §ADR-23 OTP-Relay Log read surface (OTPLOG-001..003) marked 

progress snapshot — §ADR-23 OTP-Relay Log read surface (OTPLOG-001..003) marked DoD-GREEN (gateway side).

Marked 2026-06-17 by next-pm (campaign otplogspm), build-workflow.md Step 4, on concrete per-step evidence (gone-and-looked, never on a claim):
- BUILD: PR #566 MERGED to main — merge commit f2c01cd930ea2f13f430da92548611c3da3a7207, confirmed ancestor of origin/main; migration 20260617000140_v_otp_logs_read_surface.sql + pgTAP test present on main.
- REVIEW: next-code-reviewer (campaign otplogsreview) PR #566 review BODY-HEADER = APPROVE across the 3 dimensions. gh review state=COMMENTED is the expected self-authored-PR degrade under the shared kxlahsimx09 identity (verdict = body header per build-workflow Step 3, NOT gh state).
- VERIFY(probe): next-tester (campaign otplogsbuildt, tester stack yupsevcrubgprsbujbpu, probe-sha f2c01cd) 25/25 GREEN, 0 FAIL, teeth proven (harness self-validates to FAIL on a leaked code first), code-blind.
- VERIFY(seal): next-investigator (campaign otplogsseal, own seal stack qnccphgykzdydebmdwdf, seal-sha f2c01cd = merged HEAD) SEAL — every tester PASS re-derived from raw seal-DB; TEETH (OTP code never in v_otp_logs) confirmed FOUR ways (viewdef excludes o.otp by construction; schema 0 forbidden cols; non-vacuous behavioral seed->gated-read->cast = absent; wire select=otp -> 400); zero residue.
- LIVE (§ADR-21): N/A. The LIVE gate is the per-epic golden MONEY journey (DEPOSIT/AUTH/PAYOUT) recomputing the 4 money invariants from raw tables. v_otp_logs is a read-only, non-money admin surface — no money moves, no money journey, no invariant to recompute. DoD met on build evidence. (Contrast bbotmark, which moved money + had a cross-repo bot LIVE journey.)

Mark mechanism (doc-only, per bbotmark/payout/deposit precedent): docs/requirements/epic-otp-relay-log.md gets a "Build status (DoD)" section + 3 per-story DoD-GREEN blockquotes. INDEX.md untouched (trust-label surface; DoD state lives in the epic). Committed to campaign/otplogspm off main (commit d4f7f7c); NOT self-merged (doc-mark is not build CODE so §9a does not apply — left for owner-merge).

NOT marked (owner-gated, out of this DONE): (c1) OTPLOG-003 metadata-retention archive window [RATIFICATION_PENDING:owner]; (OQ-2) from_email parity gap; (OQ-3) method badges; (OQ-4) parse-failure visibility. Non-defect awareness: deferred SV8-allowlist §ADR-13 amendment to ratify _otp_log_app_now() (architect doc task, #456 precedent shape); the tester raw-db:view-row-cast leg was vacuous (no-JWT -> 0 rows) and the investigator closed it (forced gated JWT, code still absent) — non-blocking.

Evidence file: next-pm_otplogspm_findings.md.

---
*Added via Oracle Learn*
