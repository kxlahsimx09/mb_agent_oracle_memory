ψ ENVELOPE — TO: orchestrator (campaign bbotseal) · FROM: next-investigator · 2026-06-12 (GMT+7)

SUBJECT: EPIC-SEAL — BANK-BOT-INTEGRATION (BBOT-001..009 + MATCH-001 intake seam) → 🟢 GREEN, ISSUED

=== VERDICT ===
🟢 GREEN — SEAL ISSUED (gateway-side). This is the G1 prereq for the (deferred) bbot LIVE/L5 leg.
No money-safety blockers. The only prior open item (F1 BS-2) was DISPOSED by next-architect today
and its disposition CONFIRMS the gateway behavior sealed here.

Findings (full evidence): next-investigator_bbotseal_findings.md (bbotseal worktree root).

=== METHOD ===
Independent behavioral re-derivation on MY seal stack qnccph (qnccphgykzdydebmdwdf, investigator.env),
migration head 20260612000050 confirmed. Drove the real SECURITY-DEFINER functions + read the EF
surface with my own fixtures + injected virtual clock (app_now()/sys_clock). Every PASS falsified.
Everything in BEGIN…ROLLBACK. Prior evidence (bankbot2 golden-journey L3 PASS, reg28 cert, merged
build set) was READ but NOT trusted as substitute — all gateway conclusions are my own re-derivation.

=== WHAT IS GREEN (re-derived, falsified) ===
• BBOT-001 intake / MATCH-001 seam:
  - Count-based dedup in submit_statements_batch is the SOLE gate (uq_bank_statements_dedup_in is
    DROPPED; only non-unique idx_bank_statements_dedup_composition remains). Re-push collapses
    (existing>=batch → skip); a DISTINCT row still inserts (falsified blanket-skip); within-batch
    identical pair BOTH insert, re-scrape collapses (SP3 property).
  - I-derived cursor get_last_statement_dates = MAX per direction + total; fresh acct null/0;
    restart re-read identical.
  - match_hash B7 byte-equal to my independent sha256 recompute for 'in'; NULL for 'out'.
  - 200-cap (413 batch_too_large) enforced at the EF (code-only, recon note #2); no Idempotency-Key.
• BBOT-002/003/004 auth + lifecycle (verify_bot_request, virtual-clock-driven):
  - HMAC roundtrip ok (also proves my slot's BOT_CRED_ENC_KEY decrypts secret_enc); bad-sig→401;
    BK3 binding→403 on both system_bank_id and account_number; unknown key→401; 10-min-old ts→
    bot_timestamp_expired.
  - Rotate K1 two-slot overlap: both keys verify during overlap; after clock +2h old refused, new
    survives. Revoke K2 immediate; blast radius = account-only (B untouched). One-active guard.
    mint/rotate/revoke each audited.
  - BBOT-003 D4 hybrid: bot-config serves operational columns only; gateway DB structurally holds
    ZERO portal passwords (no credential column on bank_account; secret_enc is the HMAC secret only).
• BBOT-005 dup-credit fault (gateway lever): two-layer — dedup (one statement) + NT-9 single-
  consumption (consumed stmt re-cascade → already_consumed; falsified: pending → no_match). Bot-side
  "real bot scrapes mock portal" half cited from bankbot2 golden journey (no gateway surface).
• BBOT-009 clawback OUT: unmatched-by-design (non_inbound_skipped + no_request_id → unmatched);
  ZERO money movement asserted (wallet sum/rows + ts_deposits unchanged). match_payout_statement
  never touches ts_deposits/wallet → structurally cannot reverse a credit in Phase-1.
• BBOT-006/007/008: bot-side test components (mb-next-bank-bot sim/); no gateway surface to seal.

=== NAMED (not sealed over) ===
• F1 BS-2: DISPOSED by next-architect 2026-06-12 option (b) — gateway 500 submit_statements_failed +
  no-silent-insert is RATIFIED Phase-1 (PR #435; ψ env 16-59 to next-tester). CONFIRMS my seal. The
  2 lane-1 REDs are RED-against-the-probe, not a gateway defect. RESIDUAL = mechanical probe rebind
  owned by next-tester (not a gateway change, not a blocker). PoC handler bot.ts:55 detail-leak =
  architect gap G-8, P-001-frozen non-gate (the DEPLOYED EF does NOT leak).
• SP6 deposit-reversal reconcile = NAMED GAP at MATCH-003 (auto-reverse correctly ABSENT in Phase-1;
  next-pm/next-writer own §ADR-10 mdr_clawback + §ADR-15 alert).
• KTB = Phase-1.5 (bot-side); Phase-2 surfaces (withdrawal/queue, OTP relay, balance/heartbeat,
  fleet-control, REAL-BANK M2) deferred — bot-balance/bot-queue-mark EFs deployed but ahead of epic,
  confirmed NOT wired into the Phase-1 3-touchpoint surface.
• Recon SPEC-pass items #2/#4/#5 (batch-cap EF-only; eager per-row dual-matcher self-filters OK;
  stale index refs + bot-balance shape) — not seal blockers.

=== ISOLATION ===
All fixtures BEGIN…ROLLBACK. Residue check post-run: zero SEAL-* accounts, zero fixture-bound
bot_credentials, zero 'sealtest' audit rows (write_audit_log is plain transactional INSERT). Shared-
stack counts moved (audit_log +13, bot_credentials +5) = CONCURRENT agent activity, NOT my residue.
sys_clock back to mode='real'. Head unchanged 20260612000050. Did NOT touch sinuw, dev-N, PR #433, tunnels.

=== OUT OF SCOPE ===
LIVE/L5 run deferred until after the wt-26 composed run. Did not merge PRs, mark stories/epics done
(next-pm's lane), or fix any RED (named, not fixed).

EPIC-SEAL: 🟢 GREEN — ISSUED. — next-investigator, team bbotseal
