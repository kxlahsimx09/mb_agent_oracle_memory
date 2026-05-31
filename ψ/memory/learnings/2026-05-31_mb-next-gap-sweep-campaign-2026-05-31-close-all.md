---
title: mb-next gap-sweep campaign — 2026-05-31 CLOSE: all 5 PRs merged, read-time fraud
tags: [orchestrator, team-dispatch, mb-next-payment-gateway, campaign-resume, gap-sweep, pr-282, pr-283, pr-284, pr-285, pr-286, read-time-fraud-badge, dl3-ratified, settle-002, dtr-001, backlog, repo:arra-oracle-v3, fleet]
created: 2026-05-31
source: orchestrator session 2026-05-31; main HEAD b92f9a1; PRs #282-286 all merged
project: github.com/soul-brews-studio/arra-oracle-v3
---

# mb-next gap-sweep campaign — 2026-05-31 CLOSE: all 5 PRs merged, read-time fraud

mb-next gap-sweep campaign — 2026-05-31 CLOSE: all 5 PRs merged, read-time fraud badge KEPT. Resume point for backlog.

All merged to main (origin/main HEAD b92f9a1). Verified on main: DL3 read-time fraud-preview advisory badge RATIFIED; DEPOSIT-007 read-time badge wording intact; SETTLE-002 = S2; 0 open PRs; all campaign branches/worktrees cleaned.

MERGED (in order):
- #282 — 3 quick-wins (CALLBACK-001 30s timeout §ADR-9 WC9; AUTH-007 step-up per-purpose replay §ADR-2 S3; INDEX PAYOUT-011 deferred §ADR-4a RR4)
- #283 — 4 ADR-backed AC adds (PAYOUT-001 unroutable-by-band §ADR-8 AF2; MATCH-003 payout-driven trigger §ADR-4a RR1; WALLET-003 is_owner §ADR-10 D1; CLIENT-001 cached-4xx replay §ADR-11 C4)
- #284 — 3 HIGH ADR amendments (§ADR-12 Settlement Confirm-Review CR1-4; §ADR-12 DT-override DTO1-4 step-up REQUIRED option(a); §ADR-13 admin deposit read-surface DL1-3)
- #285 — SETTLE-002 confirm-review story S3→S2 + DTR-001 reconciliation-override story (DEPOSIT-007 badge downgrade WITHDRAWN per user reversal)
- #286 — §ADR-13 DL3 PROMOTED: read-time fraud-preview advisory badge ratified #decision as a deliberate next-system addition (prod runs fraud only at approve-time). Advisory-only, no money effect, Layer-2 approve-time wins → within architect authority. user GO 2026-05-31.

KEY USER DECISIONS (binding): (1) next-system holding state is `review`, never `waiting_to_review`. (2) a plain Direct-Transfer NEVER touches a wallet — DT override is pure status reconciliation review→{completed,failed}, no freeze; only DTR-002 deposit-refund (Phase-2-deferred) touches a wallet. (3) DT override step-up = REQUIRED (option a). (4) KEEP read-time fraud-preview badge in DEPOSIT-007 — reversed an earlier downgrade; DL3 flipped carve-out→ratified.

SMALL FOLLOW-ON (not urgent): DEPOSIT-007 Sources should add a cite to §ADR-13 DL3 next time epic-deposit.md is touched — badge wording is restored-from-main and still cites old ADR context.

BACKLOG NOT YET DISPATCHED (needs user GO; money-safety/new-ADR → escalate per charter §9): 5 new-ADR — provisioning epic (admin CRUD merchant/client/partner/pool/system-bank/MDR-profile — BIGGEST, every flow depends on it); deposit QR/fee config; pullout-task CRUD; client API-key lifecycle. + ~8 medium amendments — idempotency-store fail-open; topup filter + residual-MDR routing; fleet reboot-ack health; admin audit-log query surface; monitoring wallet-high-balance alert + hourly/daily ops-report; callback redirect-chain + gateway-identity header. Full 31-gap dump: session transcript tool-results/bvfhrnuq7.txt.

PROCESS NOTE: when re-dispatching to an already-finished campaign slug, the worktree may be stale/on wrong branch — pre-create the worktree on the target PR branch (git worktree add <wt> <pr-branch>) + inject .agent/.secrets symlinks before spawning, OR use a fresh slug. Re-dispatching same slug after finish caused tangled worktrees this session (recovered cleanly). Supersedes prior resume learnings 2026-05-30 + 2026-05-31_archamd1.

---
*Added via Oracle Learn*
