---
description: Add a new integration test case to close a coverage gap (เพิ่มเทสเคสใหม่)
owner: tester
autonomy: write-on-test-files-only
---

# Workflow 2 — Add New Integration Test Case

Extend the integration suite with a new `test-*.sh`. The gap is either
proposed by the user or surfaced by the tester's own
`docs/test-coverage-gaps.md`.

**Session vs. per-test scope.** A session may add 1, 3, or 10 new tests.
Steps 1–9 run **once per test** (each test gets its own commit, its
own row in `docs/test-index.md`, its own design-choice learnings).
Step 10 (retrospective) runs **exactly once at the end of the
session**, covering every test added in that session. Do not write a
separate retrospective for each test — the retro is a session-level
artifact, not a per-test one.

## Scope & rules

- **Tester writes the test file.** Production code is read-only here too.
- **No runtime validation in this workflow.** `bash -n` (syntax parse) is
  the only check run. The test's *first real execution* is a follow-up
  action the user or CI initiates; tester marks the row in
  `docs/test-index.md` as `UNKNOWN` until then.
- **Pattern discipline is non-negotiable.** Every new test follows the
  template and pitfall list in
  `.agent/skills/integration-test-writer/SKILL.md`. That skill is
  superseded on process but canonical on patterns.
- **One retrospective per session, not per test.** See Step 10.

## Prerequisites

Wake-up ritual complete. Open these files before typing a line of test code:

1. `.agent/skills/integration-test-writer/SKILL.md` — pattern library.
2. `.agent/skills/tester/SKILL.md` — your own rules.
3. `docs/test-coverage-gaps.md` — the gap you are closing (confirm it's
   there and still open).
4. The existing `test-*.sh` most similar to the new one — copy its shape,
   don't reinvent.

## Step 1 — Confirm the target

### 1a. User-specified
User said "เพิ่มเทสเคส X" or "add test for Y": paraphrase back the scope,
wait for confirmation, note any ambiguity. Proceed.

### 1b. Auto-discovered
No target specified. List `docs/test-coverage-gaps.md` open rows by
priority. Present top 3 with one-sentence "why this matters" each. Let
user pick one.

### 1c. Check for overlap
```bash
ls integration-tests/test-*.sh | xargs -I{} basename {} | sort
```
Reject if a test with the same domain already exists unless the new test
is a distinct sub-case (e.g., `-cancel`, `-insufficient`, `-expiry` suffix).

## Step 2 — Read the feature under test

Before writing a single assertion, read the code:

- **Controller**: `controllers/<Feature>Controller.go`. Note the handler
  signatures, required fields, validation, fee calc.
- **Service**: `services/<feature>.go`. Status transitions, async work,
  dependencies (scheduler, bank-bot, DB writes).
- **Model + bson tags**: `models/<feature>.go`. **Check bson casing
  carefully** — payouts use camelCase, most others use snake_case.
- **Route registration**: `routes/<feature>.go` (or `main.go`).
- **Scheduler, if any**: `scheduler/<feature>*.go`. Cadence, fail-closed
  behavior, side-effects.
- **Bank-bot, if involved**: `bank-bot/src/**` for the adapter code that
  the test's mock-bank interaction will exercise.

Write a short internal note: "what the test is supposed to prove" — 2–4
sentences. This becomes the header comment block of the test.

## Step 3 — Check mock-bank readiness

Does the feature require a mock-bank endpoint that doesn't exist yet?

```bash
grep -nE "app\.(get|post|put|delete)" integration-tests/mock-bank/server.js
```

- **If all needed endpoints exist** → proceed to Step 4.
- **If a new mock endpoint is required** → stop. Hand off to
  `mock-bank-sync-check` workflow to add the endpoint in a separate
  commit (user sign-off required). Only after that commit lands do you
  come back to Step 4.

Never inline a mock-bank change into a test PR. Every mock change is its
own review.

## Step 4 — Draft the test script

### File path + naming

```
integration-tests/test-<domain>-<variant>.sh
```

Use the existing naming convention. Domains seen in the tree:
`deposit`, `payout`, `settlement`, `topup`, `mixed`, `multi-bank`,
`split-bank`, `burst`. Variants: flow (basic), cancel, expiry,
insufficient, collision, fifo, idempotency, min-max-limit,
promptpay-qr, upload-slip, <bank>-specific (e.g. `-ktb`).

### Mandatory shape

See `.agent/skills/integration-test-writer/SKILL.md` § "Mandatory Test
Script Template" for the full template. The non-optional pieces:

- Header comment block (title, Thai description, Flow list, Usage,
  Exit codes).
- `source "$SCRIPT_DIR/helpers/setup-infra.sh"` — first non-comment line
  after shebang.
