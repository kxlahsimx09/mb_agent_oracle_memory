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
- **Runtime-iterate until the test works — or bail with an honest report.**
  Default path: `bash -n` parse check, then execute the test, then
  fix-and-retry until it exits 0 (for regression tests) or lands in the
  expected failure mode (for forward-looking tests — see Step 5 Part B).
  This is the opposite of the pre-2026-04-20 policy (which left
  first-execution to CI) — runtime drift has historically hidden in
  UNKNOWN rows for weeks. Now it gets caught in the same session.
- **Escape hatch — "unusually long" tests.** If the test is demonstrably
  slow (criteria in Step 5), skip runtime, leave `docs/test-index.md`
  row as `UNKNOWN`, and **report plainly to the user**: "test added but
  not runtime-verified, reason: <criterion>". Do not silently ship. See
  Step 5 Part C for the criteria.
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

Mock-bank has **three fixture surfaces**, each a separate readiness
concern. Missing any one produces a silent half-working test — the
endpoint answers, the server-state flag toggles, but the behavior the
test actually depends on never fires. Always check all three.

### 3a. Server endpoints — API routes that simulate production

```bash
grep -nE "app\.(get|post|put|delete)\('/api/" integration-tests/mock-bank/server.js
```

These mirror real bank APIs (`/api/ktb/login`, `/api/transfer/approve`,
etc.). Missing → standard `mock-bank-sync-check` hand-off.

### 3b. Admin toggle endpoints — fixture control plane

```bash
grep -nE "app\.(get|post|put)\('/admin/" integration-tests/mock-bank/server.js
```

Examples: `/admin/accounts`, `/admin/ktb/break-otp-confirm`,
`/admin/shuffle-pending`, `/admin/set-config`. This category is
test-only instrumentation (no production counterpart) — lives only on
mock-bank.

### 3c. Client-side HTML/JS fixtures — browser behavior

```bash
# flags + condition branches that gate mock behavior
grep -rnE "_brk|_fixture|mock-only|// TEST|// Fixture" \
  integration-tests/mock-bank/public/
```

**Critical distinction:** an admin toggle endpoint returning
`{success: true}` does NOT mean the corresponding client-side
behavior will fire. Admin toggle (3b) and client honor-it (3c) are
**separate surfaces** — both must be ready.

