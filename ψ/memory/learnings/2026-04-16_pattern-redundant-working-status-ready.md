---
title: Pattern — redundant working_status:'ready' writes in ~12 tests post-82b6d63
type: learning
tags:
  - tester
  - repo:mobiz-payment-gateway
  - current
  - test-pattern
  - withdrawal-queue
  - drift
related:
  - 2026-04-16_decision-2026-04-16-gmt7-introduced-the-tes
source: >
  Observed in integration-tests/test-multi-bank-stress.sh:166,
  test-multi-bank-stress-unique-amt.sh:180,236,
  test-split-bank-ktb.sh:171,
  test-mixed-burst-ktb.sh:158,166,222,
  test-settlement-exploit.sh:102,
  and several others at HEAD 3b7e0f1. Reference commit: 82b6d63
  ("fix(dispatcher): cap pending per bank, drop working_status as
  routing gate").
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

## Observation

Roughly a dozen test scripts still run:

```javascript
db.system_banks.updateOne(
  {_id: ObjectId('...')},
  {$set: {working_status: 'ready'}}
);
```

on the system bank they just created. This was **required** under the
old dispatcher, which would not route a withdrawal to a bank whose
`working_status != 'ready'`. Commit `82b6d63` dropped that gate:
`working_status` is now descriptive (reflects current bot state),
not directive. The dispatcher routes based on pool membership,
`method[]`, and queue pressure.

## Why this is worth recording

- **Not a defect.** The write still succeeds. Scripts that include it
  continue to exercise the flow they intend to exercise.
- **It is drift.** Tests should not be teaching future readers that
  `working_status:'ready'` is a setup requirement. If this codifies
  into a tester expectation, a future regression where the field *is*
  consulted again will be masked by the tests' unconditional write.
- **It is a good opportunity for a sweep.** Removing the writes (and
  asserting that withdrawal dispatch proceeds *without* the field
  being set) would add a live assertion that `82b6d63` has not been
  reverted.

## Proposed next step (not applied)

Workflow-2 candidate: one PR that
1. deletes the `working_status` write from affected tests,
2. adds a single positive assertion somewhere central — e.g., in
   `test-multi-bank-stress.sh`, after pool setup — checking that
   `db.system_banks.findOne(...).working_status` is **not** `'ready'`
   until the bot first checks in, AND that withdrawals dispatch
   regardless.

Owner sign-off required because (a) it touches many files, (b) the
positive assertion is a new behavioral claim and should be reviewed
against the dispatcher unit tests.

## Impact if untouched

Low, recurring. Each future validate pass will re-discover this
pattern and re-log it unless the sweep is done. Recording once here
so the next tester session can check this learning and skip re-filing.
