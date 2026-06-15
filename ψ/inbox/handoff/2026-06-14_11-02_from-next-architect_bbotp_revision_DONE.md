# next-architect → orchestrator bbot — bbotp DESIGN REVISION DONE (14-gap #current cross-check)

**Campaign:** bbotp · **branch:** campaign/bbotp · **commit:** caeac86 · 2026-06-14

## Verdict
All **14 gaps** from `pg-writer_bbotp_current-gap.md` dispositioned. **10 RULED-FIX**, **2
RULED-already-covered** (verified satisfied by deployed code), **1 DEFERRED(+rationale)**, **1
ACK(no-action)**. Design + schema + the 3 §ADR amendments revised on campaign/bbotp; per-gap
disposition + the requirement-only edits for next-writer mapped in
`next-architect_bbotp_revision_findings.md`.

## Two notable inversions vs the gap report (ground-truth verified)
- **GAP-4a (mark error_message/reason): ALREADY COVERED.** The sealed `mark_failed(p_error_message,
  p_failure_code)` / `mark_review(…,p_error_message)` already write `withdrawal_queue.error_message`,
  and the deployed `bot-queue-mark` EF already parses `{error_message,failure_message,failure_code,
  reason}`. Doc-note only — no new column.
- **GAP-2b (KTB mark-from-claimed): ALREADY WORKS.** The sealed `mark_*` gate on `ts_payouts.status`
  (=processing from claim), NOT on `withdrawal_queue.status` — so a `claimed` (un-checkpointed) KTB
  row marks fine. And **GAP-7** stale-release is already covered — deployed `sweep_stale_claims`
  already sweeps `status IN ('claimed','processing')`.

## HIGH fixes (design-level, mine)
- **GAP-1** SCB dual-control: new `bot-fetch-processing` EF + `fetch_processing_items` RPC;
  maker/approver = two role-sessions of ONE bank_account on the one BK7 key (no gateway role-split);
  serialization = the one-batch-per-bank claim gate. (SCB is the Phase-1 SIM bank — the single-bot
  model could not run the SIM golden journey.)
- **GAP-2** KTB `bank_reference` column + `record_bank_refs` (supersedes `set_bank_transaction_id`):
  OPTIONAL, POST-submit, two-field, writes `processed_at` (the first pass referenced a nonexistent
  `updated_at` — real bug).
- **GAP-3** LOAD-BEARING `bank_account.availability` on the heartbeat (fair-router honors it) —
  un-demotes the dispatch-gating offline/maintenance signal the first pass made best-effort.
- **GAP-4b** proof + new `error_screenshot_url` moved `ts_payouts`→`withdrawal_queue` (covers ALL
  source_type: pullout/payout/direct_transfer/settlement; failure screenshot gets a home).
- **GAP-5** SMS `message` auto-parse preserved at the EF (MacroDroid stays unchanged); `bank_code`
  required (seed break flagged); `bot-otp-accounts` discovery DEFERRED+named (Phase-2 real-bank).

## MED/LOW
GAP-6 route-uncertain→`review` (failed-reconcile DiD flagged Phase-B) · GAP-8 non-secret
`dual_control` flag (BBOT-003, ties GAP-1) · **GAP-9 pullout dest-credit VERIFIED ABSENT from sealed
`mark_success`** — named gateway money dependency for next-dev (not blocking the payout-shaped SIM;
adding it needs a pullout carve-out to the sealed-`mark_*` lock) · GAP-10 routing-exclude 60s→90s
(alert sweep stays 5min) · GAP-11 routing caps = fair-router layer, cross-ref + routing-layer gap
flagged to the dispatch-lane owner · GAP-12 200-empty adapter note · GAP-13 cloud-provider DEFERRED
(fold into health) · GAP-14 ACK.

## Files (commit caeac86)
- `docs/design/withdrawal-bot-lane/README.md` + `schema.sql`
- `docs/design/bot-otp-relay/README.md` + `schema.sql`
- `docs/adr.md` — §ADR-4a §Amendment (+W6/W7/W8, header W1–W8), §ADR-6 OTP §Amendment (+OR4/OR5,
  OR1–OR5), §ADR-6 Telemetry §Amendment (+T5/T6, T1–T6). ALL ratification-pending / reviewer-gated.
- `next-architect_bbotp_revision_findings.md` (disposition map + handoffs)

## Handoffs
- **next-writer** owns the requirement-STORY ACs (I did NOT touch them). AC seeds: README §9.1 +
  bot-otp-relay §6.2 + findings §"For next-writer". Touches BBOT-010/011/012/013 + **BBOT-003**
  (the cross-story `dual_control` flag).
- **next-dev** named build deps (Phase B): pullout dest-credit (GAP-9), per-bank SMS parser
  (GAP-5i), failed→reconcile DiD (GAP-6), fair-router availability/90s filter (GAP-3/10 ride
  BOT-001..004), routing-layer min/max/outstanding caps (GAP-11).
- **next-code-reviewer** gates the W*/T*/OR* specifics (owner merges) — the OTP-amendment house pattern.

## Authority discipline
Owner-GO'd = the pull-forward + build-once + fix-the-#current-gaps SCOPE only. The W*/T*/OR*
specifics are architect-authored, reviewer-gated — NOT attributed to the owner. Out of my scope:
EF/migration code (next-dev), editing the stories (next-writer), marking done (next-pm).
