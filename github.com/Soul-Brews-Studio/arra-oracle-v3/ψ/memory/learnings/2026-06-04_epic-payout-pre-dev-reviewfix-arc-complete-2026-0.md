---
title: epic-payout pre-dev review→fix arc COMPLETE 2026-06-04: dev-ready, all merged (P
tags: [orchestrator, team-dispatch, epic-payout, pre-dev-review, dev-ready, mb-next-payment-gateway, 3-lens-review, pr-323-325-326, payout-remediation-toolkit, step-up-carveout, payout-state-machine, residual-mdr-payout, dpay-verify, prod-data-grounded-decision, numbering-collision-caught, repo:arra-oracle-v3, fleet]
created: 2026-06-04
source: orchestrator session 2026-06-04; campaigns payreview/paydesign/dpayverify/payfix/payfix-epic/stalecnt
project: github.com/soul-brews-studio/arra-oracle-v3
---

# epic-payout pre-dev review→fix arc COMPLETE 2026-06-04: dev-ready, all merged (P

epic-payout pre-dev review→fix arc COMPLETE 2026-06-04: dev-ready, all merged (PRs #323 adr + #325 epic + #326 stale-counts). main HEAD 7c74536.

CONTEXT: user requested the same 3-lens pre-dev review as epic-deposit, now on epic-payout (money-OUT, the mirror lane). Pattern: next-writer=completeness + pg-writer=current-mobiz-parity + next-architect=ADR-consistency+decides-un-ADR'd-gaps → orchestrator aggregates → user ratifies → staged fixes (architect adr + writer epic).

REVIEW (campaign payreview, 3 parallel read-only reviewers): architect 2H/1M/4L, pg-writer 2H/4M/5L, next-writer 2H/7M/7L. Story holes PAYOUT-006 (cut) + PAYOUT-011 (deferred review→failed) both deliberate.

KEY VERIFICATION WINS (orchestrator diligence before acting):
1. STEP-UP (review H1/H2 said PAYOUT-004/005 omit §ADR-2 S2 step-up): user asked to check current — verified in Go source that current VerifyTOTPStepUp is called ONLY for deposit_refund/deposit_refund_resolve, NEVER payout/settlement/pullout. So S2 was a next-system HARDENING, not a current-drop. User RATIFIED: CARVE PAYOUT OUT of S2 step-up scope (current-parity).
2. REMEDIATION (review: next-system dropped the payout-correction toolkit, alert-only): user asked to verify OverridePayoutStatus/ConfirmPayoutCompleted are real vs dead/legacy. brew-ops queried dpay PROD DIRECTLY (mcp__dpay__*, NOT the flaky subagent; grounded field names in Go first): OverridePayoutStatus 239 uses (last 2026-06-03), ConfirmPayoutCompleted 1300 uses (!) — both daily-use CS tools, NOT debug/legacy (contradicts §ADR-4a D8). → user RATIFIED port the full toolkit.

5 RATIFIED DECISIONS (user GO 2026-06-04, campaign payfix):
- DEC-A §ADR-2 S2 carve-out: payout admin actions NOT step-up-gated (AUTH-007 updated).
- DEC-B §ADR-4a D8 amendment: PORT the correction toolkit as 2 gated admin stories — PAYOUT-012 correction (failed/review→success, the 1300× dominant) + PAYOUT-013 reverse_settle (success→failed). NOT step-up; §ADR-13 admin-write + audit + atomic.
- DEC-C §ADR-15: ADD false-FAILED detection (P2.17, audits the failed population for double-spend) — sibling of P2.16.
- DEC-D §ADR-4a state-machine: canonical states (drop 'claimed'→processing; unify 'success'); per-RPC source-state table; late-report SPLIT (user nuance): mark_success ACCEPTS a late bot report from review (statement just slow); mark_failed is bot=processing-ONLY (review→failed is the clawback case, admin/statement only, never a late bot's word).
- DEC-E §ADR-10: payout_reverse_settle wallet op + extend RM2/R1 residual-MDR to payout fan-out + reverse-settle MDR-unwind = per-partner ALL-OR-NOTHING (user nuance, corrected mid-flight): full claw-back only if the wallet covers the full share, else deduct NOTHING for that share + audit the full unrecovered shortfall (cleaner to net later than a partial); never partial, never forced-negative.

ORCHESTRATION CATCHES before the writer applied: (1) architect first encoded DEC-E as 'recover what is available' (partial) — corrected via maw team send to all-or-nothing-per-share; (2) architect reused PAYOUT-011 (already taken = deferred review→failed) for the new correction story — caught the collision, renumbered to 012/013, left 011 as the deferred surface. (3) a maw team send got shell-mangled by backticks in the body — resent backtick-free.

+ PR #326 stale-counts: §ADR-8 56→65 banks (live re-verify found growth past the 2026-05-31 58 figure; corrected a now-false 'all method=payout @50000' assertion), §ADR-10 93→113 clients; as-of-date convention added to prevent recurrence. NOTE: §ADR-18 still has the same stale figures back-referenced (out of scope; small follow-up).

PROCESS: architect=adr.md PR, writer=epic+auth+INDEX PR (disjoint from adr). The #323+#326 both-touch-adr.md overlap merged clean (no markers). dpay MCP: works from a fresh teammate session; the long-lived orchestrator session's HTTP session expires ('invalid session') — query via a teammate.

REMAINING BACKLOG: finish-script orphan-pane fix (brew-ops handoff 2026-05-31_19-14); revision-log shared-anchor process-fix (the recurring adr.md merge cascade — this arc hit it again); §ADR-18 stale-figure back-refs; the OTHER epics not yet deep-reviewed (wallet-ledger, callback-delivery, topup, monitoring, statement-matching, admin-audit, bot-dispatch, fleet-control, entity-provisioning, source-flows, client-api).

---
*Added via Oracle Learn*
