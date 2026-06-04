---
title: orchestrator build-workflow — DEPOSIT-003+004 cluster (2nd vertical slice) shipp
tags: []
created: 2026-06-03
source: orchestrator session 2026-06-03→04; campaigns dep34dev/dep34test/dep34deploy/dep34redeploy/dep34seal/dep34review/dep34pm; PRs #320/#321 merged, #319/#12 (workflow hardening), #315-318 (cleanup+robustness)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator build-workflow — DEPOSIT-003+004 cluster (2nd vertical slice) shipp

orchestrator build-workflow — DEPOSIT-003+004 cluster (2nd vertical slice) shipped end-to-end via team-dispatch, 2026-06-04. ACCEPTED.

First FULL run of the canonical bias-minimized build-workflow (docs/build-workflow.md, Step 0-4) driven by the orchestrator after the workflow + stack-readiness gate were merged (#319) and the orchestrator SKILL gained the build-team pointer (#12). The whole loop ran and every gate fired as designed:

PIPELINE: SPEC-first (next-dev publishes docs/spec/deposit-slip-expire-slice.md) → Step1 next-dev ∥ next-tester off the shared SPEC (tester never reads dev code) → STACK-READINESS GATE → Step2 VERIFY (tester probes, then investigator falsifies on an independent seal stack) → Step3 REVIEW (next-code-reviewer 3-dim) → merge → Step4 next-pm marks DoD from artifacts.

OUTCOME: DEPOSIT-003 (6 AC) + DEPOSIT-004 (16 in-slice assertions) DONE; D4-11 (clean-approve→paid) DEFERRED out-of-slice (V2 fraud gate is DEPOSIT-007's, and the upload contract has no slip-receiver-proxy field to satisfy V2 — making it work = scope creep into another story). PRs #320 (dev) + #321 (tester probes+evidence) squash-merged; investigator EPIC SEALED on isolated stack qnccphgykzdydebmdwdf (own regression 27/27 + raw-table re-derivation, caught a probe-teardown trust-trap and drove flows itself); reviewer APPROVE; pm marked gate↔artifact only. NOT epic-done (§ADR-21 LIVE gate is a separate per-epic step).

THE GATES EARNED THEIR KEEP (proof the workflow is not ceremony):
- The just-merged STACK-READINESS GATE fired immediately: next-dev built but could NOT deploy to the tester/seal stacks (role isolation — dev only holds the dev-1/2 slot, not tester/seal; + no SUPABASE_ACCESS_TOKEN). It flagged + handed off rather than idling; brew-ops db-pushed via the IPv4 Supavisor pooler (DB password only, no token).
- DE-BIAS VERIFY caught 2 REAL pre-seal defects the tester surfaced binding off SPEC (never code): FINDING A [blocker] — upload_slip ambiguously overloaded (CREATE OR REPLACE with a different 6th param made a 2nd overload not a replace → PostgREST could-not-choose-best-candidate → every slip upload 500'd); FINDING B [scope] — V2 fraud gate blocks clean-approve (D4-11). dev fixed A with an add-on collapse migration; owner deferred B.

FOUR WORKFLOW-REFINEMENT GAPS surfaced for next iteration (none blocked this run, all worked-around): (1) deploy-ownership — the gate says "next-dev deploys" but role isolation means dev lacks tester/seal slot access → realistically brew-ops does cross-stack deploy, OR dev must be granted the slots; (2) SPEC-broadcast — dev published the SPEC on its PR branch, tester (separate worktree off main) couldn't see it → orchestrator had to relay the branch path; a shared SPEC location is needed (reading the SPEC doc from the dev branch does NOT violate de-bias — it is the contract, not code); (3) SUPABASE_ACCESS_TOKEN absent from all per-role slots → supabase functions deploy cannot run (EF was already deployed this time, but an EF change would be blocked) — owner should provision the token; (4) gh review --approve self-approval — all agents share the PR-author gh identity (kxlahsimx09) so GitHub blocks a literal APPROVED state; the reviewer verdict lives in the COMMENTED review body (matches §9a). MERGE policy clarified by owner: build-team PRs that pass the full workflow self-merge per §9a — orchestrator may merge them directly once all gates are green (explicit owner grant 2026-06-04).

Non-blocking follow-ups recorded: reviewer nits C-1 (dead p_now in run_slip_verify), C-2 (silent EXCEPTION-WHEN-OTHERS in both sweeps — no observability); verify_jwt-config-deploy (token gap).

ALSO this session (earlier): cleanup+verify-consistency arc — preserved the sealed DEPOSIT-001/002 probe suite to main (#315) before worktree cleanup, fixed 3 recurring test-robustness problems (#316/#317/#318: AC-5 deterministic stub, dup_egress ground-truth, SPEED→frozen clock) with 50/50 consistency re-confirmed, and durably hardened the workflow (#319 + #12).

tags: [orchestrator, team-dispatch, build-workflow, decision-authority, 2b-fan-out, accepted, deposit-003, deposit-004, nextteam, mb-next-payment-gateway, de-bias, verify-falsification, epic-seal, stack-readiness-gate, defer-out-of-slice, v2-fraud-gate, deposit-007-coupling, deploy-role-isolation, spec-broadcast-gap, access-token-gap, self-approve-limit, 9a-self-merge, repo:arra-oracle-v3, fleet]

---
*Added via Oracle Learn*