**Case study — 2026-04-20 debug session (Oracle thread #26):**
`/admin/ktb/break-otp-confirm` toggled server state correctly
(`state.ktbBreakOtpConfirm.has(acc) == true`), but `ktb.html:437`
fetched the status flag at page load — before `/api/ktb/login` set
the session cookie — so `getSessionBankAccount()` fell back to the
mock-bank container's `BANK_ACCOUNT` env default, never matched the
toggled account, and client-side `_brkOtpConfirm` stayed `false` for
the entire page lifetime. Fixture silently no-op'd, test half-passed.
Hours of debug before 3c surfaced as the broken layer.

**Heuristic for checking 3c when the test depends on client behavior:**

1. Grep the HTML/JS flag the test presupposes (e.g., `_brkOtpConfirm`).
2. Read the condition that gates it. Common gates: URL query param,
   session cookie, `document.readyState`, fetch timing.
3. Ask yourself: *"If my test toggles the admin endpoint at time X,
   when does the browser observe the flag change? Before or after the
   action that should trigger the fixture?"*
4. If you cannot answer confidently → **red flag** — trace via bot
   container logs, mock-bank `console.log` instrumentation (temporary
   only), or browser devtools (non-headless run) before trusting the
   fixture.

### 3d. Smoke-test the round-trip BEFORE drafting test logic

If the test depends on a fixture + admin toggle (i.e. 3b+3c combo),
verify round-trip works before writing Step 4:

```bash
# Toggle ON for target account
curl -X POST "$MOCK_BANK_URL/admin/<fixture>" \
  -H "Content-Type: application/json" \
  -d '{"account_number":"<target>","enabled":true}'

# Probe that the status endpoint (used by ktb.html/scb.html on page load)
# reflects the toggle for THIS account specifically
curl "$MOCK_BANK_URL/admin/<fixture>/status?account=<target>"
# expect: enabled:true + account:<target>

# Manual: open /<bank-page>?account=<target> via headless Playwright or
# non-headless browser, trigger the action, observe whether the fixture
# fires via: bot container logs, temporary mock-bank console.log,
# or browser devtools.
```

If toggle → status mismatch, or status OK → client behavior not
observed ⇒ 3c gap is open. Do NOT write around it in the test. Hand
off to `mock-bank-sync-check` to fix the root cause.

### 3e. If anything is missing — hand off to `mock-bank-sync-check`

Covers all of:

- New `/api/` endpoint (3a)
- New `/admin/` toggle endpoint (3b)
- New JS fixture block in a bank HTML page (3c)
- **Edit to an existing fixture** (e.g. `break-otp-confirm` v2 → v3) —
  treat as a change requiring its own review commit, not a "small fix"
  inlined into the test PR.

Never inline a mock-bank change into a test PR. Every mock change is
its own review commit so `mock-bank-sync-check` can verify the full
3-surface contract.

### 3f. Consult `integration-tests/mock-bank/FIXTURES.md` for known fixtures

Before grep-ing (3a/3b/3c), check if the fixture you need is already indexed:

```bash
cat integration-tests/mock-bank/FIXTURES.md
```

Entries are shaped `(admin endpoint, client behavior, gate conditions, applies-to, used-by)` — faster than grepping and surfaces non-obvious gotchas (e.g. pre-login fetch timing gates). If your fixture is NOT in FIXTURES.md → either it's a true unknown (proceed to 3a/3b/3c) or FIXTURES.md has drifted (re-audit via this thread #28).


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

## Step 5 — Save, parse-check, run, iterate

### Part A — Syntax parse (mandatory first gate)

```bash
chmod +x integration-tests/test-<name>.sh
bash -n integration-tests/test-<name>.sh
echo $?   # must be 0 — non-zero means syntax error, fix before continuing
```

### Part B.0 — Ensure docker images match the source you're testing

Running against a stale image is the silent #1 cause of "I just fixed
that bug why is it still broken" — 2026-04-20 session ate 3-4
rebuild-debug cycles on mock-bank alone before the pattern became
obvious. Always rebuild the services whose source you've touched
**before** the first run, and again after each iteration edit.

**Rebuild mapping (by changed path):**

| Changed path | `docker compose -f integration-tests/docker-compose.yml up -d --build <svc>` |
|---|---|
| `controllers/` `services/` `models/` `helpers/` `routes/` `main.go` `db/` `middlewares/` | `backend` |
| `integration-tests/mock-bank/server.js` | `mock-bank` |
| `integration-tests/mock-bank/public/*.html` | `mock-bank` |
| `bank-bot/**/*.js` | `bank-bot bank-bot-ktb` (add stress variants if active) |
| `integration-tests/test-runner/**` | `test-runner` |
| `integration-tests/test-*.sh` | **no rebuild** — `-v .:/tests` mount reflects live |
| `integration-tests/helpers/*.sh` | **no rebuild** — same mount |
| `.agent/**`, `docs/**`, vault files | **no rebuild** — not consumed at runtime |

**Targeted vs lazy:**

- **Targeted** (preferred — precise): rebuild only affected services.
  ~5s cache-hit, ~30-60s genuine rebuild.
- **Lazy** (when unsure): `docker compose -f integration-tests/docker-compose.yml up -d --build`
  — rebuilds everything; cache makes the unchanged parts nearly-free.
  ~5-10s total if nothing changed, ~60s if one service changed.

**Verify post-rebuild** (cheap gate, catches silent Docker cache bugs):

```bash
# Example: mock-bank HTML edit
docker exec integration-tests-mock-bank-1 \
  grep -c "<unique-marker-string-from-your-edit>" /app/public/ktb.html
# expect > 0

# Example: backend binary
docker exec integration-tests-backend-1 \
  wget -qO- http://localhost:3099/<new-endpoint> | head -c 100
```

If the marker/string isn't in the container → something in the
compose/cache layer is stale; `docker compose down` + `up -d --build`
and re-verify before running the test. Do NOT iterate on the test
itself until the image has your latest code.

### Part B — Runtime execution and fix-and-retry

Ensure the test env is up (`docker compose -f integration-tests/docker-compose.yml
ps` — all services `healthy`; if not, `docker compose up -d`).

Run via test-runner web UI (`localhost:8080`) OR direct docker exec
(faster for iteration — but **must pass `DOCKER_MODE=true
TEST_RUNNER_MODE=1`** env, otherwise `setup-infra.sh` falls back to
`docker compose exec -T` which fails inside test-runner — see
`learning_2026-04-20_when-running-integration-tests-via-direct-docker`):

```bash
docker exec -e DOCKER_MODE=true -e TEST_RUNNER_MODE=1 \
  integration-tests-test-runner-1 \
  bash -c "cd /tests && ./test-<name>.sh"
```

**Iterate until green:**

- **PASS (`exit 0`)** → proceed to Step 6.
- **FAIL** → read the logs (test stdout, `docker logs integration-tests-bank-bot-*-1`,
  `docker logs integration-tests-mock-bank-1`, `docker logs integration-tests-backend-1`),
  identify the gap, fix *within scope* (test script, mock-bank fixture,
  test-runner env — NEVER production code), and re-run.
- **Forward-looking test** (header contains an `[AWAITING_THREAD:N]`
  marker — a convention some tests use to flag dependency on an
  open drift thread) → "PASS" means the observed failure mode matches
  the expected drift described in the thread, not `exit 0`. Example:
  `test-payout-ktb-post-otp-waiting-to-review.sh` at thread #16 HEAD
  expected `withdrawal_queue.status = 'failed'`; after thread #16 fix
  it flipped to `waiting_to_review`. Match the expectation, commit.

**State cleanup between iterations:** most tests generate fresh
timestamped entities (`TS=$(date +%s)`) — iterations don't conflict on
identity. But they share mock-bank ledger, withdrawal_queue collection,
and bank `working_status`. If state accumulation causes confusion, reset
between runs via mock-bank's admin reset or `docker compose down &&
docker compose up -d`.

### Part C — "Unusually long" escape hatch

If running the test would exceed the session time budget or tie up the
test-runner for other work, skip runtime and report honestly. Criteria
(any single match → skip):

| Criterion | Threshold |
|---|---|
| `MAX_WAIT` or any single polling-loop cap | > 600s (10 min) |
| Test filename / header contains | `stress`, `burst-multi`, `multi-bank-stress`, `load` |
| Scheduler cadence the test waits on | > 15 min (e.g., some deposit-expiry / pullout-task variants) |
| Stated expected end-to-end duration in header comment | > 8 min |
| Test relies on a fixture / PR not yet merged | blocked by external thread |

**If skipped:**
1. Complete Parts A + verify via manual inspection (read the script
   against the template in SKILL).
2. `docs/test-index.md` row → `status: UNKNOWN` with footnote: "added
   <date> — runtime skipped, reason: <criterion>. First runtime pending
   CI or manual run."
3. In the session-end report to user, say plainly: "test added but
   **not runtime-verified** — reason: <criterion>." Don't bury this in
   a retrospective.
4. If the blocker is a not-yet-merged fixture/PR, file the dependency
   as `[AWAITING_THREAD:N]` in the test header (see
   `test-payout-ktb-post-otp-waiting-to-review.sh` for the canonical
   example) — future runs will auto-flip it green when the blocker
   resolves.

### Part D — If stuck on a non-test bug

If the failure is in production code (not the test, fixture, or test
env), stop iterating. Production code is read-only in this workflow.
Options:
1. Open an `arra_thread` documenting the drift (anchor: the test script
   + reproduction). Route to the appropriate repo owner (bot-writer for
   bank-bot drift, pg-writer for gateway drift).
2. Mark the test row `UNKNOWN` with footnote "blocked by thread #N".
3. Commit the test anyway — it becomes a regression tripwire when the
   drift closes.

Never patch production code to make a new test pass. That inverts the
tripwire — the test would no longer catch real drift, only the drift
you papered over.

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
Append a new row for the test. `status` value depends on the Step 5
outcome:

| Step 5 outcome | `status` | Footnote |
|---|---|---|
| Part B ran green (`exit 0`) | `VALID` | "added <ISO date GMT+7> by tester agent; runtime-verified in-session at commit <sha>." |
| Part B matched expected forward-looking failure mode | `VALID` (forward-looking) | "added <date>; runtime-verified as expected-red per [AWAITING_THREAD:N] — will flip to regression tripwire when thread closes." |
| Part C skipped (unusually long) | `UNKNOWN` | "added <date> — runtime skipped, reason: <criterion>. First runtime pending CI or manual run." |
| Part D stuck on production bug | `UNKNOWN` | "added <date> — blocked by thread #N; test is a regression tripwire for that drift." |

`last_verified_commit` = current HEAD, `root_cause` = `—`,
`proposed_fix` = `—`.

## Step 8 — File learnings for non-obvious design choices

For anything surprising in the feature being tested (e.g., an undocumented
status transition, a validation rule only visible in a middleware), file
an `arra_learn` via the MCP tool. These are free signal for `technical_writer`.

**Do NOT include markdown frontmatter in the `pattern` body** — arra_learn
wraps its own `---\ntitle: ...\n---` around whatever you pass. Pre-wrapped
input produces the nested double-wrap bug (filename `_title-*`, outer
`title: ---`, caught by verify.sh). Metadata goes in the separate
`concepts`, `source`, and `project` parameters; the first line of `pattern`
is the headline and seeds the slug.

```
arra_learn(
  pattern="<one-line headline: what the surprise is and where>

<1–3 paragraph explanation of the behaviour: what the code actually does,
why it matters for tests and docs, and any hidden invariant the reader
should carry forward>.",
  concepts=["tester", "repo:mobiz-payment-gateway", "current",
            "<feature>", "discovered-while-testing"],
  source="<controller/service file>:L<line>@<commit> + integration-tests/test-<name>.sh:L<line>",
  project="github.com/kokarat/mobiz-payment-gateway"
)
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
- Runtime outcome: <VALID (exit 0) | VALID (expected-red per AWAITING_THREAD:N) | UNKNOWN (reason: <criterion>)>
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

## Runtime verification

- [ ] Ran green in-session (`exit 0`) → `docs/test-index.md` = `VALID`
- [ ] Ran as expected-red per `[AWAITING_THREAD:N]` → `VALID` (forward-looking)
- [ ] Skipped (unusually long) → `UNKNOWN`, reason: `<criterion>` — first
      runtime pending CI/manual.

## Post-merge follow-up

If status = `UNKNOWN`, first runtime execution (CI or manual) upgrades
`docs/test-index.md` via the standard validate workflow.

EOF
)"
```

**Do not merge.** Human reviews.

## Step 10 — Retrospective (session-end only)

### Per-test open questions — use threads, not handoffs

If a specific test has an unanswered question that a domain expert needs to resolve (e.g. "should this edge case return 400 or 422?", "is this expected failure mode correct?"), open an `arra_thread` for that question with the PR URL and the test path in the message body. Anchor the question in the test script or in `docs/test-index.md` with `[AWAITING_THREAD:<id>]` so the next tester/writer pass sweeps it when resolved.

**Note:** "first runtime run — pass or fail?" should no longer reach this step since Step 5 now runtime-iterates in-session. If it does appear, that's a signal the test hit Part C (unusually long) or Part D (production blocker) — both already carry their own `[AWAITING_THREAD:N]` marker, so a duplicate thread here would be redundant.

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
- **`arra_learn(pattern=...)` expects prose, not a pre-wrapped markdown
  doc.** arra_learn wraps its own `---\ntitle: ...\n---` around whatever
  you pass as `pattern`. Passing a document that already contains a
  frontmatter block (e.g. an earlier arra_learn output, or hand-authored
  markdown starting with `---\ntitle: ...`) produces the nested
  **double-wrap** bug: filename begins `_title-*`, outer `title: ---`,
  two frontmatter blocks, `verify.sh` flags it. A tool-side strip-and-warn
  guard landed 2026-04-19 (Soul-Brews-Studio/arra-oracle-v3
  `stripFrontmatterWrap`), and the Step 8 template above was rewritten
  the same day to use the `arra_learn(pattern=..., concepts=..., ...)`
  function-call form. Keep `pattern` as 1–2 paragraphs of plain prose
  and rely on the guard only as a safety net.

## Memory/search/trace anomalies — escalate to brew-ops (non-blocking)

**Fire-and-forget.** Filing a handoff does NOT block this workflow or wait on brew-ops. Finish your pass normally (Step 10 retro + commit) — brew-ops picks up asynchronously on its next session. No `[AWAITING_...]` anchor, no Step 0 sweep. The handoff file itself is the durable record.

If your pass encounters one of these patterns and cannot resolve it in scope:

| Symptom | Likely cause |
|---|---|
| `arra_search` returned 0 for content you know exists | possible FTS5 / vector / tokenizer drift |
| `arra_learn` succeeded but search can't find the new entry | possible indexer / vector connect race |
| `arra_trace` succeeded but `arra_trace_get` returns missing fields | possible trace tool bug (e.g., 2026-04-21 trace project-corrupt incident) |
| `arra_supersede` says success but old doc still appears un-flagged | possible supersede chain breakage |
| Closed thread leaves `[AWAITING_THREAD:N]` markers stranded across repos | cross-repo orphan — see workflow-5 §13c |
| `verify.sh` fails with new pattern not covered by existing fixes | possible new corruption class |
| Path-typo files (`bank-bot<`, `pure-bot`, etc.) keep recurring | input-validation gap |

Don't try to debug in-pass. File a handoff at:

```
$(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/ψ/inbox/handoff/<YYYY-MM-DD>_<HH-MM>_brew-ops_<topic>.md
```

Format per `arra-oracle-v3/.agent/skills/brew-ops/references/workflow-5-memory-audit.md` §How this workflow gets triggered → §B (Escalated handoff). brew-ops picks up on next fresh wake; **your workflow does not wait.**

If unsure whether to escalate: file a P2 handoff with `expected outcome: investigation only`. brew-ops can downgrade to "no action needed" cheaply; a missed real signal is more expensive.

---

**Created:** 2026-04-16 (GMT+7) · workflow owner: `tester` agent.
**Revised:** 2026-04-19 (GMT+7) — Step 8 `arra_learn` template
rewritten from YAML-frontmatter-blob form to `arra_learn(pattern=...,
concepts=..., source=..., project=...)` function-call form (sibling-
synced with workflow-1 Step 5 and workflow-3 Step 7 the same day).
The earlier template was isomorphic to the arra_learn "double-wrap"
corruption signature recovered from technical-writer territory on
2026-04-19. Common pitfall bullet added.
**Revised:** 2026-04-20 (GMT+7, part 1) — Step 3 expanded to 3-surface
mock-bank readiness check (server endpoints / admin toggles / client-
side HTML-JS fixtures) after 2026-04-20 debug session evidenced that
admin-toggle success does NOT imply client-side behavior fires (Oracle
thread #26).
**Revised:** 2026-04-20 (GMT+7, part 2) — Policy inverted for runtime
validation: new tests now runtime-iterate in-session until green (or
match expected-red for `[AWAITING_THREAD:N]` forward-looking tests);
"unusually long" escape hatch defined with concrete criteria (Step 5
Part C). `docs/test-index.md` row status is now outcome-dependent
(VALID / UNKNOWN) instead of blanket UNKNOWN. Step 7b, Step 9 commit
body, and PR body template updated accordingly.
**Revised:** 2026-04-20 (GMT+7, part 3) — Step 5 Part B.0 added:
rebuild-mapping cheatsheet + post-rebuild verify step to prevent
iterating against stale docker images (the 2026-04-20 session ate
3-4 debug cycles on mock-bank before the stale-cache pattern surfaced).
**Revised:** 2026-04-20 (GMT+7, part 4) — Step 3f (FIXTURES.md
consult) removed — placeholder HTML comment left pointing at Oracle
thread #28. Intention: restore Step 3f only after the fixture
inventory audit (thread #28) completes; a partial FIXTURES.md would
false-advertise coverage and readers would skip the 3a/3b/3c greps.
**Revised:** 2026-04-21 (GMT+7, part 5) — Step 3f restored (FIXTURES.md
seeded with `break-otp-confirm` × 2 per Oracle thread #28). The
placeholder HTML-comment block at lines 194–200 was replaced with the
live Step 3f section; the audit candidates from thread #28 remain open
as a TODO list at the bottom of FIXTURES.md and will be filled
opportunistically per thread #28's "let it accumulate organically"
guidance. Thread #28 closed by the PR that landed this edit.
