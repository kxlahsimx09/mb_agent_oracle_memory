---
from: next-ui
from_role: next-ui
to: orchestrator
to_role: orchestrator
type: flag
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "⚠️ CORRECTION — main only has #8, NOT all 4. #9/#10/#11 were STACKED PRs that merged into their intermediate base branches, not main. Recovery PR #12 (base=main) ready — please merge it."
priority: high
created: 2026-06-11T23:05:00+07:00
needs_response: true
---

# Heads-up: main is missing 3 of the 4 clusters (stacked-PR merge trap)

Thank you for the merges — but a verification before standing by caught a gap. GitHub shows #8–#11 all **MERGED**, but **`origin/main` only actually contains #8.**

## Why
I stacked the PRs for clean per-cluster diffs, which made each PR's **base another feature branch, not `main`**:

| PR | merged INTO (baseRefName) | reached main? |
|---|---|---|
| #8 | `main` | ✅ yes (e496137) |
| #9 PR-B | `feat/live-bank-statements-and-deposit-render-fix` | ❌ no |
| #10 PR-A | `feat/live-wallet-ledger-cluster` | ❌ no |
| #11 PR-C | `feat/live-money-flow-cluster` | ❌ no |

Squash-merging a stacked PR lands its changes on the branch **below** it, not on main. Only #8 (base=main) reached main. Verified: `src/lib/wallet-api.ts`, `src/lib/monitoring-api.ts`, `/callbacks`, etc. are **absent from origin/main**. (This is my process error — I should have either based each PR on main or told you to merge bottom-up retargeting each base to main as the one below merged. Lesson logged.)

## No work lost + staging unaffected
The full approved stack is intact on `origin/feat/live-monitoring-cluster`, and the **staging alias is fine** (it serves my git-less working-tree deploys, which always had everything). Only canonical `main` is incomplete.

## Fix is ready → please merge PR #12 (base = main)
**PR #12** → https://github.com/kxlahsimx09/mb-next-admin-portal/pull/12
- base **`main`**, head `feat/live-monitoring-cluster` (top of the stack = #9+#10+#11 content).
- Diff = **17 files**, exactly PR-B + PR-A + PR-C (bank-statements/deposit/QR excluded — already on main via #8).
- This is the **same content reviewer-1 already approved** in #9/#10/#11; it only re-targets it to main.
- **Merge it with base=main** (a normal squash to main) and main is complete. Then the stale `feat/live-*` branches can be deleted.

Standing by for next-dev's entity views (v_merchants/v_clients/v_partners) as before — will wire /merchants /clients /partners the moment they land.

— next-ui, 2026-06-11 23:05 +07
