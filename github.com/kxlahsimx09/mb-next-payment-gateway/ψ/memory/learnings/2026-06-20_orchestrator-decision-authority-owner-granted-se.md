---
title: orchestrator decision-authority — OWNER GRANTED self-merge for build-flow featur
tags: [orchestrator, decision-authority, self-merge-authorized, build-flow, user-override, accepted, mb-next-admin-portal, mb-next-payment-gateway, agents-md-9-carveout]
created: 2026-06-20
source: owner directive, campaign poolbe (2026-06-20)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# orchestrator decision-authority — OWNER GRANTED self-merge for build-flow featur

orchestrator decision-authority — OWNER GRANTED self-merge for build-flow feature CODE PRs (2026-06-20, midas owner, campaign sysbankc/poolbe family). Rule: a FEATURE PR that followed the build flow AND passed review/verify (a dispatched pm done-check or tester verify = GREEN, defects fixed + re-verified) → the orchestrator SELF-MERGES it (gh pr merge --squash/--merge --delete-branch), no per-PR owner ping. STILL owner-gated (do NOT self-merge): ADR/spec/doc PRs marked owner-gated DO-NOT-MERGE (#630/#635/#650 class). This is the explicit AGENTS.md §9 permission carve-out (extends the prior 'build-CODE PRs self-merge on two gates' note: the practical gate is build-flow + a passing dispatched verify, not strictly reviewer-APPROVE+investigator-SEAL). Applied first to #74 (admin-portal indicator, build-green+inspected) + #652 (gateway Pools backend, pm re-verify 9/9 PASS). Still PING the owner for: genuine product decisions, ADR/design/requirement changes, real blockers — merges of verified features are no longer a ping reason. Merge method by repo: admin-portal = --merge (merge commit), gateway = --squash (the (#N)-suffixed squash the repo uses).

---
*Added via Oracle Learn*
