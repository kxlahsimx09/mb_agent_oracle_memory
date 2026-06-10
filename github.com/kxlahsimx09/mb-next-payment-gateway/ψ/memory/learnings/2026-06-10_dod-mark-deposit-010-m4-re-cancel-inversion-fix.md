---
title: #dod-mark — DEPOSIT-010 M4 re-cancel inversion FIXED — IN-SLICE-DONE (campaign s
tags: [dod-mark, deposit, deposit-010, in-slice-done, m4-re-cancel, idempotent, verify-probe, nextteam, next-pm, simlive]
created: 2026-06-10
source: next-pm (campaign simlive) — DoD-mark
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #dod-mark — DEPOSIT-010 M4 re-cancel inversion FIXED — IN-SLICE-DONE (campaign s

#dod-mark — DEPOSIT-010 M4 re-cancel inversion FIXED — IN-SLICE-DONE (campaign simlive, marked by next-pm 2026-06-10 GMT+7).

Marked gate-to-artifact, FROM ARTIFACTS ONLY (merged-PR + probe; never claims). Scope = the M4 idempotent re-cancel fix slice (200 echo not 409 + effective-pending precondition); NOT epic-done — the §ADR-21 LIVE gate + owner ACCEPT for epic-deposit is a separate per-EPIC step.

GATE BOARD (gate → artifact → result):
- SPEC: next-architect_dep10fix_spec.md F1–F7, reconciled to ratified S2 epic-deposit.md (M4 AC :693, NOT_PENDING AC :694). PASS.
- BUILD: PR #371 MERGED to main — gh: state=MERGED, mergeCommit 43df6402d41c42a5391cdf4dbc5c56364fd05303, mergedAt 2026-06-10T10:12:56Z. Branch fix/deposit010-m4-idempotent-recancel, +210/-28, 3 files: NEW migration 20260610000001_deposit010_m4_idempotent_recancel.sql (the already_cancelled branch placed BEFORE the status<>'pending' gate → RETURN with NO UPDATE, cancelled_at not re-stamped, no callback, no wallet effect), deposits-cancel/index.ts outcome→HTTP mapping, spec rev. Original 20260607000001 client-cancel migration confirmed UNTOUCHED. PASS.
- REVIEW: reviewer-371-report.txt — next-code-reviewer VERDICT APPROVE, no blockers; M4 echo CORRECT on full-content read. PASS.
- VERIFY (PROBE GREEN): /tmp/simlive/tester-dep10-probe-report.txt — next-tester F4/F5 probe rev on INDEPENDENT stack qnccph (qnccphgykzdydebmdwdf), de-biased (authored from SPEC only; production source NOT read). OVERALL GREEN:
   • P1 M4 re-cancel: cancel#1 200 → re-cancel STRICTLY==200 (not 409), body identical, status stays cancelled, cancelled_at UNCHANGED (before==after = 2026-06-10 10:25:05.331239+00), O3/O4 zero callback_queue + zero callback_attempts rows. PASS.
   • P2 F5 de-bias self-check: verdict(200)==PASS, verdict(409)==FAIL — probe demonstrably REJECTS the OLD 409-on-re-cancel impl (strict predicate, not loose 200||409). PASS.
   • P3 404: ADMIN unknown deposit_id → 404 {error:deposit_not_found}, no row created. PASS. (Per reviewer-371 note the F4 404 probe correctly uses an ADMIN caller — a non-admin sees 403 by tenant-scope; design-correct.)
   • P4 AC2(c) effective-expired: raw status=pending (sweep not ticked) → 409 {code:NOT_PENDING, status:expired} echoing EFFECTIVE expired (not raw pending), row unchanged (not flipped to cancelled). PASS.

INVERSION CLOSED: re-cancel now returns 200-echo (idempotent), no longer the inverted 409; cancelled_at immutable on replay; no duplicate callback/wallet side-effects. The DEPOSIT-010 M4 fix slice is IN-SLICE-DONE.

SCOPE DISCIPLINE: claimed "DEPOSIT-010 M4 fix: code-landed + probe-GREEN (in-slice-done)" — NOT "epic done". The §ADR-21 LIVE gate + owner ACCEPT remain the separate per-EPIC step.

---
*Added via Oracle Learn*
