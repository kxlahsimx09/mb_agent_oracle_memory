---
title: epic-deposit pre-dev review→fix arc COMPLETE 2026-06-02: fully dev-ready, all me
tags: [orchestrator, team-dispatch, epic-deposit, pre-dev-review, dev-ready, mb-next-payment-gateway, 3-lens-review, pr-299-305, deposit-timer-two-sweep, low-findings, disjoint-file-prs, writer-owns-ac-prose, backlog, repo:arra-oracle-v3, fleet]
created: 2026-06-02
source: orchestrator session 2026-06-01→02; campaigns depreview/depfix/depfix-epic/deptimer/deptimer-epic/deplow
project: github.com/soul-brews-studio/arra-oracle-v3
---

# epic-deposit pre-dev review→fix arc COMPLETE 2026-06-02: fully dev-ready, all me

epic-deposit pre-dev review→fix arc COMPLETE 2026-06-02: fully dev-ready, all merged across 5 PRs (#299/#300/#302/#303/#305). main HEAD e8e1208.

CONTEXT: user requested a deep pre-development review of epic-deposit.md (mb-next-payment-gateway) before entering dev. Orchestrator ran it as a 3-lens fan-out + staged fixes.

REVIEW (campaign depreview, 3 parallel reviewers, read-only): next-architect (ADR-consistency: 2H/3M/3L), pg-writer (current-mobiz parity: 2H/6M/6L), next-writer (internal completeness: 4H/15M/5L). Story-hole verdict: DEPOSIT-006/011 = documented deliberate deferrals; DEPOSIT-010 = was accidental gap, now filled by the new client-cancel story.

FIXES (all merged, all meaning-locked, writer owns AC prose / architect owns adr.md):
- #299 (adr) + #300 (epic): HIGH+MED. deposit.completed→deposit.paid; V1.5 +checking (§CR5); whole-baht FLOOR at create; retroactive at-match slip-fraud DETECTION documented (refund still deferred DEPOSIT-011); status-taxonomy → deployed 7-value enum (TS1-R); client slip-upload Idempotency-Key; MDR all-or-nothing rollback ACs; §ADR-19 D2 fee link; 5 user-ratified decisions D1 (required customer source-bank fields) / D2 (escalate-to-checking) / D3 (port 4 gates incl new DEPOSIT-010 client-cancel) / D4 (server-derived bank-exclusion) / D5 (resend set {paid,expired,rejected,failed}).
- #302 (adr) + #303 (epic): TIMER MODEL (user redesign — emerged from LOW PG-L1). §ADR-4c Two-Sweep Restoration (supersedes the #299 DA5 expire-sweep escalation arm) + §ADR-4d D3 5min/slip_uploaded. Model: expire-sweep = slip-LESS → expired at per-client deadline (config); slip-escalation sweep = slip-BEARING → checking + Thunder at slip_uploaded_at + slip_review_timeout_minutes (default 5, config-tunable; the unconditional flip is the guaranteed no-verdict producer); slip-bearing never expires.
- #305 (epic): the 8 remaining LOW. NW-L1 400 IDEMPOTENCY_KEY_REQUIRED; NW-L2 V13↔V1.3 map; NW-L3 metadata bound ≤2KB/≤20 keys + METADATA_TOO_LARGE (user-confirmed value, no ADR pins it); NW-L4 sweep-tick ≤60s wording; NW-L5 deposit:verify-slip RBAC; PG-L2 idempotency 409/Idempotency-Key divergence note; PG-L4 QR image client-side (server GetQRImage endpoint + access telemetry intentionally not ported); PG-L5 active-partner-wallet precondition + mdr_skip + is_owner residual.

PROCESS NOTES: 2-PR-per-fix pattern (architect=adr.md branch, writer=epic.md branch) → DISJOINT files → merge any order, no mutual conflict (unlike the wave-2 batch that all shared adr.md revision-log anchor → 5 re-sync rounds). AC prose stayed writer-owned throughout (the standing user correction). All cross-campaign windows killed by NAME (finish-script orphan-pane bug recurs every close; nextteam campaign #293/#297/#301/#304 left untouched — different orchestrator instance orchestrator-orec).

REMAINING BACKLOG (not done; awaiting GO): (1) EG1 source-IP allowlist propagation to DEPOSIT-001/PAYOUT-001 + callback onboarding doc; (2) husk-dir sweep + team-dispatch-finish.sh orphan-pane fix (brew-ops handoff 2026-05-31_19-14); (3) stale illustrative counts §ADR-8 56→58 banks / §ADR-10 93→113 clients (from dpay ADR-18 re-verify); (4) revision-log shared-anchor process-fix; (5) the OTHER epics (payout/wallet-ledger/callback/topup/monitoring/etc) have NOT had the deep 3-lens pre-dev review epic-deposit got.

---
*Added via Oracle Learn*
