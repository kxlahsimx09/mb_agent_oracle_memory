# Handoff — Payout lane B+C BUILT (4 PRs staged, await owner merge + LIVE/B4)

**Filed:** 2026-06-14 by orchestrator (campaign bb2payout / bb2docsync). Follows handoff `2026-06-14_18-17_bbot-payout-lane-bc-handoff.md`.

## What got built (all FORK-INTERNAL, §9-compliant, NOT merged — owner-gated)
- **bot mb-next-bank-bot PR #15** — payout lane B1+B2+B3. **VERIFY-GREEN (next-tester) + REVIEW-APPROVE (next-code-reviewer).** B1 = graduate core/api.js client methods (claimItems/fetchProcessingItems/mark*/proof/checkpoint → the deployed bot-* EFs, payout-api.js mixin); B2 = payout-app.js + payout-runner.js + payout-marks.js ported from #current kokarat app.js (KTB batch-transfer 1-OTP / SCB maker→checker→approver dual-control, systemBankId forwarded); B3 = KTB mock transfer UI + SIM OTPService (bank_code=ktb). Branch campaign/bb2payout @6dc7d6a. Suite 86 tests / 80 pass / 0 fail / 6 Chromium-skip.
- **gateway mb-next-payment-gateway PR #503** — C-SEAL: ratify the 3 payout ADR amendments (§ADR-4a W1-W8, §ADR-6 OR1-OR5 + T1-T6) — confirmed against deployed migrations bbot010-013 + EFs (no discrepancies), status flipped ratification-pending → ratified. Epic-LIVE-DONE / §ADR-21 G2 kept PENDING the LIVE run.
- **bot PR #14** — doc-sync: current-system.md Phase-1-adapter-port staleness flag.
- **gateway PR #501** — doc-sync: build-workflow.md §ADR-21 LIVE gate → tri-epic (DEPOSIT/AUTH/PAYOUT).

## De-bias caught 6 money-safety bugs (test fakes had masked them) — all fixed + regression-locked
F1 KTB otpConfig 4th arg (OTP-expiry); F2 SCB fetchProcessingItems envelope→array bridge (double-pay-guard was dead); [1] safeMarkWaitingToReview→markFailed (uncertain→failed); [2] SCB submitted-unmatched→failed + matchedIds.size===0 fail-open; [3] mark/proof/checkpoint fail-open on 401/403; [4] KTB empty bank_ref→silent 400.

## OUTSTANDING (owner-gated — orchestrator cannot do)
1. **Merge** the 4 PRs (#15, #503, #14, #501) — held all session per owner.
2. **LIVE gate / B4 (§ADR-21):** deploy payout-app + KTB portal transfer UI + SCB dual-mode (PR #13) + provision payout-role creds (KTB transfer/maker; SCB maker+approver) → golden PAYOUT journey Mode SIM on staging → next-investigator L3 → owner live_signoff. brew-ops/owner + creds (role-isolated).
3. **Mark DONE** — next-pm only, after LIVE + seal.
4. **Follow-up (non-blocking, both gates agreed):** runScbBatch approver-EXCEPTION path (payout-runner.js:180-182) marks staged items failed on approverFlow throw (browser crash) — same double-pay class as [2] on the throw path; future-hardening (route staged→review on crash).

## Operational notes for next session
- Local checkouts of both bot + gateway were on STALE side-branches (bot 9 behind, gateway 237 behind origin/main) — always read/build from origin/main, not local HEAD.
- Filed learnings: `2026-06-14_orchestrator-dispatch-commit-templates...` (§9 no-AI-attribution overrides harness co-author default) + `2026-06-14_when-the-user-has-invoked-a-defined-workflow...` (follow the workflow, don't ask what it already defines).
- Oracle vector index (bge-m3 lance) degraded this session → arra_search FTS-only; worth repairing.
