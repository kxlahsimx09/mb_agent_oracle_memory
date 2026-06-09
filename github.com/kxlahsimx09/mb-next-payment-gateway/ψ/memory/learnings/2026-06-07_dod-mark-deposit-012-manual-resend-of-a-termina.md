---
title: DoD-MARK — DEPOSIT-012 (manual resend of a terminal deposit callback; client / s
tags: [dod-mark, deposit-012, nextteam, done-to-seal, deposit-epic]
created: 2026-06-07
source: next-pm dep12pm DoD-mark
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK — DEPOSIT-012 (manual resend of a terminal deposit callback; client / s

DoD-MARK — DEPOSIT-012 (manual resend of a terminal deposit callback; client / sub-client / admin) — DONE-TO-SEAL (all 9 in-slice ACs). NOT epic-done: §ADR-21 LIVE gate + owner ACCEPT remains owner-only.

Marked from ARTIFACTS ONLY by next-pm; each of the 5 gates independently re-verified gate-to-artifact on 2026-06-07.

GATE BOARD (all GREEN):
- SPEC ✓ docs/spec/deposit-012-resend-callback-slice.md present on origin/main (blob 9e8c0bb), added by 3f38a9d. 9-AC test-facing contract + DB observable surface.
- BUILD ✓ PR #342 MERGED (squash mergeCommit 3f38a9d, mergedAt 2026-06-07T06:50:30Z); git merge-base --is-ancestor 3f38a9d origin/main = TRUE. Delta name-status: M supabase/config.toml ([functions.deposit-resend-callback] verify_jwt gate, DEPOSIT-008 platform-gate class) + A supabase/migrations/20260607000002_deposit012_resend_race_guard_dispatching.sql (AC6 race-guard, predicate line 87 status IN ('pending','dispatching') = in-flight non-terminal set, faithful §ADR-9 AM5, forward-only CREATE OR REPLACE resend_callback). EF supabase/functions/deposit-resend-callback/index.ts pre-existing on main (substrate ~90% pre-built).
- REVIEW ✓ next-code-reviewer ## VERDICT: APPROVE in PR #342 body and in next-code-reviewer_dep12review_findings.md.
- VERIFY ✓ next-tester 19/19 GREEN across 9 ACs; evidence/integration-deposit-12-1780814643268-2746a84a.json summary {total:19, passed:19, failed:0}; probe suite commit 407b2fc on campaign/dep12test; harness falsification-validated first.
- SEAL ✓ next-investigator verdict: SEALED on isolated seal stack qnccphgykzdydebmdwdf — all 9 ACs independently re-derived PASS from truth DB (202 + 1 queued callback + 1 manual_resend attempt same-event-id actor-triple one-txn; admin all 4 terminals; race-guard 409; non-terminal 409; 403 tenant/perm; original history untouched). next-investigator_dep12seal_findings.md.

MILESTONE: DEPOSIT-012 is the LAST DEPOSIT build slice. With it sealed, ALL DEPOSIT build slices (001/002, 003/004, 005, 007, 008, 009, 010, 012) are now DONE-TO-SEAL — still pending the owner per-epic §ADR-21 LIVE acceptance.

Tags: dod-mark, deposit-012, nextteam, done-to-seal, deposit-epic

---
*Added via Oracle Learn*
