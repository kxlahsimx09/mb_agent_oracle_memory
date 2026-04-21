---
title: drift — deposit-auto-expire-pending — step-7 resend function pointer-accuracy (ResendPendingCallbacks → ProcessPendingCallbacks)
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, pointer-accuracy, flow:deposit-auto-expire-pending, step:7, callback]
created: 2026-04-21
source: docs/flows/deposit-auto-expire-pending.md@26a62fa + services/callbackService.go:385-459@26a62fa
project: github.com/kokarat/mobiz-payment-gateway
related:
  - learning_2026-04-19_flow-deposit-auto-expire-pending-ratified-revi  # parent ratified-revision learning
  - learning_2026-04-19_drift-deposit-auto-expire-pending-step-7-callb  # prior drift against the same step, behavioral scope
  - learning_2026-04-19_regression-candidate-callback-resend-scheduler  # paired W4 queue item
trace: 896be907-70d0-4d7f-a0b3-097b5c84a6b4
prev_trace: 43ead641-96bd-49f3-9813-53b69ffaab84
---

# drift — deposit-auto-expire-pending — step-7 resend function pointer-accuracy

## Class

Pointer-accuracy drift introduced at W8 authoring time (2026-04-19), discovered during adopt-from-branch refresh pass (2026-04-21). Not code drift — code never moved. The doc cited a function name that did not exist in the cited commit.

## Claim the doc made

Initial W8 pass on `docs/flows/deposit-auto-expire-pending.md` (commits `e355e91` + `8d69585`, authored 2026-04-19 against baseline `153a4f6`) cited in both §Error paths and §Implementation pointers step 7:

> `services/callbackService.go:379-422` defines `ResendPendingCallbacks()` which would periodically retry stale callbacks …

## Reality at the same commit

`git show 153a4f6:services/callbackService.go | sed -n '378,425p'` returns:

```
// ProcessPendingCallbacks processes callbacks that failed and need retry
func (s *CallbackService) ProcessPendingCallbacks() error {
    … 
    (deposit section: :385-421)
    (payout section:  :423-459)
}
```

Function is named `ProcessPendingCallbacks`, spans `:385-459`, never had the identifier `ResendPendingCallbacks` in this repo's history (`git log --all -S ResendPendingCallbacks -- services/callbackService.go` returns zero commits).

## Behavioral claim is unaffected

Ratification via thread #19 (2026-04-19 GMT+7) confirmed three behavioral properties:
1. Function exists but has zero production callers — **still true** at `26a62fa` (`grep -rn ProcessPendingCallbacks` outside `.claude/worktrees/*` returns only the definition).
2. Human's intent: "เขียนทิ้งไว้ยังไม่ได้ใช้" — draft for later wiring, not dead code. Behavior unchanged.
3. Follow-up must pair resend-wiring with an idempotency guard beyond the existing `callback_sent` flag. Unchanged.

Identifier correction does not invalidate the ratification. The human's Q-b and Q-d rulings hold verbatim under the corrected name.

## How did this slip past both W8 author and thread-#19 ratification?

Hypothesis (cannot be proven retroactively): the initial author read `services/callbackService.go` for the retry-loop logic (:156-168), then guessed the name of the never-wired resend function from context (every adjacent payout-side function is named `Send…Callback` / `Process…Callbacks`; `Resend…Callbacks` is a plausible-sounding adjacent identifier). The thread-#19 human ratified the behavioral claim — they responded to "function ที่เขียนทิ้งไว้ยังไม่ได้ใช้" without fact-checking the identifier. Two-sided miss: author didn't re-grep; reviewer didn't grep either.

Defensible fix for future W8: Step 5 impl-pointer verification should end with a literal `grep -rn <FunctionName> .` copy-pasted into the retro, so a reviewer sees the grep output (or its absence) as evidence the name is real.

## Fix applied at 2026-04-21

Refresh pass updated four places in `docs/flows/deposit-auto-expire-pending.md` (under the adopt-from-branch refresh commit):

- §Claim-strength header: added a **Pointer correction (2026-04-21 refresh)** note pointing at this learning.
- §Error paths "Callback delivery failure — all 3 attempts exhaust": `:379-422 ResendPendingCallbacks()` → `:385-459 ProcessPendingCallbacks() (deposit sub-section :385-421)`.
- §Error paths "Scheduler process killed mid-tick": `Combined with the ResendPendingCallbacks gap` → `Combined with the ProcessPendingCallbacks gap`.
- §Implementation pointers step 7: `:379-422 ResendPendingCallbacks()` → `:385-459 ProcessPendingCallbacks() (deposit sub-section :385-421, payout sub-section :423-459)` + updated the inline `grep -rn` invariant.
- §Resolved questions (b): heading `(b) ResendPendingCallbacks with zero callers` → `(b) ProcessPendingCallbacks with zero callers`.
- §Resolved questions (d): body `the same ResendPendingCallbacks function serves both cases` → `the same ProcessPendingCallbacks function serves both cases`.
- §Change log 2026-04-21 entry records the refresh + the pointer fix + the zero-diff re-verification.

Historical §Change log entries 2026-04-19 (both initial-authoring and thread-#19-ratification) retain the `ResendPendingCallbacks` wording verbatim per P-001 — readers can diff the two identifiers and trace the correction trail. The Q-b phrasing in the §Claim-strength header also retains `ResendPendingCallbacks` because it paraphrases the thread-#19 dialogue; the header's Pointer-correction note points to the corrected identifier in live sections.

## Why this is not a W4 queue item

No code change is needed. Behavioral drift — the zero-callers latent gap — is already tracked by `2026-04-19_regression-candidate-callback-resend-scheduler` (W4-queued). This learning records the pointer fix and closes the identifier-accuracy loop. No separate W4 item.

## How to prevent

W8 workflow Step 5 should include a verification sub-step before writing the pointer range:

```bash
grep -n "<FunctionName>" <file-path>
```

If zero hits inside the cited file, the claim is false. The output (or `no matches`) should be copied into the retro as evidence. This preserves the one-way property: a doc can only claim a function name exists if grep at the cited commit agrees.

A SKILL.md edit proposing this sub-step is out of scope for this learning; the pattern would need a separate cross-repo sync learning tagged `#sibling-drift` so `next-writer` / `bot-writer` pick it up too.
