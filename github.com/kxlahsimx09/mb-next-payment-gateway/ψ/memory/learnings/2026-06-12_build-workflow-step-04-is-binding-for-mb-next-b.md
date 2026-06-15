---
title: Build-workflow (Step 0→4) is BINDING for mb-next builds — the orchestrator must 
tags: [orchestrator, build-workflow, anti-bias, spec-first, dev-tester-parallel, next-tester, process-discipline]
created: 2026-06-12
source: orchestrator-buildteam wt-26, thread #16 (owner-caught)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Build-workflow (Step 0→4) is BINDING for mb-next builds — the orchestrator must 

Build-workflow (Step 0→4) is BINDING for mb-next builds — the orchestrator must dispatch dev+tester TOGETHER off a Step-0 SPEC, not dev-first-tester-late.

**Observed (2026-06-13, orchestrator-buildteam wt-26, AUTH full-epic Phase B):** The orchestrator dispatched next-dev to BUILD AUTH-008/012 directly and left next-tester IDLE during the build, dispatching the tester only AFTER the owner noticed it sitting idle (and after #445 had already merged to main). The owner caught it: "มันต้องทำตาม workflow2 / คุณไม่ได้ให้ dev สร้าง spec หรอ" — it must follow the build-workflow; didn't you have the dev emit the SPEC?

**The binding workflow (docs/build-workflow.md, owner decision 2026-06-03, anti-bias spine):**
- Step 0 SPEC-FIRST: next-dev emits the TEST-FACING SPEC (API contract: endpoints/shapes/status/required-headers + DB observable surface) under docs/spec/<file>, commits+pushes it to its PR branch EARLY, and broadcasts the exact `branch` + `path`.
- Step 1 PARALLEL: next-dev implements ∥ next-tester builds probes off the SPEC (`git show origin/<dev-branch>:docs/spec/<file>` — contract, NEVER the supabase/ code). The orchestrator relays the branch+path to the tester ON DISPATCH so both start together.
- Step 2 verify (tester probes → investigator falsifies on its own seal env against the truth DB), Step 3 reviewer APPROVE, Step 4 next-pm marks done on evidence.
- The orchestrator DISPATCHES, never marks (no authority leakage).

**Why dev-first-tester-late breaks it:** the anti-bias guarantee is "tester can't see the code." If the dev's code MERGES to main before the tester is dispatched, the tester's worktree (off main) can now see supabase/ — the STRUCTURAL hiding (code on the dev's unmerged branch) is gone; only tester self-discipline + the investigator's independent truth-DB falsification remain. The parallelism isn't a nicety; it's what keeps the tester's expected-behaviour sourced from the SPEC, not the implementation.

**How to apply:**
1. For every mb-next build story: dispatch next-dev and next-tester in the SAME wave, relay the dev's SPEC branch+path to the tester, and confirm the dev pushed the test-facing SPEC to its PR branch at Step 0 BEFORE deep implementation.
2. A pre-existing requirement/AC slice is NOT a substitute for the dev's Step-0 test-facing contract — the dev emits/confirms the buildable contract at build time and broadcasts it.
3. If a build already merged out-of-workflow (like AUTH-008/012 here): recover by binding the tester strictly off the SPEC (forbid reading supabase/) and lean on the investigator's independent falsification as the primary remaining de-bias; acknowledge the structural tester-independence is weakened.
4. Don't let the deposit/critical-path focus starve the parallel build lanes — an idle tester during a dev build is a workflow violation, not just lost throughput.

---
*Added via Oracle Learn*
