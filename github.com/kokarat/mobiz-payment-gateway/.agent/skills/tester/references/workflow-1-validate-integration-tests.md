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

For every STALE / WRONG-SETUP / FLAKY row, emit one learning via the arra_learn MCP tool. **Do NOT include markdown frontmatter in the `pattern` body** — arra_learn wraps its own `---\ntitle: ...\n---` around whatever you pass, and a pre-wrapped input produces the nested double-wrap bug (filename `_title-*`, outer `title: ---`, caught by verify.sh). Pass metadata via the separate `concepts`, `source`, and `project` arguments; let the first line of `pattern` carry the headline.

```
arra_learn(
  pattern="<STATUS> — <test-name> — <one-line-cause>

What's wrong: <1–3 sentences>.

Why this is wrong: <cite the rule from integration-test-writer SKILL.md or the changed commit>.

Minimal fix (proposed, not applied): <one paragraph, or a diff-style snippet>.

Impact if unfixed: <what false-signal this test emits today>.

Related: <prior tester learning ids if continuing a thread; omit line if none>.",
  concepts=["tester", "repo:mobiz-payment-gateway", "current",
            "<stale-test | wrong-setup | flaky-test>",
            "<feature tag e.g. deposit / payout / settlement / bank-bot>"
            /* add "drift" if the cause is a mock-bank or endpoint rename */],
  source="integration-tests/<test>.sh:L<line> + <production file>:L<line>@<commit>",
  project="github.com/kokarat/mobiz-payment-gateway"
)
```

Substitute `<STATUS>` with `STALE`, `WRONG-SETUP`, or `FLAKY` on the first line of `pattern` — arra_learn derives both the title and the filename slug from those first ~50–80 characters, so lead with the status + test name for searchable filenames like `2026-04-19_stale-test-payout-foo-endpoint-removed-.md`.

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

## Step 7 — Commit + PR (3 min new / 4 min amend)

Before committing, verify no broken frontmatter was introduced this session:

```bash
bash $(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/scripts/verify.sh | grep -A 3 frontmatter
# expect: ✅ no double-wrap + ✅ every indexed doc has a title:
# if ❌ or ⚠️ — fix via /tmp/fix-frontmatter.py before proceeding
```

