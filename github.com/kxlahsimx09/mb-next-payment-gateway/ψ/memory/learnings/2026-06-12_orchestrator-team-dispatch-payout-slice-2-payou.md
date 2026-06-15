---
title: orchestrator team-dispatch — PAYOUT slice-2 (PAYOUT-004/005 review-cancel rails)
tags: [orchestrator, team-dispatch, 2b, accepted, build-workflow, payout, slice-2, spec-reuse, shared-rpc-caller-census, stack-parity]
created: 2026-06-12
source: campaign payb2 + payb2t + payb2ops + payb2i + payb2r + payb2pm (orchestrator wt-28-dev, 2026-06-12)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# orchestrator team-dispatch — PAYOUT slice-2 (PAYOUT-004/005 review-cancel rails)

orchestrator team-dispatch — PAYOUT slice-2 (PAYOUT-004/005 review-cancel rails) full Step 0-4 cycle, accepted; second consecutive same-day slice — the pattern is now ROUTINE. Faster than slice 1 because: (1) SPEC discipline tightened — the dev's slice-2 SPEC explicitly pinned the outcome→HTTP maps + EF bodies + named its own delta census (§0 "what changed vs the predating substrate") so the tester had near-zero contract questions; the one gap (RPC param names by-name-only) was closed by a v2 re-broadcast in minutes, with the tester binding honest flagged-pendings meanwhile; (2) probe-suite REUSE — slice-1 _spec/_assert/_flow/_stage helpers were on main, the tester imported them as prior-artifacts (allowed; they are tester-owned) and added _rc siblings additively, no slice-1 mutation; (3) cross-stack deploy was light because the stacks were kept at main-parity continuously (the 000070 follow-up right after #441 merged) — keep stacks current between slices, deploys stay one-migration cheap. Slice-2 found a REAL dormant money bug via census: slice-1's SM2-SPLIT lock (mark_failed processing-only) had silently KILLED admin reconcile's failed leg (review payouts could never fail/release — freeze stuck forever); fix = a sanctioned mark_failed_from_review producer; lesson: when a slice tightens a shared RPC's source-guard, census every CALLER of that RPC in the same pass (admin_reconcile_payout was the missed caller). Also: brew-ops item-7 pattern — a deploy actor verifying tester-stack fixtures must check IDENTITY substrate (auth.users) not just app tables; zero gotrue users = EF-gate probes blocked; the tester seeds its own identities (never the deploy actor inventing credentials). Gates: VERIFY 46/46 (yupsev) → falsify 65/65 +1 teeth-sentinel (qnccph) → APPROVE x2 → self-merge #449/#451 → PM marks with the slice-1 pattern.

---
*Added via Oracle Learn*
