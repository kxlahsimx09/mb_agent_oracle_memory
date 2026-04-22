---
title: ratified revision — flow ktb-single-transfer-withdrawal (S4 to S2 via Oracle thread 21, Q5 scope REVISE)
tags: [technical-writer, repo:bank-bot, current, flow, flow:ktb-single-transfer-withdrawal, ktb, withdrawal-queue, single-transfer, batch-transfer, ratified, s2, thread-21, revision]
created: 2026-04-19
source: docs/flows/ktb-single-transfer-withdrawal.md post-ratify (bank-bot PR 79); thread 21 closed 2026-04-19; mobiz sibling at 252849e
project: github.com/kokarat/bank-bot
---

# ratified revision — flow ktb-single-transfer-withdrawal (S4 to S2 via Oracle thread 21, Q5 scope REVISE)

Thread 21 ratified the spec on 2026-04-19 GMT+7 with six KEEP plus one REVISE. Supersedes the pending learning `2026-04-19_title-flow-ktb-single-transfer-withdrawal`.

## Verdicts

- **Q1 bank-specific slug `ktb-single-transfer-withdrawal`** — KEEP. Scb-dual-control-withdrawal precedent confirmed; bot-side per-bank slugs pair with the generic mobiz sibling `withdrawal-queue-single-bot-transfer`.
- **Q2 loop-wrapped mermaid variant** — KEEP. 12 actor crossings accepted (borderline against the 10-crossing cap). Consistency with scb-dual-control-withdrawal for readers jumping between bot-side docs.
- **Q3 `External:OTPService` actor framing** — KEEP. Reused verbatim from scb-dual-control-withdrawal.
- **Q4 drift marker carry-forward** — KEEP. `[AWAITING_THREAD:15]` (bankRef slot at `app.js:1642,1708`) and `[AWAITING_THREAD:16]` (waiting_to_review lost at `app.js:1640-1649, :1707-1714`) referenced from mobiz-side threads 15/16. No new bot-owned threads filed. Bot-writer closes the mobiz-side threads when the bank-bot code fixes land; the next W9/thread-resolve sweep strips the markers from both docs automatically.
- **Q5 scope boundary (login-with-OTP inclusion)** — **REVISE.** Login-with-OTP moved OUT of this doc's scope. Reason for split: the KTB login path is substantial enough (three-field fill, 120s dashboard wait, post-login OTP SMS→email fallback, `KTB_POST_OTP` handling at login vs transfer time) to warrant its own future W8 flow doc `ktb-login-with-otp`. This doc now:
  - removes Step 0a (login crossing) from the mermaid;
  - renumbers former Step 0b (first balance push) to Step 0a;
  - adds a mermaid `Note over` at Step 0 pointing future readers at the sibling flow;
  - keeps `banks/ktb/login.js:372-515 / loginIfNeeded` plus `:207-366 / fillOTP` as author hints in §Implementation pointers Step 0 so the future sibling's author has a running start;
  - §Preconditions continues to assume `init()` completed (including login) but defers mechanics to the sibling doc.
- **Q6 four KTB sentinels as first-class §Error paths entries** — KEEP. 13-entry §Error paths accepted as the right level of operator-debugging detail.
- **Q7 "single-session batch" naming disclaimer in §Purpose** — KEEP. Load-bearing for reading `processSingleTransfer` correctly.

## Transition

- Claim strength **S4 → S2**.
- Doc header carries `// ratified-via-thread:21` instead of `[RATIFICATION_PENDING:21]`.
- `docs/flows/.baseline` refresh `466d56e` → `1cf5e14` confirmed.
- Supersedes pending learning id `learning_2026-04-19_title-flow-ktb-single-transfer-withdrawal`.
- Thread 21 moved straight to `closed` (skipping intermediate `answered` per project feedback memory — see `feedback_thread_closure.md`).

## Deferred follow-up (follow-up W8 candidates surfaced by this pass)

- **`ktb-login-with-otp`** — covers three-field fill, 120s dashboard wait, login-time OTP (SMS then email), `banks/ktb/login.js::loginIfNeeded + fillOTP + ensureLoggedIn + checkSession + dismissPopups + isUIBlockedByBackdrop`. Cross-repo counterpart: unknown at ratification time; may share the generic mobiz-side login precondition that other bank modules also consume.
- **`bot-bootstrap-and-status-reporting`** — init, reportStatus online/offline/error/maintenance, shutdown. Noted as a remaining candidate from the original reverse-engineering scan.

## Related

- W8 root trace: `ae42fef8-b445-4f13-ad0f-0e0ca7a05b7c` (bank-bot side).
- DoD-anchor child trace: `55d81b28-414a-4c96-a724-0c13488287cd` (populates `found_learnings`).
- Cross-repo sibling W8 trace: `6afbf4f9-e19e-4b63-8a9e-26e23f941154` (mobiz side, ratified S2 via mobiz thread 13).
- PR: kokarat/bank-bot#79 (initial doc + baseline refresh + ratify amendment).

---
*Added via Oracle Learn*


---
*Added via Oracle Learn*
