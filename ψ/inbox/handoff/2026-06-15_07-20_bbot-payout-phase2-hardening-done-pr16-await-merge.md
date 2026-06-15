# Handoff UPDATE — Payout lane Phase-2 hardening DONE (supersedes 2026-06-14_21-57)

**Filed:** 2026-06-15 by orchestrator. Updates `2026-06-14_21-57_bbot-payout-lane-bc-built-4prs-await-merge.md`.

## Merged to main
- bot PR #15 (payout lane B1+B2+B3) — MERGED 2026-06-14. bot main @1ab39f6.
- bot PR #14 (doc-sync current-system staleness) — MERGED.
- gateway PR #503 (C-seal: 3 ADR amendments ratified) — MERGED.

## NEW — Phase-2 hardening, VERIFIED, await owner merge
- **bot PR #16** (branch campaign/bb2hard) — phase-2 hardening of the merged payout lane. **VERIFY-GREEN (next-tester) + REVIEW-APPROVE (next-code-reviewer).** Closes ALL the prior payment-safety defers:
  - H1 approver-CRASH staged-items→review (the open double-pay follow-up) — CLOSED
  - H2 KTB all-failed-batch browser recycle; H3 pre-claim checkApiHealth probe (money-safety nets re-ported from #current)
  - H4 failure_code wiring (classifyFailure→bank_timeout); H5 module.exports dedup; H6 SCB unmatched-under-review→review (W8 max-conservatism); H7 CLAUDE.md Phase-2 drift fix
  - Refactor: split core/payout-batch.js (201) out of payout-runner.js (→115) to hold ≤250. Suite 92 pass / 0 fail / 6 skip (pre-existing live-portal). 12 new real-path tests. §9 OK. banks/** untouched.

## OUTSTANDING (owner-gated / separate tracks)
1. **Merge** bot PR #16 + gateway PR #501 (tri-epic doc-sync — still OPEN).
2. **LIVE gate / B4 (§ADR-21):** deploy payout-app + KTB portal transfer UI + SCB dual-mode + provision payout-role creds → golden PAYOUT journey Mode SIM → next-investigator L3 → owner live_signoff. brew-ops/owner + creds (role-isolated).
3. **Mark DONE** — next-pm only, after LIVE + seal.
4. **Gateway Phase-2 / named-deferred** (architect SPEC; bigger): GAP-9 pullout dest-credit, GAP-6 failed→statement-reconcile DiD, GAP-5ii bot-otp-accounts, success proof_url blob-store.
5. **Minor fidelity nits from #16 review** (non-blocking, no money impact): H2 streak not reset on KTB_DOM_STUCK throw-recycle; H3 probe runs every tick (intended); KTB_DOM_STUCK generic-throw vs #current's saveStorage+RECYCLE.
6. **Infra:** current-system.md full re-baseline (writer); Oracle bge-m3 vector index repair (arra_search FTS-only).

## Pattern: the de-bias workflow earned its keep
Across PR #15 (3 rounds) + PR #16, next-tester/next-code-reviewer caught 6 money-safety bugs the dev's tests had MASKED (OTP-expiry, double-pay ×3, fail-open auth, silent 400) — all fixed + regression-locked before any merge. Run the VERIFY-by-falsification + REVIEW gates on every payment-path PR; never trust the dev's "tests green".
