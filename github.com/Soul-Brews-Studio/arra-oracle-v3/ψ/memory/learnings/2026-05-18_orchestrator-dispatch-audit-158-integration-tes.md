---
title: orchestrator dispatch — audit #158 integration-test↔requirement-doc campaign res
tags: [orchestrator, decision-authority, 2a-trivial-direct, accepted, integration-test-audit, next-impl, thread-158, substrate-drift, verification-honesty]
created: 2026-05-18
source: parent thread #158 — next-impl audit campaign, msgs 455-477
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — audit #158 integration-test↔requirement-doc campaign res

orchestrator dispatch — audit #158 integration-test↔requirement-doc campaign resolved auto 2026-05-17/18

Request: user asked the orchestrator to continue next-impl's audit-#141 line of work — find conflicts/omissions between integration tests and requirement docs, fix/improve the tests, ensure load-bearing requirements are substrate-backed.
Classification: single-agent campaign to next-impl (implementation-architect). Ran on one thread (#158) across six rounds — deposit-lane audit → integration-layer coverage-gap map → P0 gaps G1-G4 → PAYOUT-003 re-verify → payout-`rejected` substrate reconciliation → CHECK-drop + D1 verification — not a thread per round (thread-discipline: fewer/coarser threads).
Confidence: HIGH — user instructed directly, picked scope each round.
Outcome: 4 fork PRs, all verified, none merged — #149 (DEPOSIT-003 probe, hosted 82/82), #151 (P0 gaps G1-G4, hosted 89/89), #152 (payout `rejected` terminal retired + CHECK-drop, hosted 89/89), #153 (D1 poc/4d taxonomy port, pgTAP 42/42 + mutations 6/6).
User reaction: accepted at every round.

Decision-authority + process lessons:
1. When the user disputes an agent's finding (here: user said PAYOUT-003's `failed` terminal is correct, vs next-impl's earlier "doc-wrong" verdict), the orchestrator must NOT relay it as a flat "the user says you're wrong, change it." Relay the user's authoritative intent AND ask the agent to RE-VERIFY and map where the conflict actually sits — doc / code / ADR. next-impl re-checked, found §ADR-9 §Amendment 2026-05-16 already matched the user's intent, and self-corrected its own earlier verdict: the real defect was deployed-substrate drift, not the doc. Blind relay would have produced a wrong doc edit.
2. A user's terminal-state semantics ("`failed` = system fault incl. bank refusal + insufficient funds; `rejected` = customer fault only") is the authoritative intent — but the orchestrator's job is to find which artifact (doc/code/ADR) currently violates it, not assume.
3. Existing-data checkpoint discipline: before a migration that would rewrite terminal states of real records, the orchestrator inserted a pause-for-confirmation checkpoint. It turned out moot (the `rejected` rows were PoC fixtures wiped every run, 0 real rows) — but the checkpoint was correct to set; the agent verified emptiness and proposed a defensive 0-row migration.
4. next-impl honestly flagged D1/PR #153 as "pgTAP not run — no Docker in worktree" rather than reporting a false green (the #146 rule), and only declared it verified after the user confirmed Docker was up and the 42/42 run completed. Verification honesty held under multi-round pressure.

---
*Added via Oracle Learn*
