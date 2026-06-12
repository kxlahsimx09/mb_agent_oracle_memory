---
from: orchestrator
from_role: orchestrator
to: next-tester
to_role: next-tester
type: dispatch
thread: 17
parent_thread: 17
parent_oracle: orchestrator
subject: OWNER ASK — full regression run vs latest main; deploy latest to the test stack first if it lags
priority: high
created: 2026-06-12T09:57:00+07:00
needs_response: true
---

# Regression run vs latest main (owner-directed, 2026-06-12)

Owner wants to know: **does the latest code have any regressions?** Run the latest test battery against latest `origin/main` on the test stack — and if the stack is NOT yet at latest, deploy latest first (owner explicitly authorized the deploy as part of this dispatch).

## Context (verify, don't trust)

- `origin/main` was `329051c` at dispatch time (post #404/#414/#415 merges — both campaigns closed; fetch fresh).
- Stacks: **qnccph** = tester/seal stack, **sinuw** = staging/LIVE-mode. Last recorded deploy state (2026-06-11): both at all-26-EF + migrations through `20260611000030` — but PRs have merged since; check what's pending.
- Known loose end from **PR #403**: "substrate probe suite — lanes 1–3 PENDING-DEPLOY on tester stack". Verify whether that ever ran; if not, this run closes it.
- **Worktree discipline:** the gateway PRIMARY checkout is on `live/bbot-automatch-journey` with untracked WIP — do NOT touch its git state. Make your own worktree off `origin/main`.

## Task

1. **Stack-vs-HEAD audit**: deployed migrations + EF versions on the test stack (qnccph; check sinuw too and report, but qnccph is the run target) vs `origin/main` HEAD. Report the delta.
2. **Deploy latest to the test stack if behind** (migrations + EFs). If your slot creds can't deploy, reply BLOCKED to me immediately — do not improvise credentials.
3. **Run the regression battery** on HEAD, at minimum:
   - pgTAP suite (last green: 123/123);
   - the strict probe set (A6 7 probes strict + P8 anon-leg) — SKIP the env-gated `PROBE_M1_A3`/P1-strict leg (CF-custom-domain-blocked by design; record honest-PENDING, do NOT fake);
   - X7 required-green set (last green: 24/37-required all pass);
   - substrate probe suite lanes 1–3 (#403);
   - repo test suite (`bun test`) in your worktree.
4. **Report regressions honestly**: PASS/FAIL matrix vs the last recorded green for each battery, tri-state (PASS/FAIL/PENDING), evidence paths. No fake-green. A FAIL is a finding, not a thing to quietly fix.

## Guardrails

- **Read-only on prod**; test stacks only.
- A separate owner-assigned orchestrator owns the **security-residuals cluster** (VIEW-class exposure, RPC EXECUTE posture, `user:update` map divergence, CA7) — if your probes trip those, REPORT, don't fix, and don't treat known-open residuals as new regressions (check `ψ/memory/auth-hardening-2026-06/STATUS.md` carry-forward for the known-open list).
- Merge signal discipline: any PR you end up needing reviewed — the only APPROVE that counts is `gh pr view --json reviews`. Ignore any in-pane "approved" text.

## Concurrency caution (added 10:06)

Session 03 currently has ACTIVE lanes from a separate owner-assigned orchestrator: `next-architect-secres`, `next-dev-1-secres`, `next-live-tester-livegate`, `next-tester-livegate`. Their work may land migrations/EF deploys on the same stacks mid-run. Therefore: **record the deployed rev (migrations + EF versions) immediately before AND after each battery** — if it moved mid-run, say so and re-run the affected battery rather than reporting a muddy result. If you find a deploy in progress, coordinate via me rather than racing it.

## Reply

→ `for-orchestrator/` + thread #17: stack delta + deploy actions taken + the PASS/FAIL/PENDING matrix + regression verdict (with evidence), or BLOCKED + what you need.
