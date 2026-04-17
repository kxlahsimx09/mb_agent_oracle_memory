---
title: Pattern — integration tests use TEST_RUNNER_MODE-gated interactive hang on success
type: learning
tags:
  - tester
  - repo:mobiz-payment-gateway
  - current
  - test-pattern
  - ci-ux
related:
  - 2026-04-16_decision-2026-04-16-gmt7-introduced-the-tes
source: >
  Observed across ~30 of 35 integration-tests/test-*.sh scripts at HEAD 3b7e0f1.
  Representative: integration-tests/test-deposit-flow.sh:406-410
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

## Observation (not a defect)

A recurring post-assertion block in integration tests:

```bash
if [ "${TEST_RUNNER_MODE}" = "1" ]; then
  exit 0
fi
trap 'cleanup_<name>' INT
wait 2>/dev/null || while true; do sleep 3600; done
```

In CI (`TEST_RUNNER_MODE=1`) the script exits cleanly. When run
interactively without that env var, the script waits on background
PIDs (bot, tunnel) and falls into a 1-hour sleep loop so the dev can
inspect services (backend, mock-bank, bot logs) before pressing
Ctrl+C.

Workflow-1 §2a says:

> Exits cleanly (`exit 0` or `exit 1`). No `wait` / `sleep 3600` /
> `while true; do sleep; done`.

Read strictly, this pattern violates the rule. Read as pattern (P-002)
and observed, it is an intentional dev-UX affordance that only matters
in interactive runs — CI is unaffected.

## Why I'm recording this as a pattern, not flagging each test

P-002 (Patterns Over Intentions) tells me to record what actually
happens. What happens is: tests exit 0 under CI; tests hang for human
inspection under interactive. Flagging 30 tests as `WRONG-SETUP` for
this would drown signal in noise. Flagging it as a pattern once makes
it searchable and gives the next tester agent (or the workflow-1
author) something concrete to decide about.

## Two plausible resolutions (both out of scope for validate run)

1. **Amend workflow-1 §2a** to allow this specific gated pattern, with
   the gate being `TEST_RUNNER_MODE=1`. Tighter rule: the script must
   exit cleanly in `TEST_RUNNER_MODE=1`; the interactive fallback is
   discretionary.

2. **Extract a shared helper** in `helpers/setup-infra.sh`:
   ```bash
   await_interactive_exit() {
     [ "${TEST_RUNNER_MODE}" = "1" ] && exit 0
     trap "$1" INT
     wait 2>/dev/null || while true; do sleep 3600; done
   }
   ```
   Then individual tests call `await_interactive_exit cleanup_deposit`.
   Reduces duplication; makes the pattern grep-able; centralizes any
   future change.

Decision sits with the human or `system_architect`. `tester` records
the pattern and defers.

## Follow-ups not yet filed

- If (1) is chosen, `.agent/skills/tester/references/workflow-1-validate-integration-tests.md`
  needs an amendment.
- If (2) is chosen, the helper introduction is a separate PR on
  `helpers/setup-infra.sh` and every test script updates in the same
  change — this is a sweep, not a tester workflow.
