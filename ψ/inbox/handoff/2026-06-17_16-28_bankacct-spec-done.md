# [for orchestrator/owner] /bank-accounts requirement docs DONE — epic + ADR authored to current-system parity (DOCUMENTS ONLY, owner-gated PRs)

**From:** next-architect (system-architect, campaign `doc-bankacct-spec`) · **2026-06-17 (GMT+7)** · **Re:** owner decision = PARITY WITH CURRENT for the `/bank-accounts` beneficiary registry

## TL;DR
Both requirement docs authored to **current-system parity** and opened as **owner-gated PRs (NOT merged)**:
- **Portal PR #43** — `mb-next-admin-portal` `docs/requirements/epic-bank-account-ui.md` (+ INDEX), stories **WUI-201..205**. https://github.com/kxlahsimx09/mb-next-admin-portal/pull/43
- **Gateway PR #557** — `mb-next-payment-gateway` `docs/adr.md` **§ADR-22** (Beneficiary Bank-Account Registry). https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/557

Branched off `origin/main` in each repo (`arch/bank-account-ui-spec`). Grounded in code/DB per P-004; **DOCUMENTS ONLY** — build chain (next-dev→brew-ops→next-ui) NOT started.

## Parity findings (dpay prod `bank_accounts`, 126 docs + mobiz Go @ HEAD `03d6383`; two independent sub-agents cross-corroborated — dpay MCP was FUNCTIONAL, unlike the §ADR-18 incident)
- **Submission = client/partner SELF-service** (in this multi-tier portal). `CreateBankAccount` derives owner from JWT and **REFUSES the admin user-type** (`:86-91`) — no admin-on-behalf. Admin role only approve/reject (one `bank-account:approve` perm) + super_admin edit/delete.
- **status** = int 0/1/2 = pending/approved/rejected (consts `:46-50`) — mock's `pending|approved|rejected` IS parity-faithful (0 rejected ROWS in prod today, but the state exists in code; code = truth).
- **purpose** = array of `topup|settlement` — mock's `deposit|payout` is DRIFTED; resolved to `topup|settlement`. Partner = settlement-only; client = topup and/or settlement.
- **account_number** = full plaintext, NO masking to any caller; per-caller difference is ROW VISIBILITY (tenant filter), not column mask. Spec'd via a leak-safe read mirroring v_deposits (security_invoker + RLS; full within RLS-visible rows).
- **NO payout-destination linkage** (both agents): the registry is NEVER consulted server-side by payouts/settlements/topups; destinations are free-form inline (`ts_payouts.dest_*`, `SettlementController.go:37-38/327-328`). `GetApprovedBankAccounts` is a client-side picker convenience only.
- Limits client 5 / partner 3; duplicate (owner+bank_code+account_number) guard; 2FA-if-enrolled on create/delete/set-default; set-default approved-only.
- **NEW table required**: existing next-gateway `bank_account` is the §ADR-4a SYSTEM/operator bank — different entity → ADR-22 introduces `beneficiary_bank_account`. **NEW §ADR-13 F3 RBAC resource `bank-account`** (not in the 33-resource list; that has `system-bank`).

## OPEN OWNER DECISIONS (current has NO equivalent of what the mock implies — flagged, not guessed)
1. **[ESCALATE / RATIFICATION_PENDING] ENFORCED payout-destination linkage** (the material one). Current production has ZERO server-side registry↔payout linkage; "match current" ⇒ the registry is **advisory only** (an approved `purpose=payout` account carries no backend authority over a payout). Confirm: keep advisory (parity) vs add NEW enforced linkage (payout MUST reference an approved registry id). Enforcement = new behaviour, out of scope for this parity pass. Marker `[ESCALATE_TO_HUMAN]` is in the epic; `[RATIFICATION_PENDING:owner]` (b1) in §ADR-22.
2. **purpose enum** — resolved to `topup|settlement` by parity (mock `deposit|payout` was drift); recorded for owner awareness.
3. **admin create-on-behalf** — parity = self-only; confirm not wanted.
4. **24h approval cooldown** — shown in the current maxpay UI but no backend guard located in `ApproveBankAccount`; likely UI-tier — confirm at impl.
5. **single-step / single-approver approval** — parity (no maker/checker); confirm.

## Trust + next step
Epic stories tagged **S3 provisional** (ground on the `#provisional` §ADR-22) — **flip to S2 on owner ratification of §ADR-22**. On ratification, the build chain may be dispatched (separate owner-authorized phase). Until then, leave the `/bank-accounts` mock in place.

## Operational note (recorded as a durable learning)
The `mb-next-payment-gateway` PRIMARY checkout is SHARED — a concurrent agent branch-switched it mid-task and my first ADR-22 commit landed on their `chore/wf7-migfix...` branch. Recovered via an isolated `git worktree` (cherry-pick → push → PR) + a guarded reset that restored their branch exactly. Learning written: always use a worktree for gateway commits, never the shared primary.

## Memory
- arra_learn: parity finding (`2026-06-17_parity-current-production-bank-accounts-the`) + the shared-primary gotcha (`2026-06-17_gotcha-shared-primary-race-never-git-switchc`).