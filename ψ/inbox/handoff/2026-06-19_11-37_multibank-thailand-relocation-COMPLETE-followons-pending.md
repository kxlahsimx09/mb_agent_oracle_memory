# Handoff — Multibank fair-router + Thailand relocation: CORE COMPLETE, follow-ons pending

**Date:** 2026-06-19 (GMT+7 11:35) · Orchestrator · campaign `multibank` (+ live-coverage/reconcilelegs/createpayoutfix/adrcheck arcs). Session CLOSED at owner request before the follow-on work.

**Full retro:** `ψ/memory/retrospectives/2026-06/19/04.35_orchestrator-multibank-thailand-relocation.md`
**State carrier:** auto-memory `campaign-multibank-fairrouter.md` (has every decision + the follow-on list).

## DONE
- bbot LIVE re-runs all-green; L2a-dup-fault NON-VACUOUS via a least-priv restart-only IAM key (`mb-next-bbot-restart`).
- Multibank fair-router GREEN (deposit+payout spread 0, per-login isolation, 3 SCB / 1 multi-account mock portal).
- **Full Thailand relocation DONE:** bankbot cluster in `ap-southeast-7`, per-account 2-service (statement+payout, no shared payout), SG fleet decommissioned, **§ADR-9 merchant EIP preserved**. **A + B + C + fair-router all GREEN on TH, no regression (0 RED).** (B's 1 AMBER = flaky cloudflared callback delivery, env not regression.)
- Found+fixed a PROD bug existing tests missed: `create_payout` Mode-1 42702 (#613).

## OPEN PRs (owner reviews/merges — I never merge)
#614 (fair-router harness + TH wiring), #613 (create_payout fix), #31 (multi-account portal, mb-next-bank-bot), #607 (B↔C restart split).

## OUTSTANDING follow-ons (owner-deferred to after close)
0. **DOC the journey tests** (owner): update journey docs (live-test-journey.md, bbot-coverage-matrix.md, bbot-live-journey.md + doc-site) to the CURRENT landscape = **4 journeys** — A (tri-epic, admin/full; ACT-B-only until UUID-overlap fixed), B (bbot-automatch, now RESTART-FREE post-#607 split), C (bbot-restart, NEW #607: L2a-dup-fault + P1 III.5-reconcile + P2 amount-mismatch), fair-router (bbot-fairrouter, NEW #614: multibank deposit+payout). Per-journey deltas to write: ap-se-7 TH cluster + per-account 2-service topology; B's restart legs → C; III.5 now live-via-C (supersede the #601 "live-planned" note); create_payout fix #613; multi-account per-login portal.
1. **bank-cleanup** (owner ฝาก): delete "system banks" with no live bot AND not used in any journey (KBANK etc.); KEEP if Journey A uses; audit-before-delete. Now auditable (B/C SCB-only; KTB has a bot but untested).
2. **UUID-overlap fix (structural):** tri-epic olive cast `0117e000-…0001/2/3` overlaps the TH SCB fleet → A's ACT B clobbered scb1's cred (remediated). Give the fleet distinct IDs OR gate ACT B; interim = run A dry-validate-only.
3. **stale `staging.env` PORTAL_BASE_URL=18-136-227-108** (retired) → brew-ops update.
4. **EIP / fixed-Thai-IP + §ADR-6 BF9** = deferred to real-bank integration (verify if target Thai banks allowlist per-IP → amend BF9, else residential egress; compute-region is decoupled per BF8).

## Fleet
All MY teammates closed/verified-dead; worktrees KEPT (open PRs + follow-ons need them). `next-pm@buildepic2` is a different campaign's agent (not mine — left per §151).