- `--no-bot` flag handling.
- `cleanup_<name>()` trap on EXIT that kills `$BOT_PID` only.
- **Step 1: Verify services** (curl `$BACKEND_URL/swagger/index.html`
  and `$MOCK_BANK_URL/api/session`) — not start them.
- `log_step` at every major phase boundary.
- Cross-check verification before `exit 0` (wallet, ledger, or mock-bank
  passbook — at least one).
- `exit 0` / `exit 1` — no `wait` / `sleep 3600` loops.

### Pattern picks

Choose the patterns from the integration-test-writer SKILL that match the
feature:

| Scenario | Pattern |
|---|---|
| Create system bank | Pattern 1 (SCB) or Pattern 2 (KTB) |
| Create client | Pattern 3 |
| Create deposit | Pattern 4 |
| Simulate customer transfer | Pattern 5 |
| Create payout | Pattern 6 |
| Start bank bot | Pattern 7 |
| Poll deposit status | Pattern 8 |
| Poll payout / settlement (MongoDB direct) | Pattern 9 / 10 |
| Cross-check wallet | Pattern 11 |
| Print passbook for debug | Pattern 11 (ledger) |

Do not copy pattern code unthinkingly. Adapt names and amounts. Every
placeholder (`<test_name>`, `<TEST>`) must be replaced.

### WRONG-SETUP hazards to design out from Day 1

These were the commonest findings in prior validation passes; design the
new test to avoid them:

1. **System bank `working_status: 'ready'`** — always set this in the
   MongoDB patch after the bank create. Without it, bot ignores the job.
2. **`method` array must include every transaction type the bank
   handles** (`deposit` / `payout` / `topup` / `settlement`).
3. **Destination account registered in mock ledger** — `POST
   ${MOCK_BANK_URL}/admin/accounts` before any payout/settlement that
   expects a bot transfer.
4. **Poll `withdrawal_queue` via MongoDB direct** for payout/settlement
   completion — REST API lags the async MDR distribution by seconds.
5. **Polling loop on partner wallet** (not just `sleep 3`) if the test
   asserts MDR distribution outcomes.
6. **Timeout path is a failure**, not a pass. Every polling loop ends
   with an explicit `TEST_RESULT=1; break` on timeout, not fall-through.

## Step 5 — Save + parse-check

```bash
chmod +x integration-tests/test-<name>.sh
bash -n integration-tests/test-<name>.sh
echo $?   # must be 0 — non-zero means syntax error, fix before continuing
```

No runtime execution. The first execution is a separate event (user or
CI).

## Step 6 — Register in **three** places

Mandatory per the existing create-test-case workflow. Missing any one of
these means the test is invisible to downstream humans and tooling.

### 6a. `.agent/workflows/run-integration-tests.md`
Append to the "Available Test Scripts" list with a one-line Thai/English
description.

### 6b. `integration-tests/run-integration-test.sh`
The echo section that lists available tests (grep for the block — it
usually prints after the "ready" banner).

### 6c. `integration-tests/mock-bank/public/test-runner.html`
Add an entry to the `TESTS` array with: `script`, `icon`, `name`,
`category`, `bank`, `type`, `desc`, `details`. If the test belongs to a
new category, also:
- Add a `.badge.<category>` CSS class.
- Add the category to the `CATEGORIES` array.

## Step 7 — Update tester's own docs

### 7a. `docs/test-coverage-gaps.md`
Mark the filled gap:
- `Status` → `filled`
- `Filled by test` → the new `test-*.sh` filename
- Do **not** delete the row (P-001 — Nothing is Deleted).

### 7b. `docs/test-index.md`
Append a new row for the test with:
- `status` = `UNKNOWN` (never run yet)
- `last_verified_commit` = current HEAD
- `root_cause` = `—`
- `proposed_fix` = `—`
- A footnote: "added <ISO date GMT+7> by tester agent; awaiting first
  runtime execution to upgrade status to VALID."

## Step 8 — File learnings for non-obvious design choices

For anything surprising in the feature being tested (e.g., an undocumented
status transition, a validation rule only visible in a middleware), file
an `arra_learn` tagged `#tester #repo:mobiz-payment-gateway #current` +
the feature tag. These are free signal for `technical_writer`.

```yaml
tags:
  - tester
  - repo:mobiz-payment-gateway
  - current
  - <feature>
  - discovered-while-testing
source: <controller/service file>:L<line>@<commit> + integration-tests/test-<name>.sh:L<line>
```

## Step 9 — Commit + PR

Before committing, verify no broken frontmatter was introduced this session:

```bash
bash $(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/scripts/verify.sh | grep -A 3 frontmatter
# expect: ✅ no double-wrap + ✅ every indexed doc has a title:
```

