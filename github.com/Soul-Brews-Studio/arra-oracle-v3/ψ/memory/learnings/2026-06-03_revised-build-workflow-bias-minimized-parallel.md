---
title: REVISED BUILD WORKFLOW (bias-minimized parallel) — mb-next campaign nextteam, ow
tags: [nextteam, build-workflow, bias-minimization, next-dev, next-tester, next-investigator, next-pm, orchestrator, spec-first, self-merge, mb-next-payment-gateway]
created: 2026-06-03
source: orchestrator campaign nextteam — revised build workflow (owner decision 2026-06-03)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# REVISED BUILD WORKFLOW (bias-minimized parallel) — mb-next campaign nextteam, ow

REVISED BUILD WORKFLOW (bias-minimized parallel) — mb-next campaign nextteam, owner decision 2026-06-03. BINDING for the build team. Supersedes the earlier sequential dev→tester flow.

== THE ANTI-BIAS SPINE ==
The whole point: minimize bias BETWEEN roles by (a) running dev+tester in PARALLEL off a shared SPEC instead of sequentially, (b) forbidding tester from ever reading dev's code, (c) having investigator falsify tester's PASS against the truth DB, (d) letting only pm mark done — on evidence, (e) orchestrator never marks anything.

== STEP 0 — SPEC-FIRST (next-dev) ==
Before deep implementation, next-dev emits the test-facing SPEC the testers need: the API CONTRACT (endpoints, request/response shapes, status codes, required headers e.g. Idempotency-Key) + the DATABASE schema / observable surface (tables, columns, the rows/columns probes will read). This SPEC is the shared contract that decouples tester from dev's code. If dev changes the contract later, it's a CONTRACT change broadcast to tester — never "go read my code".

== STEP 1 — PARALLEL BUILD (next-dev ∥ next-tester), orchestrator-coordinated ==
- next-dev: implements code (EFs, RPCs, migrations) per AC + ADR + PoC.
- next-tester: designs + builds probes/fixtures IN PARALLEL, working ONLY from the SPEC + DB probes + API responses. **next-tester is FORBIDDEN from reading next-dev's code — ever.** Expected behaviour is derived from the SPEC/AC, NOT the implementation. This is the dev↔tester de-bias.
- orchestrator keeps the SPEC as the single shared contract and relays contract changes.

== STEP 2 — VERIFY BY FALSIFICATION ==
- next-tester runs probes → reports per-AC pass/fail derived from DB GROUND-TRUTH / API responses (never dev's claim).
- next-investigator: for EVERY probe that says PASS, independently queries the TRUTH database and confirms the data matches the probe's claim — actively trying to CATCH a discrepancy (falsify). Reads ground-truth ONLY — never the harness flags, never dev's code, never the tester's word. A probe-PASS that the truth DB contradicts = the probe is wrong → reopen.

== STEP 3 — PR → REVIEW → MERGE (SELF-SERVICE, NO OWNER GATE) ==
next-dev opens PR → next-code-reviewer reviews (3 dims) → on approve, the TEAM MERGES — **no owner/user PR approval**. Owner explicitly WAIVED PR approval for the build workflow 2026-06-03 ("pr -> review -> merge กันเอง ไม่ต้องผ่านผม"). This is a scoped carve-out from AGENTS.md §9 for build-workflow PRs (does not extend to deleting vault data / force-push / destructive ops).

== STEP 4 — MARK DONE ON EVIDENCE ONLY (next-pm) ==
next-pm marks a step/story/epic done ONLY after concrete completion evidence exists (merged PR + reviewer approve + tester-green-from-ground-truth + investigator confirmation + LIVE/seal where applicable). next-pm never marks on a claim — it goes and looks at the evidence per step. **Only next-pm marks. The orchestrator NEVER marks anything.**

== ORCHESTRATOR (the human's coordinator) ==
Dispatch + coordinate ONLY. MUST NOT mark anything done, MUST NOT instruct a role to mark without evidence. Proceed autonomously when unblocked; consult the owning role for domain questions; PING THE OWNER only for a genuine decision (ambiguous requirement, scope change, real risk). The owner granted standing autonomy 2026-06-03.

== WHY IT WORKS (4 independent de-bias layers) ==
1. tester can't see code → can't inherit dev's assumptions. 2. investigator falsifies tester's green against the truth DB → catches a biased/wrong probe. 3. pm marks only on evidence → no premature done. 4. orchestrator dispatches only → no authority leakage.

---
*Added via Oracle Learn*
