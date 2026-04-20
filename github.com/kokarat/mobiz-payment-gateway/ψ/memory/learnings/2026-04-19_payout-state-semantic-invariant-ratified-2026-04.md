---
title: Payout state semantic invariant (ratified 2026-04-19 via Oracle thread #22).
tags: [technical-writer, repo:cross, current, invariant, principle, payout, failed, waiting-to-review, state-semantics, design-rule, proof-negative-only, thread-22-ratified, cross-repo-invariant, repo:mobiz-payment-gateway, repo:bank-bot]
created: 2026-04-19
source: Oracle thread #22 ratification 2026-04-19 + docs/flows/payout-confirm-completed.md + PR #231 + cross-repo-sync with kokarat/bank-bot (threads #16 + #24 reference)
project: github.com/kokarat/mobiz-payment-gateway
---

# Payout state semantic invariant (ratified 2026-04-19 via Oracle thread #22).

Payout state semantic invariant (ratified 2026-04-19 via Oracle thread #22).

**Rule:** On the payout rail (`ts_payouts.status` + `withdrawal_queue.status`), mark `failed` **only** when there is proof that the money did not leave the bank (proof negative). Any uncertainty — OTP failed mid-flow, popup/parse ambiguity, bot crashed after submit, network timeout after submit, stale-lock sweep on crashed bot — belongs in `waiting_to_review`, not `failed`. Admin must resolve `waiting_to_review` against bank statement evidence.

**Origin:** Articulated and ratified by human in 2026-04-19 in-session pg-writer Claude Code discussion during the `payout-confirm-completed` W8 flow review (PR #231, thread #22). Verbatim ratification: *"failed = proof negative only (พิสูจน์ได้ว่าเงินไม่ออก); uncertainty → waiting_to_review เห็นด้วยเลย"*.

**Why it is load-bearing:** The whole existence of `tryReconcileAfterMarkFailed` goroutine + `ConfirmPayoutCompleted` accepting `failed` as entry state are **defensive patches for upstream violations of this invariant** — not features. The `waiting_to_review` state was specifically designed to receive uncertainty; using `failed` for uncertainty is a design error that cascades into callback double-send, client wallet refund-then-spend races (payout-request §Resolved questions (b)), double-transfer risk (client retries on `failed` callback while bank actually moved money), and manual reconciliation burden.

**Scope:** cross-repo. This invariant governs code in BOTH `mobiz-payment-gateway` and `kokarat/bank-bot`:
- `mobiz-payment-gateway`: all paths that set `ts_payouts.status = "failed"` or call `services.MarkFailed` / `MarkWaitingToReview`
- `kokarat/bank-bot`: all paths that call `safeMarkFailed` / `safeMarkWaitingToReview` / `safeMarkSuccess` (bot dispatcher + bank-layer modules)

**Known violations at 2026-04-19 HEAD (all require fix to become invariant-compliant):**

| Violation | Location | Thread | Status |
|---|---|---|---|
| Bot dispatcher flattens waiting_to_review to failed | `bank-bot/app.js:1640-1648` (single + batch branch) | Oracle #16 | pending (bot-writer) |
| Stale-lock sweep mislabels uncertainty as failed | `mobiz/scheduler/withdrawal_dispatcher.go:788` | Oracle #24 | pending (mobiz) |
| Admin endpoint PUT /withdrawal-queue/:id/failed — no evidence guard | `mobiz/controllers/WithdrawalQueueController.go:368-383` | Oracle #12 classified as "debug/legacy" | deprecation candidate |
| Admin endpoint PUT /payouts/:id/status status=failed — no evidence guard, cascade asymmetry | `mobiz/controllers/PayoutController.go:842-891` | — | separate class (evidence-guard design) |
| Admin endpoint PUT /payouts/:id/override target=failed — no evidence guard | `mobiz/controllers/PayoutController.go:1498-1729` | — | separate class (evidence-guard design) |

Auto-paths (first two) close the most frequent violations. Admin-discretion paths (last three) are a separate concern class — fix pattern is evidence-guard design, not 1-line state change.

**How to apply:**
1. **Code review (both repos):** when reviewing any PR that transitions a payout to `failed` or calls a `MarkFailed`-flavored helper, ask: *"is this proof negative or is this uncertainty?"* If uncertainty, reject unless routed through `MarkWaitingToReview` / `safeMarkWaitingToReview`.
2. **W8 authoring:** flow docs that touch the payout rail must cite this invariant in §Purpose or header so the semantic is load-bearing in the doc, not implicit in code.
3. **W1/W2 baselines:** when surfacing new `MarkFailed` call sites in code-path scans, treat each as a candidate invariant violation; file a `#drift + #invariant-violation` learning if the call context does not guarantee proof-negative.
4. **Bot-writer specifically:** when reviewing bank-layer modules (`banks/<code>/transfer.js`, etc.), note that several bank layers already produce correct `waiting_to_review` values (e.g. `banks/ktb/transfer.js:159` distinguishes `KTB_POST_OTP → waiting_to_review` vs other errors → `failed`). The common violation class is the **app-layer dispatcher** collapsing them back to `failed` — preserve bank-layer intent through the dispatcher.
5. **Deprecation paths on the table:** `ConfirmPayoutCompleted` endpoint's `failed` entry branch is a deprecation candidate once upstream drifts (threads #16 + #24) are fixed; canonical usage becomes `waiting_to_review → completed` only. Tracked in `2026-04-19_drift-flowpayout-confirm-completed-a-failed.md`.

**Related:** `confirm-failed` endpoint doesn't exist yet (payout-request §Resolved questions (c)). If built, apply the same invariant — it resolves `waiting_to_review → failed` after admin verifies the bank did NOT transfer. Symmetric pair with `confirm-completed`.

**State vehicle:** this Oracle learning is the cross-repo canonical reference. Pg-writer also has a session-memory copy at `/Users/dev01/.claude/projects/-Users-dev01-Code-github-com-kokarat-mobiz-payment-gateway/memory/feedback_payout_state_invariant.md` for zero-latency recall without `arra_search`. Session-memory copy is a convenience mirror; Oracle learning is the source of truth.

---
*Added via Oracle Learn*