The validate suite produces a single PR per pass. If a previous tester-validate PR is still open (human hasn't merged yet) the next run **extends** it instead of stacking — same shape as W2 Step 8.0/8.A/8.B (mb_agent_oracle_memory commit `0357769`) and W9 Step 8.0/8.A/8.B (commit `0bdfdc3`), with the `feat/tester-validate-` branch prefix that distinguishes tester PRs from writer PRs. Tester W1's stack risk is lower than W2's because the date suffix gives each daily run a unique branch name, but two runs on consecutive days against the same set of unmerged docs (`docs/test-index.md` + `docs/test-coverage-gaps.md`) would conflict at merge time and produce duplicate `arra_learn` filings — the amend path avoids both.

### 7.0 — Detect open tester-validate PR (run first)

```bash
existing_pr=$(gh pr list --search "head:feat/tester-validate- state:open" --author "@me" \
  --json number,headRefName,title --jq '.[0]')
```

- empty → continue with **7.B** (new PR path).
- non-empty → switch to **7.A** (amend path).

### 7.A — Amend path (existing tester-validate PR open)

```bash
branch=$(jq -r .headRefName <<< "$existing_pr")
pr_num=$(jq -r .number <<< "$existing_pr")

git fetch origin
git checkout "$branch"
git merge --no-edit origin/main    # absorb new main commits
# Conflicts in docs/test-index.md or docs/test-coverage-gaps.md are
# expected if the prior pass's findings overlap with this pass —
# resolve manually by accepting the union (P-001: prior findings retained,
# new findings appended).
# Conflicts in test-*.sh files → out-of-territory; abort + retro note
# (tester does not patch tests in W1).
```

Layer the new validation results on top with an "extend" subject:

```
chore(tester): extend validate to baseline <new-sha> (W1 amend; cumulative since <orig-sha>)

Adds N new test-*.sh evaluations to PR #<pr_num>. Status delta:
- V: +x  S: +y  W: +z  F: +w  SUP: +v  UNK: +u
- Filed N new arra_learn entries (PR cumulative now: N+M).

No test scripts modified. No production code touched.
```

Push + rewrite PR metadata to reflect the **cumulative** range:

```bash
git push origin "$branch"
gh pr edit "$pr_num" \
  --title "chore(tester): validate integration tests — cumulative <orig-sha>..<new-sha> (W1, amended)" \
  --body "<regenerated body — full Status breakdown across BOTH passes (cumulative), Top findings deduplicated, all arra_learn ids listed cumulatively, end with 'Do not merge. Wait for human review.'>"
```

Skip to Step 8. Do **not** open a second PR.

### 7.B — New PR path (no existing tester-validate PR)

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

**Path discipline (load-bearing — see §The ψ/ trap).** Before writing, verify the vault symlink resolves:

```bash
readlink ~/.arra-oracle-v2/ψ | grep -q "mb_agent_oracle_memory/ψ$" \
  || { echo "FAIL: ~/.arra-oracle-v2/ψ does not resolve to the canonical vault — halt"; exit 1; }
```

**Write to:**
```
~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_tester-validate.md
```

**Never to any of these traps:**
- ❌ `ψ/memory/retrospectives/...` — relative path, lands in your current cwd (worktree tree)
- ❌ `./ψ/memory/retrospectives/...` — same
- ❌ `<project-path>/ψ/memory/...` — absolute but wrong root; `project` is the product repo, not the vault
- ❌ `.agent/../ψ/memory/...` — symlink traversal may misresolve through the vault's own project subdir

`rrr` template — AI Diary and Honest Feedback are mandatory (AGENTS.md §7). Cover:

- What the validation turned up that was surprising.
- Any rule in the integration-test-writer SKILL that feels outdated or
  ambiguous after this run (propose a refinement, don't apply it).
- Any patterns that recurred across multiple tests (e.g., "5 tests all
  miss `working_status: 'ready'`") — candidate for a shared helper.

**After writing, verify no stray landed in the project tree:**

```bash
SLUG="<slug-you-used>"  # e.g., 14.05_tester-validate-first-baseline
# This MUST return empty — any hit = stray leak, follow recovery in §The ψ/ trap.
find ~/Code/github.com/kokarat/mobiz-payment-gateway \
  -path '*/ψ/memory/*' -name "*${SLUG}*" \
  -not -path "*/.agent/*" 2>/dev/null
# And the canonical location MUST exist:
ls ~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/${SLUG}.md
```

**Recovery if stray found** (do NOT just delete — content may not be in vault yet):
```bash
STRAY="<stray-path-from-find>"
VAULT_DEST=~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/
mkdir -p "$VAULT_DEST"
if [ -f "$VAULT_DEST/$(basename "$STRAY")" ]; then
  diff -q "$STRAY" "$VAULT_DEST/$(basename "$STRAY")" && rm "$STRAY" || echo "differs — merge manually"
else
  mv "$STRAY" "$VAULT_DEST"
fi
(cd $(ghq list -p Soul-Brews-Studio/arra-oracle-v3) && bun run index)
```

---

## The ψ/ trap (why path discipline in Step 8 matters)

`ψ/memory/` looks like a vault-relative path but is not. The **canonical vault** lives at:

```
$(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/ψ
```

surfaced to agents via the symlink `~/.arra-oracle-v2/ψ → <vault>/ψ`. Writes going through that symlink land in the vault correctly.

A **stray `ψ/` directory at the root of this project repo** (`mobiz-payment-gateway/ψ/`) would look identical to a vault path but:

1. **Not indexed by Oracle** — `arra_search` can't find it.
2. **Invisible to other agents** — defeats the "shared memory" design.
3. **May get git-tracked accidentally** — `ψ/` is NOT in this repo's `.gitignore` as of 2026-04-19. Once `git add` catches it, it enters the payment-gateway product repo's permanent history.

Historical incidents:
- **21 files** already committed to `mobiz-payment-gateway` git history from this trap, across three failed cleanup attempts (commits `414f568` / `2965cda` / `da4d13a`).
- **2026-04-19 15:06**: a W2 run wrote its retro to `mobiz-payment-gateway/ψ/memory/retrospectives/2026-04/19/15.06_w2-track-commit-admin-cancel-payout.md` (stray) instead of `~/.arra-oracle-v2/ψ/memory/retrospectives/2026-04/19/15.06_...` (vault). Recovered by manually moving to vault + re-indexing (see `arra_search "ψ-trap-retro-leak"`). The same trap shape applies to tester W1 — only W2 was bitten that day because tester W1 hadn't run, but the retro template was vulnerable.

Step 8's pre-write symlink check + post-write stray-find is the fix. Both must pass. Retro is not "done" until the stray check returns empty.

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
- **`arra_learn(pattern=...)` expects prose, not a pre-wrapped markdown
  doc.** arra_learn wraps its own `---\ntitle: ...\n---` around whatever
  you pass as `pattern`. Passing a document that already contains a
  frontmatter block (e.g. an earlier arra_learn output, or hand-authored
  markdown starting with `---\ntitle: ...`) produces the nested
  **double-wrap** bug: filename begins `_title-*`, outer `title: ---`,
  two frontmatter blocks, `verify.sh` flags it. A tool-side strip-and-warn
  guard landed 2026-04-19 (Soul-Brews-Studio/arra-oracle-v3
  `stripFrontmatterWrap`), and the Step 5 template above was rewritten
  the same day from a YAML-blob form that literally prescribed this
  pattern. Keep `pattern` as 1–2 paragraphs of plain prose and use the
  function-call form shown in Step 5; rely on the guard only as a
  safety net.

## Memory/search/trace anomalies — escalate to brew-ops (non-blocking)

**Fire-and-forget.** Filing a handoff does NOT block this workflow or wait on brew-ops. Finish your pass normally (Step 8 retro + commit) — brew-ops picks up asynchronously on its next session. No `[AWAITING_...]` anchor, no Step 0 sweep. The handoff file itself is the durable record.

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
**Revised:** 2026-04-19 (GMT+7) — Step 5 `arra_learn` template
rewritten from YAML-frontmatter-blob form to `arra_learn(pattern=...,
concepts=..., source=..., project=...)` function-call form. Backstory:
the earlier template was isomorphic to the arra_learn "double-wrap"
corruption signature (eleven such learnings recovered on 2026-04-19
across technical-writer territory — the tester template had not yet
been exercised but was equally exposed). Sibling-synced with the
technical-writer W2/W8 pitfall additions the same day. Common pitfall
bullet added; Step 9 verify.sh gate remains the pre-commit backstop.
**Revised:** 2026-04-21 (GMT+7, brew-ops) — **Step 8 retro path
discipline + §The ψ/ trap section added.** Port from W2's 2026-04-19
fix after the live retro-leak incident at
`mobiz-payment-gateway/ψ/memory/retrospectives/2026-04/19/15.06_w2-
track-commit-admin-cancel-payout.md` (21 stray files committed in
mobiz history across 3 failed cleanup attempts). Tester W1 had been
using a relative `ψ/memory/retrospectives/...` path which is exactly
the trap shape — the workflow had never been bitten because tester W1
had only run once (2026-04-16 first baseline), but the template was
load-bearing for any future run. Step 8 now mandates pre-write
`readlink ~/.arra-oracle-v2/ψ` check + absolute-path-via-symlink
write target + post-write stray-find with documented recovery
recipe. New §The ψ/ trap section (inserted before §Common pitfalls)
explains the topology + cites historical incidents from W2's prior
exposure. No tester-specific change to behavior; pure path
discipline propagation. No bank-bot tester sibling to sync (bank-bot
has no tester role yet).
**Revised:** 2026-04-21 (GMT+7, brew-ops, later same session) —
**Step 7 split into 7.0 (detect) → 7.A (amend) / 7.B (new).** Mirrors
W2 Step 8.0/8.A/8.B (mb_agent_oracle_memory commit `0357769`) and W9
Step 8.0/8.A/8.B (commit `0bdfdc3`) with the `feat/tester-validate-`
branch prefix that distinguishes tester PRs from writer PRs. Stack
risk for tester W1 is lower than W2 (date suffix gives each daily run
a unique branch name) but two unmerged passes on consecutive days
would conflict at merge time on `docs/test-index.md` +
`docs/test-coverage-gaps.md` and produce duplicate `arra_learn`
entries — 7.A's amend path avoids both via single-PR-per-cycle
discipline. Independent gate from W2's `docs/track-` PR gate and W9's
`docs/flow-track-` PR gate (different branch prefix). Tester W1 not
yet in the watcher today; this prepares the spec for when manual
multi-day cadence happens or watcher integration lands.
