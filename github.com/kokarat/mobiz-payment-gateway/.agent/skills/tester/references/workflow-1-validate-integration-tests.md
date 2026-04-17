---
description: Validate integration tests by static analysis (ตรวจสอบความ valid ของเทสด้วยการอ่านโค้ด)
owner: tester
autonomy: read-only
---

# Workflow 1 — Validate Integration Tests (Static Analysis)

This is the tester's primary workflow. It answers one question per test:
**"Does this test still mean what it claims to mean?"**

No runtime execution. Nothing is started, killed, or polled. The workflow
reads files and reports. Fast, reproducible, safe.

## Scope & rules

- **Read-only on production code.** `controllers/`, `services/`, `models/`,
  `routes/`, `middlewares/`, `scheduler/`, `helpers/`, `db/`, `main.go`,
  `bank-bot/` — open, read, cite. Never modify.
- **Read-only on test scripts during this workflow.** Validation produces a
  *report* (`docs/test-index.md` + `arra_learn` entries). Fixing the tests
  themselves is a separate, user-approved follow-up step.
- **Do not invoke `run-integration-test.sh`, `bash test-*.sh`, or any
  `docker compose` / `curl` against a live backend.** Validation runs on a
  laptop with zero services up.
- **Do not edit `integration-tests/mock-bank/server.js`** here. If
  mock-bank drift is suspected, hand off to the `mock-bank-sync-check`
  workflow.

## Prerequisites

Before starting, confirm the tester wake-up ritual has run (see
`.agent/skills/tester/SKILL.md` § "Wake-up ritual"). Then have open:

1. `.agent/skills/integration-test-writer/SKILL.md` — the pattern library.
   Every violation you find is a violation of something documented there.
2. `docs/test-index.md` if it exists. If not, this is the first baseline.

## Step 1 — Snapshot the suite

List every integration-test script and the files that describe how they
should look.

```bash
cd integration-tests
ls -1 test-*.sh | sort > /tmp/test-files.txt
wc -l /tmp/test-files.txt
```

Also record:

- Current git commit (`git rev-parse HEAD`). This becomes the header of
  `docs/test-index.md`.
- Last baseline commit from the existing `docs/test-index.md` header (if
  any). Call this `$PRIOR_BASELINE`.
- Diff of production surface since `$PRIOR_BASELINE`:

  ```bash
  git log --oneline "$PRIOR_BASELINE..HEAD" -- \
    controllers/ services/ models/ routes/ middlewares/ \
    scheduler/ bank-bot/ integration-tests/mock-bank/
  ```

  These commits are the candidates for any STALE finding — a test goes
  stale because *something in this list* changed under it.

## Step 2 — Static-analyse each test (one pass per file)

For every `test-*.sh`, run these checks in order. Stop at the first
non-VALID finding per check category — one test can only be in one status.

### 2a. Conformance to the pattern library

Every test must follow the template from
`.agent/skills/integration-test-writer/SKILL.md` § "Mandatory Test Script
Template". Check:

- [ ] Has a header comment block with Category / Flow / Usage / Exit codes.
- [ ] `source "$SCRIPT_DIR/helpers/setup-infra.sh"` is present and
      unconditional.
- [ ] Supports `--no-bot` flag (or has a documented reason not to).
- [ ] Has a `cleanup_<test>()` trap bound to `EXIT` that **only** kills
      `$BOT_PID` — no `infra_cleanup` calls.
- [ ] Step 1 = verify services (curl `$BACKEND_URL/swagger/index.html`
      and `$MOCK_BANK_URL/api/session`). Does **not** call `start_infra`,
      `start_backend`, `start_mock_bank`.
- [ ] Uses `log_step` / `log_ok` / `log_fail` / `log_info` / `log_warn`
      — not raw `echo` — for step boundaries.
- [ ] Exits cleanly (`exit 0` or `exit 1`). No `wait` / `sleep 3600` /
      `while true; do sleep; done`.
