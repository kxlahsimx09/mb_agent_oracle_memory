---
title: ruled-drift — stale-lock sweep mislabels uncertainty as failed (thread #24 resol
tags: [technical-writer, repo:mobiz-payment-gateway, current, followup, ruled-drift, scheduler, withdrawal-dispatcher, stale-lock-sweep-mislabels-failed, invariant-violation, w4-queued, thread-24-resolved, payout]
created: 2026-04-19
source: Oracle thread #24 resolution 2026-04-19 + learning 2026-04-19_drift-stale-lock-sweep-mislabels-uncertainty-as.md + invariant 2026-04-19_payout-state-semantic-invariant-ratified-2026-04.md
project: github.com/kokarat/mobiz-payment-gateway
---

# ruled-drift — stale-lock sweep mislabels uncertainty as failed (thread #24 resol

ruled-drift — stale-lock sweep mislabels uncertainty as failed (thread #24 resolved 2026-04-19: drift, fix later). Cross-references the drift-discovery learning `2026-04-19_drift-stale-lock-sweep-mislabels-uncertainty-as.md` which details the finding at `scheduler/withdrawal_dispatcher.go:788` where `services.MarkFailed` is called on items stuck `processing > 10 min` with an error message that itself admits uncertainty ("bot may have crashed. Check bank statement before retrying"). Human ruling 2026-04-19 via Oracle thread #24 confirms: (1) this is a real invariant violation under the cross-repo invariant ratified in thread #22 (`failed` = proof-negative-only; uncertainty → `waiting_to_review`), (2) the 1-line fix `MarkFailed` → `MarkWaitingToReview` is the correct shape, (3) queue for W4 pickup rather than immediate PR. Rationale for "fix later" not "fix now": defense-in-depth stack (`tryReconcileAfterMarkFailed` + `ConfirmPayoutCompleted`) has been masking the drift without customer-facing incidents; coherent batch with thread #16 (bot-side sibling) makes the observable change cleaner; admin UI + ops SOP must be ready to handle increased `waiting_to_review` volume before the fix lands (otherwise ops experience gets worse before better). **W4 pickup criteria:** prerequisite = thread #16 resolved or in-flight (paired fix), admin UI for `waiting_to_review` queue ready, 1-line code change + test covering bot-crash-mid-flow + ops rollout note. **Risk class:** low code risk, medium operational risk (changes status mix admins see). Thread #24 closed via `arra_thread_update(status="closed")`. Recorded as W8 child trace sibling of thread #22's resolution trace `6641fe94-0520-4afa-a9fd-d2636ee9bb14` under W8 root `a7dd9b6d-fea6-4123-a423-897b15950a51`.

---
*Added via Oracle Learn*