Branch convention: `feat/tester-test-<domain>-<variant>`.

```bash
git checkout -b feat/tester-test-<domain>-<variant>
git add \
  integration-tests/test-<name>.sh \
  integration-tests/run-integration-test.sh \
  integration-tests/mock-bank/public/test-runner.html \
  .agent/workflows/run-integration-tests.md \
  docs/test-coverage-gaps.md \
  docs/test-index.md
git commit -m "test: add integration test — <name>

- Covers <one-line feature description>
- Closes coverage gap: <row from test-coverage-gaps.md>
- Registered in runner script + test-runner.html + workflow doc.
- Never executed at CI yet; docs/test-index.md row marked UNKNOWN
  until first runtime pass upgrades it.
- Does not modify production code."

git push -u origin feat/tester-test-<domain>-<variant>
gh pr create \
  --title "test: add integration test — <name>" \
  --body "$(cat <<'EOF'
## Summary

Adds `integration-tests/test-<name>.sh` to close the
`<area>` coverage gap.

## What this test proves (when run)

<the 2–4-sentence note from Step 2>

## Setup hazards designed out

- working_status: 'ready' ✅
- method array includes <list> ✅
- mock ledger destination registered ✅
- withdrawal_queue polled via MongoDB direct ✅
- partner-wallet poll loop (not sleep) for MDR ✅
- timeout path = TEST_RESULT=1 ✅

## Mock-bank changes

None (all endpoints used pre-existed) — OR — depended on PR #<n> which
added `<endpoint>`.

## Post-merge follow-up

First runtime execution will upgrade `docs/test-index.md` row from
UNKNOWN to VALID or reveal issues via the standard validate workflow.

EOF
)"
```

**Do not merge.** Human reviews.

## Step 10 — Retrospective (session-end only)

### Per-test open questions — use threads, not handoffs

If a specific test has an unanswered question that a domain expert needs to resolve (e.g. "first runtime run — pass or fail?", "should this edge case return 400 or 422?"), open an `arra_thread` for that question with the PR URL and the test path in the message body. Anchor the question in the test script or in `docs/test-index.md` with `[AWAITING_THREAD:<id>]` so the next tester/writer pass sweeps it when resolved.

Do NOT write an `arra_handoff` for the PR — PR tracking lives in the PR itself, not in Oracle.

### Session-end — exactly once

After the **last** test of the session (whether that's test #1 or test
#N), write **one** retrospective covering the whole session. Do **not**
write a per-test retro — the retro is a session-level artifact.

```
ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_tester-add-tests-<slug>.md
```

Where `<slug>` is a short summary of the batch (e.g.
`3-deposit-cases`, `settlement-coverage`, `topup-plus-edge-cases`).

The retro body lists every test added, with per-test subsections:

```markdown
## Tests added this session

### test-<name-1>.sh
- Gap closed: <row from coverage-gaps>
- PR: #<n>
- Setup hazards designed out: <list>
- Notable design choices or surprises: <1-2 sentences>

### test-<name-2>.sh
...
```

Followed by the mandatory AI Diary and Honest Feedback sections
(per `AGENTS.md` §7 — a session without both is an incomplete session).
The Diary and Feedback cover **the session as a whole**, not each test
individually: what went smoothly, what was harder than expected,
patterns that showed up across tests, any refinement the workflow
itself needs.

### Why session-level, not per-test

Per-test retros produced on-the-fly during a multi-test session
fragment the narrative. A reader trying to understand "what happened
that day" has to stitch 5 files together. A session-level retro is the
coherent log — the per-test details live in the PR bodies and the
subsection list above, which is the right granularity for future
search.

### Vault path reminder

Write the retro to `~/.arra-oracle-v2/ψ/memory/retrospectives/…` —
**not** `~/.arra-oracle/ψ/memory/…`. See SKILL § "Vault path (the #1
trap)" and `AGENTS.md` §11. The indexer only scans the v2 path.

## Common pitfalls this workflow has hit before

*(populated over time)*

- **Skipping Step 3 (mock-bank readiness).** The test gets written,
  parses fine, runs, hangs at the mock-bank call, times out → marked
  "passed" if the timeout path was not asserted. Always check mock
  endpoints first.
- **Copying a similar test without updating placeholder names.** The
  trap name `cleanup_<test_name>` literally contains `<test_name>` in a
  merged PR once. Grep for `<` after drafting — there should be none.
- **Forgetting Step 6c (test-runner.html).** The test runs from CLI but
  never appears in the UI. `technical_writer` may ask why the docs list
  only 35 tests when 36 exist in the tree. That is drift. Register all
  three places or don't ship.

---

**Created:** 2026-04-16 (GMT+7) · workflow owner: `tester` agent.