- [ ] Cross-check verification (wallet balance, ledger state, or mock-bank
      passbook) exists before `exit 0`.

**Any failure here** → bucket `WRONG-SETUP`. Root cause: specific line +
the rule violated. Cite the rule location in the integration-test-writer
SKILL.

### 2b. Endpoint drift

For every `curl … $BACKEND_URL/...` or `api METHOD /path` call in the test:

- Locate the corresponding Go handler (`grep -rn "\"/path\"" routes/`).
- Verify the HTTP method is still registered.
- Verify the request-body JSON keys exist on the controller's request struct
  (`grep` in `controllers/` for the struct tags).
- Verify the response JSON keys the test parses with `json_val` still exist
  on the response struct.

**If the endpoint no longer exists** → `STALE`. Root cause: the commit that
removed it (find with `git log -S '"/old/path"'`).

**If the endpoint exists but request/response shape has changed** → `STALE`
with sub-reason "contract-drift". Cite the commit.

### 2c. Database/Mongo direct access

Any test that does `docker compose exec mongodb mongosh` needs checking
against:

- The collection name (`db.system_banks.findOne(...)`) — does the collection
  still exist in `db/` or `seed/`? Does a Go model (`models/*.go`) still map
  to it?
- The field names referenced (e.g., `working_status`, `request_id`,
  `source_type`). Cross-check against the Go struct's bson tags. The
  `drift — Payout bson tags are camelCase while other models use
  snake_case` learning in Oracle is a live hazard — expect camelCase in
  `ts_payouts`, snake_case elsewhere.

**If a bson field was renamed** → `STALE`. **If a field is read and not
asserted against in any branch** → `WRONG-SETUP` (dead code in the test).

### 2d. Mock-bank admin calls

Every `curl $MOCK_BANK_URL/admin/...` in the test points at an endpoint
`integration-tests/mock-bank/server.js` actually serves. Check each one:

```bash
grep -nE "app\.(get|post|put|delete)" integration-tests/mock-bank/server.js
```

**If the test calls `/admin/foo` and the mock serves `/admin/bar`** →
`STALE` **and** trigger workflow 3 (mock-bank-sync-check) — this is a
drift event, not just a broken test.

### 2e. Setup-internal-consistency (the WRONG-SETUP trap)

These are the silent killers — the test runs, exits 0, and has been "green"
for weeks while asserting nothing. Check for:

- **System bank created without `working_status: 'ready'`, yet the test
  expects the bot to pick up the job.** The bot will silently ignore it;
  the test's polling loop will time out and the test will exit based on
  whether the timeout path is an assertion. Search: any `db.system_banks`
  write followed by a payout/settlement poll. If the write omits
  `working_status: 'ready'` → `WRONG-SETUP`.
- **Missing `method` entry on system bank.** If the test exercises
  settlement/topup/payout but the bank's `method` array doesn't include
  the corresponding string, the scheduler picks no bank → silent no-op.
- **Mock-bank account not registered for the destination.** Settlement
  and payout tests must `POST $MOCK_BANK_URL/admin/accounts` for the
  destination before the bot transfer. Missing this → the bot can't
  transfer → test times out. If the test asserts the timeout path as
  "pass", that is `WRONG-SETUP`.
- **Race on async MDR distribution.** Any test that reads partner wallet
  balances immediately after `withdrawal_queue.status == success` without
  a polling loop for the partner wallet is `WRONG-SETUP` (the
  async-MDR-distribution pitfall is documented in the
  integration-test-writer SKILL).
- **Unbounded `for tick in $(seq 1 N); do sleep 1; done`** where the loop
  exits only on success and has no `TEST_RESULT=1` on timeout → at best
  FLAKY, at worst a silent pass on timeout. If timeout is treated as
  success anywhere → `WRONG-SETUP`.

### 2f. Flakiness smell

- Hard-coded `sleep` values > 5 s at test-script top-level (not inside a
  polling loop) → `FLAKY`.
