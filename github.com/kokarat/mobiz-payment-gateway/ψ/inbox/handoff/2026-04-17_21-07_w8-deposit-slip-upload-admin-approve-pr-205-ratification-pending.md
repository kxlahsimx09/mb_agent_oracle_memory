# Handoff — W8 deposit-slip-upload-admin-approve (PR #205, ratification pending)

**From:** `pg-writer-oracle` (Claude session on dev01, 2026-04-17 GMT+7)
**To:** next `pg-writer-oracle` session, or the human reviewer of PR #205

## What I did

- Ran W8 flow-map for slug `deposit-slip-upload-admin-approve` at HEAD `c5270b3`.
- Authored `docs/flows/deposit-slip-upload-admin-approve.md` (10 sequence steps, 9 impl-pointer groups, 0 unimplemented, 0 drift).
- Cross-linked from `docs/current-system.md` §3.3 beside the existing `deposit-qr-request` link.
- Filed Oracle learning `learning_2026-04-17_flow-deposit-slip-upload-admin-approve-intent` (tags include `technical-writer`, `repo:mobiz-payment-gateway`, `current`, `flow`, `deposit-slip-upload-admin-approve`, `ratification-pending`).
- W8 root trace: `4b076751-86c5-42b6-ba5a-e3dfea9ea6b3`.
- Branch: `docs/flow-deposit-slip-upload-admin-approve`, **stacked on `docs/flow-deposit-qr-request`** (PR #204).
- PR: **https://github.com/kokarat/mobiz-payment-gateway/pull/205** — base is `docs/flow-deposit-qr-request`, not `main`, to isolate the diff for review.

## What is blocked

- Claim strength is **S4**. `[RATIFICATION_PENDING:6]` in the doc header must stay until Oracle thread #6 (ratification) is human-answered.
- PR #205 is stacked on PR #204. PR #204 must merge first, then PR #205 should be re-targeted to `main` (or merged together).
- I did **not** merge anything. Both PRs await human review.

## What the next agent needs

### Two Oracle threads pending answers

- **Thread #6** — general ratification. Three sub-questions:
  - (a) Is the admin-only bypass of the `transRef` duplicate guard at `controllers/DepositController.go:1954-1973` an intentional support-workflow policy, or a leftover that should log+warn instead of silently bypass?
  - (b) Is the silent-skip on inactive-partner / missing-partner-wallet MDR shares (`DepositController.go:902-908`) acceptable, or should we emit an `mdr_skip` audit row?
  - (c) The non-paid branch (admin reject) does NOT write `approved_by`/`approved_by_type`/`approved_at` — is this intentional (reject is not an approval-decision event) or drift?
- **Thread #7** — `wallets_change_logs.operation` divergence. Admin-approve path writes `"deposit"`; matcher path writes `"deposit_match"`. Is this intentional segmentation for ops reporting, or drift that should converge?

### Same-day revision expectations

Once thread #6 is answered, open a revision pass (no new file — edit the existing doc):
- Apply corrections from the human answer.
- Drop `[RATIFICATION_PENDING:6]` from the doc header.
- Upgrade claim strength header line S4 → S2 (per the ratification tier in the W8 workflow).
- Append a same-day revision entry to §Change log, citing a new W8 revision trace chained to `4b076751-86c5-42b6-ba5a-e3dfea9ea6b3`.
- Supersede `learning_2026-04-17_flow-deposit-slip-upload-admin-approve-intent` with a revised learning tagged `ratified` instead of `ratification-pending`.
- (Precedent: `deposit-qr-request` went through this exact sequence on 2026-04-17 — see commits `4e2f8a6` → `1b44f87` → `c5270b3` + the `ratified-revision-s4` supersede on its learning.)

## Notable facts surfaced (may be useful cross-repo)

- `status: "checking"` is intentionally invisible to the matcher (`services/transactionMatcher.go:594` guard). This is the *mechanism* that makes the admin-approve flow distinct — no timer, no competing automation, just a state the matcher refuses to touch.
- The atomic Mongo session at `controllers/DepositController.go:760-999` is the single largest admin-side financial code path I've seen in this repo (deposit CAS + wallet $inc + client change log + per-partner MDR fan-out + mdr_shared summary, all in one session).
- The reject branch's missing approval-audit (`approved_by`/`_at`) is a real policy question (thread #6c). Ops may want to know *which admin rejected* a deposit as much as which approved, and the current code drops that data silently.

## Pointers for quick navigation

- Doc: `docs/flows/deposit-slip-upload-admin-approve.md`
- Sibling flow: `docs/flows/deposit-qr-request.md` (ratified S2; this doc references it in §Related flows)
- Key controllers: `controllers/DepositController.go:687` (admin approve), `:1843` (admin slip upload), `controllers/DepositRequestController.go:794` (client slip upload)
- Thunder adapter: `services/thunderSlipVerify.go`
- Retrospective: `~/.arra-oracle-v2/ψ/memory/retrospectives/2026-04/17/21.05_flow-deposit-slip-upload-admin-approve.md`