- Time-based assertions without tolerance (`[ "$TICK" -lt 10 ]` as a
  correctness check) → `FLAKY`.
- Dependence on wall-clock time (`date +%s` in assertion, not just as a
  uniquifier) → `FLAKY`.

### 2g. Supersession

If the test exercises a feature whose route/controller was removed and the
feature is explicitly gone from the system (not just renamed), the test is
`SUPERSEDED`, not `STALE`. Confirm the feature is gone by searching the Go
tree for any remaining reference. If none, the test stays in tree
(P-001 — Nothing is Deleted) with a header note pointing at its
replacement (if any). No `arra_learn` needed beyond a single
`#superseded-test` entry.

## Step 3 — Assign a single status per test

Use the taxonomy from `.agent/skills/tester/SKILL.md` § "Validation
taxonomy". One status per test. If a test has multiple issues, take the
most severe (ordering: STALE > WRONG-SETUP > FLAKY > VALID).

Record for each test:

| Field | Source |
|---|---|
| `script` | filename |
| `category` | from the filename prefix (deposit / payout / settlement / mixed / stress / bank-specific). Inferred; no metadata file exists yet. |
| `status` | from taxonomy |
| `last_verified_commit` | current HEAD if status is VALID; otherwise the commit *before* the breaking change |
| `root_cause_commit` | for STALE/WRONG-SETUP only — the commit that introduced the drift (find via `git log -S` on the relevant symbol) |
| `root_cause_note` | one sentence: which file:line in the test, which rule it violates |
| `proposed_fix` | one sentence: minimal change that would restore VALID status. **Do not apply it in this workflow.** |

## Step 4 — Write `docs/test-index.md`

Regenerate the file (overwrite is allowed — P-001 applies to the vault,
not to derived docs like this index). Structure:

```markdown
# Integration Test Index

**Baseline commit:** `<sha>`
**Validated at:** <ISO date, GMT+7>
**Validator:** tester agent
**Prior baseline:** `<sha-or-none>`

## Summary

- Total tests: N
- VALID: N  |  STALE: N  |  WRONG-SETUP: N  |  FLAKY: N  |  SUPERSEDED: N  |  UNKNOWN: N
- Newly-broken since prior baseline: N

## Top findings (human-facing)

1. <one-line summary of the most severe issue>
2. …
3. …

## Per-test matrix

| Script | Category | Status | Last-verified | Root cause | Proposed fix |
|---|---|---|---|---|---|
| test-deposit-flow.sh | deposit | VALID | <sha> | — | — |
| test-deposit-foo.sh | deposit | STALE | <prev-sha> | `<sha>` removed `/api/v1/foo` | Replace with `/api/v1/bar` (see <arra_learn id>) |
| … | | | | | |

## Coverage note

See `docs/test-coverage-gaps.md` for what is **not** tested.
```

## Step 5 — File one `arra_learn` per non-VALID finding

For every STALE / WRONG-SETUP / FLAKY row, emit one learning. Template:

```yaml
title: "<STALE|WRONG-SETUP|FLAKY> — <test-name> — <one-line-cause>"
tags:
  - tester
  - repo:mobiz-payment-gateway
  - current
  - <stale-test | wrong-setup | flaky-test>
  - <feature tag, e.g. deposit / payout / settlement / bank-bot>
  # add #drift if the cause is a mock-bank or endpoint rename
source: >
  integration-tests/<test>.sh:L<line>  +
  <production file>:L<line>@<commit>
related:
  - <prior tester learnings if continuing a thread>
project: github.com/kokarat/mobiz-payment-gateway
---

## What's wrong
<1–3 sentences>

## Why this is wrong
<cite the rule from integration-test-writer SKILL.md or the changed commit>

## Minimal fix (proposed, not applied)
<one paragraph, or a diff-style snippet>

## Impact if unfixed
<what false-signal this test emits today>
```

Do not batch these at the end — emit as each test is assigned its status.
Batching risks forgetting nuance.

**Also trace:** when a STALE/WRONG-SETUP has a known production-commit
root cause, write an `arra_trace` linking:

```
commit <sha>  →  test <path>  →  proposed fix <one-liner>
```

## Step 6 — Update `docs/test-coverage-gaps.md`

If during reading the tests you noticed a surface that is obviously not
exercised by any test (a route, a scheduler branch, a bank-bot
edge-case), **append** a row to `docs/test-coverage-gaps.md`. Do not
remove existing rows — a gap filled is marked filled, not deleted.
Schema:

| Area | Surface | Suspected priority | Noticed at commit | Status | Filled by test |
|---|---|---|---|---|---|

Priority scale (from the create-test-case workflow): 🔴 Critical / 🟡
Important / 🟢 Nice-to-have.

## Step 7 — Commit + PR

Before committing, verify no broken frontmatter was introduced this session:

```bash
bash $(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/scripts/verify.sh | grep -A 3 frontmatter
# expect: ✅ no double-wrap + ✅ every indexed doc has a title:
# if ❌ or ⚠️ — fix via /tmp/fix-frontmatter.py before proceeding
```

On branch `feat/tester-validate-<date-GMT7>`:

```bash
git checkout -b feat/tester-validate-$(TZ=Asia/Bangkok date +%Y-%m-%d)
git add docs/test-index.md docs/test-coverage-gaps.md
git commit -m "chore(tester): validate integration tests — baseline <sha>

- Ran static analysis on N test-*.sh files.
- Status breakdown: V=x S=y W=z F=w SUP=v UNK=u
- Filed N arra_learn entries for non-VALID findings.
- No test scripts modified. No production code touched.
- Root-cause commits cited per row in docs/test-index.md."

git push -u origin feat/tester-validate-$(TZ=Asia/Bangkok date +%Y-%m-%d)
gh pr create \
  --title "chore(tester): validate integration tests — baseline <sha>" \
  --body "$(cat <<'EOF'
## Summary

Static-analysis pass on the integration suite. No tests were executed.
No production code was modified. Report only.

## What changed

- `docs/test-index.md` regenerated (baseline: `<sha>`).
- `docs/test-coverage-gaps.md` appended with new gaps (if any).

## Status breakdown

- VALID: …
- STALE: …
- WRONG-SETUP: …
- FLAKY: …
- SUPERSEDED: …
- UNKNOWN: …

## Top findings

1. …
2. …
3. …

## Handoff

Tests flagged STALE / WRONG-SETUP include a proposed minimal fix in
the matrix, but none have been applied. Tester does not patch tests
without explicit sign-off.

Regression candidates (behavior changes that tests correctly caught)
are linked from the relevant `arra_learn` entries and tagged
`#regression-candidate`.

EOF
)"
```

**Do not merge.** Wait for human review (AGENTS.md §9).

## Step 8 — Retrospective

`rrr` into `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_tester-validate.md`.
AI Diary and Honest Feedback are mandatory (AGENTS.md §7). Cover:

- What the validation turned up that was surprising.
- Any rule in the integration-test-writer SKILL that feels outdated or
  ambiguous after this run (propose a refinement, don't apply it).
- Any patterns that recurred across multiple tests (e.g., "5 tests all
  miss `working_status: 'ready'`") — candidate for a shared helper.

## Common pitfalls this workflow has hit before

*(populated over time from prior tester sessions' retrospectives)*

- **Mistaking a rename for a removal.** Before marking STALE, grep the
  whole Go tree for the new name — the feature may have moved, not died.
- **Treating a non-zero exit from a sub-command inside a polling loop as
  test failure.** The loop is supposed to absorb transient non-200s.
  Read the full loop before assigning status.
- **Auto-tagging FLAKY without evidence.** A `sleep 3` is not flaky on
  its own. Only tag FLAKY if the assertion outcome can plausibly change
  on a different host — not merely if the test takes a long time.

---

**Created:** 2026-04-16 (GMT+7) · workflow owner: `tester` agent.
