---
description: Detect drift between what bank-bot expects and what mock-bank provides (ตรวจว่า mock ตอบโจทย์สิ่งที่ bot ต้องการไหม)
owner: tester
autonomy: read-only (proposes edits; no silent writes to server.js)
---

# Workflow 3 — Mock-Bank Sync Check

Mock-bank is the **only thing `bank-bot` talks to** during integration
tests. It simulates a real bank's internet-banking portal (SCB Business
Anywhere, KTB, …) so the Puppeteer-driven bot can log in, read
statements, enter OTPs, submit transfers — exactly as it would against
production.

**The backend never talks to mock-bank directly.** The architecture
is strictly:

```
┌─────────┐     HTTP API      ┌──────────┐   Puppeteer/HTTP   ┌───────────┐
│ backend │ ←───(bot reports)─│ bank-bot │ ─────────────────→ │ mock-bank │
└─────────┘                   └──────────┘                    └───────────┘
             bot polls & reports             bot drives the portal
             results via /api/v1/bot/**      like a human would
```

So the contract this workflow validates is **mock-bank ↔ bank-bot**:
*"does the mock render the pages, selectors, and response shapes the
bot is coded to expect?"* Any drift between mock and bot shows up as a
test that hangs, times out, or silently "passes" while doing nothing
useful.

> Tests also hit mock-bank over an `/admin/**` API to set up fixtures
> (balances, inbound transfers, OTP behavior). That surface is a
> **fixture contract**, not the bot contract. It's covered in Step 4 as
> a secondary check.

> If you grep mock-bank's `server.js` and find `fetch(` / `axios` calls
> to the backend, those are **test-glue convenience calls** (e.g., the
> mock posts an OTP it generated to a backend debug log), not part of
> the live contract. Note them for completeness in Step 5 but do not
> weigh them — the bot is still the only production consumer.

## Scope & rules

- **Read-only on production code** (backend + bank-bot).
- **Read-only on `server.js`** during the *check* phase. Remediation is
  a proposal in the PR body — not a silent patch. Every mock-bank edit
  requires user sign-off and lands in its own commit with a linked
  `arra_learn`.
- No runtime execution. Static cross-read only.

## When this workflow runs

Pick any of these as the trigger:

1. **On user request:** "check mock-bank", "mock-bank drift", "mock ยัง
   ตรงกับ bot ไหม".
2. **Automatically suggested by the wake-up ritual** when either
   `integration-tests/mock-bank/**` or `bank-bot/**` changed since the
   last tester session.
3. **Escalation from workflow-1** when a STALE / WRONG-SETUP test cites
   a mock-bank mismatch as its root cause.

## Prerequisites

- Wake-up ritual complete.
- Open: `integration-tests/mock-bank/server.js`,
  `integration-tests/mock-bank/public/**` (any static HTML/JS served as
  the portal UI), `integration-tests/mock-bank/README.md`, and every
  adapter under `bank-bot/src/`.

## Step 1 — Inventory mock-bank's provided surface

### 1a. HTTP routes served by mock-bank

```bash
grep -nE "app\.(get|post|put|delete|patch)\s*\(" \
  integration-tests/mock-bank/server.js
```

For each route record method, path, and a one-line purpose. Partition
by audience:

- **Bot/portal surface** — routes the bot hits as if it were a browser
  driving the real bank. Login forms, statement pages, transfer
  submission, OTP verify, session/heartbeat endpoints. These are the
  **contract** this workflow validates.
- **Admin/fixture surface** — `/admin/**` routes tests use to
  pre-seed state (accounts, balances, inbound transfers). Validated in
  Step 4 as a secondary check.
- **Static UI** — files under `mock-bank/public/` served as HTML for
  the bot's Puppeteer pages. Include their IDs, `data-testid`
  attributes, and form field names in the inventory — selectors count
  as surface.

### 1b. README cross-check

```bash
cat integration-tests/mock-bank/README.md
```

Anything documented in README but not found in 1a, or vice versa, is
its own drift row (doc↔code drift of the mock itself). File as
`#drift #mock-bank` with an explicit `doc-vs-impl` sub-tag.

## Step 2 — Inventory what the bank-bot expects *from* mock-bank

This is the primary contract. The bot is the only production-shaped
consumer of mock-bank's portal surface.

### 2a. Per-adapter walk

```bash
ls bank-bot/src/          # typically one subdir per bank: scb/, ktb/, …
```

For each adapter, extract every call the bot makes against the portal.
Look for at least these patterns:

```bash
# HTTP calls (if the bot uses request/fetch for certain endpoints)
grep -rnE "fetch\(|axios\.|got\(|request\(|http\.(get|post)" \
  bank-bot/src/

# Puppeteer page interactions
grep -rnE "page\.(goto|click|type|waitForSelector|\$|\$\$|\$eval|\$\$eval|waitForResponse|waitForRequest)" \
  bank-bot/src/

# Selector literals — IDs, data-testid, CSS classes the bot reads or
# clicks on
grep -rnE "data-testid|#[a-zA-Z][a-zA-Z0-9_-]+|\\..+-(btn|form|input|otp|dropdown|modal)" \
  bank-bot/src/
```

For each hit record:

| Expectation | Where bot expresses it | What the bot does next |
|---|---|---|
| URL path | `page.goto(...)` / HTTP client | navigate |
| Selector / field | `page.click('[data-testid=...]')` | click / fill |
| Response body key | `await page.$eval(...)` or HTTP parse | branch, assert, report to backend |
| Response status / header | `waitForResponse` predicate | retry / fail |
| Timing / delay | `waitForSelector(..., {timeout})` | give up if missing |

### 2b. For each expectation, verify mock serves it

Cross-reference the expectation list from 2a against the inventory
from 1a:

- Does the route/selector exist in the mock?
- Does the response shape match (same keys, same types, same status
  code)?
- Does the page render the selector the bot is waiting on (either as
  server-rendered HTML in `server.js` string literals, or as a file
  under `mock-bank/public/`)?
- Does the mock's timing behavior fit the bot's `waitForSelector`
  timeout budget? (`/admin/delays` is tunable — if a test configures
  a long delay the bot cannot absorb, that is WRONG-SETUP; it's also
  a hint that real-world bank latency margins are thin.)

### 2c. Scope per bank

The bot has **per-bank adapters**. A drift in SCB's flow is a drift in
SCB's surface — don't mix bank scopes in the same finding. Tag
learnings with the bank: `#scb`, `#ktb`, etc., in addition to the
mandatory 3-layer set.

## Step 3 — Inventory outbound calls from mock-bank (if any)

Mostly for completeness — these are **not** contract:

```bash
grep -nE "fetch\(|axios\.|got\(" integration-tests/mock-bank/server.js
```

Any hit is test-convenience glue (e.g., mock auto-posting a generated
OTP to a backend debug endpoint). These are:

- Not exercised by the real-world bank↔bot contract.
- Safe to remove if the user agrees — but their absence can break
  specific tests that rely on the side-effect.

Include them in the Step 5 matrix under a separate column for
visibility. Do **not** classify their disappearance as production-impact
drift; flag it as a test-infra change only.

## Step 4 — Inventory tests' fixture usage (admin surface)

```bash
grep -nE "MOCK_BANK_URL" integration-tests/test-*.sh | \
  grep -oE "/admin/[a-z/-]+" | sort -u
```

Every path in that list must exist in the 1a admin inventory. Any
path used by tests but not served → **STALE test** (hand off to
workflow 1) **and** admin-surface drift (log here, feature tag
`#fixture`).

Do not weigh admin drift as heavily as bot-surface drift; fixture
problems produce obvious test failures, while bot-surface problems
produce silent mis-passes.

## Step 5 — Diff and classify

Internal matrix (drives Step 6 and 7; not shipped raw):

| Surface | Category (bot-portal / admin / outbound-glue) | Provided by mock? | Consumed by bot? | Consumed by tests? | Status |
|---|---|---|---|---|---|

Status values:

- **MATCHED** — provided and consumed; no drift.
- **MISSING-IN-MOCK** — bot (or test) expects it, mock does not
  provide. Bot-portal = **contract drift**; admin = fixture drift;
  outbound-glue = not a drift, informational.
- **SHAPE-DRIFT** — provided and consumed, but response body keys,
  types, or status codes mismatch.
- **SELECTOR-DRIFT** — bot waits on a selector / clicks a selector
  the mock no longer renders (or has renamed). Often the most silent
  failure mode because Puppeteer timeouts look like "slow mock."
- **TIMING-DRIFT** — bot's `waitForSelector` / polling budget
  narrower than the mock's configured response delay for that
  endpoint.
- **DEAD-CODE-IN-MOCK** — served but no consumer. Low priority;
  flag for user review, don't file as drift unless user asks for
  cleanup.

## Step 6 — Regenerate `docs/mock-bank-contract.md`

Overwrite allowed — derived doc, not vault-governed.

```markdown
# Mock-Bank ↔ Bank-Bot Contract

**Baseline commit:** `<sha>`
**Validated at:** <ISO date, GMT+7>
**Checker:** tester agent
**Architecture:** backend ↔ bank-bot ↔ mock-bank. Backend never calls mock-bank directly; the only live contract is mock ↔ bot. Admin API is a fixture contract used by tests, not the bot.
**Source files cross-read:**
- integration-tests/mock-bank/server.js (<N> lines)
- integration-tests/mock-bank/public/** (<M> files, <K> selectors catalogued)
- bank-bot/src/** (adapters: <list-banks>)
- integration-tests/test-*.sh (<L> scripts, fixture usage only)

## Bot-portal surface (PRIMARY — bank-bot drives this)

One subsection per bank adapter.

### SCB

| Surface | What bot expects | Mock provides? | Notes |
|---|---|---|---|
| `GET /some/page` | HTML with `[data-testid="otp-input"]` | ✅ | — |
| `POST /submit-transfer` | JSON `{txnId, status}` | ⚠️ SHAPE-DRIFT | mock returns `{transaction_id, state}` |
| … | | | |

### KTB

| … | | | |

## Admin / fixture surface (tests → mock)

| Method | Path | Purpose | Tests that use it |
|---|---|---|---|

## Outbound test-glue (mock → backend — informational, not contract)

| Method | Backend path | Trigger | Removable? |
|---|---|---|---|

## Known drift

(one row per drift found; matches Step 7 learnings)

## Historical drift (preserved — P-001)

(rows superseded by later fixes; kept for audit)
```

## Step 7 — File `arra_learn` per drift

One learning per non-MATCHED row (excluding DEAD-CODE-IN-MOCK unless
user asked for cleanup). File via the arra_learn MCP tool.

**Do NOT include markdown frontmatter in the `pattern` body** — arra_learn
wraps its own `---\ntitle: ...\n---` around whatever you pass. Pre-wrapped
input produces the nested double-wrap bug (filename `_title-*`, outer
`title: ---`, caught by verify.sh). Metadata goes in the separate
`concepts`, `source`, and `project` parameters; the first line of `pattern`
is the headline and seeds the slug.

```
arra_learn(
  pattern="drift — mock-bank <surface> <class>

Drift class: MISSING-IN-MOCK | SHAPE-DRIFT | SELECTOR-DRIFT | TIMING-DRIFT.

Consumer: <bank-bot adapter path + line | test script path + line>.

Expectation: <what the consumer expects: URL, selector, payload shape, status, timing>.

Reality in mock: <what mock actually does or does not do at that spot>.

Root cause commit: <sha> <one-line message>. (May be in bank-bot/ OR in
mock-bank/ — either side can drift.)

Remediation (proposed; not applied): <what change to server.js — or, rarely,
to the bot adapter — would restore MATCHED status>.

Blast radius: <which tests currently rely on this and may silently mispass/fail>.

Related: <prior mock-bank drift learning ids if continuing a thread; omit line if none>.",
  concepts=["tester", "repo:mobiz-payment-gateway", "current",
            "drift", "mock-bank",
            "<bank: scb | ktb | …>",
            "<sub-class: bot-contract | fixture | doc-vs-impl>"],
  source="integration-tests/mock-bank/server.js:L<line> + bank-bot/src/<adapter>.ts:L<line>@<commit>",
  project="github.com/kokarat/mobiz-payment-gateway"
)
```

## Step 8 — PR (proposals only, no server.js edits)

Before committing, verify no broken frontmatter was introduced this session:

```bash
bash $(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/scripts/verify.sh | grep -A 3 frontmatter
# expect: ✅ no double-wrap + ✅ every indexed doc has a title:
```

Branch: `chore/tester-mock-bank-contract-<date-GMT7>`.

```bash
git checkout -b chore/tester-mock-bank-contract-$(TZ=Asia/Bangkok date +%Y-%m-%d)
git add docs/mock-bank-contract.md
git commit -m "docs(tester): refresh mock-bank ↔ bot contract — baseline <sha>

- Static cross-read of bank-bot adapters against mock-bank portal surface.
- Drift summary: MISSING=<n> SHAPE=<n> SELECTOR=<n> TIMING=<n> DEAD=<n>
- One arra_learn per non-MATCHED row (see PR body).
- integration-tests/mock-bank/server.js NOT MODIFIED.
  Remediation proposed per row; awaits human sign-off."

git push -u origin chore/tester-mock-bank-contract-$(TZ=Asia/Bangkok date +%Y-%m-%d)
gh pr create \
  --title "docs(tester): refresh mock-bank ↔ bot contract — baseline <sha>" \
  --body "$(cat <<'EOF'
## Summary

Static cross-read of `bank-bot` against `mock-bank` portal surface.
Produces `docs/mock-bank-contract.md` — the single source for what
mock-bank is supposed to serve to the bot — and flags every drift as
its own `arra_learn`.

Architecture reminder: backend ↔ bank-bot ↔ mock-bank. The only live
contract is **bot ↔ mock**. Backend never speaks to mock-bank directly.

## Drift found (per bank)

### SCB
- MISSING-IN-MOCK: <n>   <routes>
- SHAPE-DRIFT:     <n>
- SELECTOR-DRIFT:  <n>
- TIMING-DRIFT:    <n>

### KTB
- …

### Admin / fixture (secondary)
- MISSING-IN-MOCK: <n>   <paths used by tests but not served>

### Informational
- DEAD-CODE-IN-MOCK: <n>  (no action unless user asks)

## Proposed remediations

One per drift row (see `arra_learn` entries tagged
`#drift #mock-bank`). Each proposal is a surgical patch to
`server.js` (or, for SELECTOR-DRIFT, to a template in
`mock-bank/public/`) that restores MATCHED status. **Not applied in
this PR.**

## Next step (separate PR)

After human sign-off on a remediation, tester opens
`chore/tester-mock-bank-fix-<slug>` with the single edit and links
the `arra_learn` that motivated it.

EOF
)"
```

## Step 9 — (Optional, separate PR) Apply a remediation

Only after user approves a specific proposal in the PR from Step 8:

1. New branch: `chore/tester-mock-bank-fix-<slug>`.
2. Edit `integration-tests/mock-bank/server.js` (or a file under
   `mock-bank/public/` for SELECTOR-DRIFT) — **one** remediation at a
   time. Keep diffs small.
3. `node --check integration-tests/mock-bank/server.js` as a syntax
   parse (bash `-n` does not work on Node).
4. Update `docs/mock-bank-contract.md`: move the row from "Known
   drift" to "Historical drift" with the fix commit SHA.
5. Mark the originating `arra_learn` as resolved via a follow-up
   learning tagged `#resolution` that references it in `related:` —
   or call `arra_supersede(oldId, newId)`. Never delete.
6. PR, push, wait for human merge.

## Common pitfalls this workflow has hit before

*(populated over time)*

- **Thinking backend talks to mock-bank.** It does not. If an earlier
  version of this workflow (or a retrospective) says otherwise, it is
  the architecture that has been clarified — the workflow is
  authoritative. The `bank-bot` is the sole production-shaped
  consumer.
- **Weighing outbound test-glue as contract.** Mock-bank's `fetch`s
  to the backend are test conveniences. Their drift is test-infra
  noise, not a production-impact drift. Report but do not prioritize.
- **Cross-bank confusion.** SCB and KTB adapters drive different mock
  flows. A drift in SCB login has nothing to say about KTB login.
  Keep the learnings separately scoped with `#scb` / `#ktb`.
- **Mistaking a feature flag for drift.** Mock-bank sometimes guards
  endpoints behind `MOCK_BANK_MODE` or similar. Read the conditional
  before filing.
- **SELECTOR-DRIFT looks like latency.** If the bot's
  `waitForSelector` times out and the mock's response time is fine,
  the first suspect is a renamed/removed selector — not a timing bug.
- **`arra_learn(pattern=...)` expects prose, not a pre-wrapped markdown
  doc.** arra_learn wraps its own `---\ntitle: ...\n---` around whatever
  you pass as `pattern`. Passing a document that already contains a
  frontmatter block (e.g. an earlier arra_learn output, or hand-authored
  markdown starting with `---\ntitle: ...`) produces the nested
  **double-wrap** bug: filename begins `_title-*`, outer `title: ---`,
  two frontmatter blocks, `verify.sh` flags it. A tool-side strip-and-warn
  guard landed 2026-04-19 (Soul-Brews-Studio/arra-oracle-v3
  `stripFrontmatterWrap`), and the Step 7 template above was rewritten
  the same day to use the `arra_learn(pattern=..., concepts=..., ...)`
  function-call form. Keep `pattern` as 1–2 paragraphs of plain prose
  and rely on the guard only as a safety net.

## Memory/search/trace anomalies — escalate to brew-ops (non-blocking)

**Fire-and-forget.** Filing a handoff does NOT block this workflow or wait on brew-ops. Finish your pass normally — brew-ops picks up asynchronously on its next session. No `[AWAITING_...]` anchor, no Step 0 sweep. The handoff file itself is the durable record.

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
**Revised:** 2026-04-16 (GMT+7) — architecture corrected: removed the
false "backend ↔ mock-bank" premise; the only live contract is
mock-bank ↔ bank-bot. Human correction; logged in vault.
**Revised:** 2026-04-19 (GMT+7) — Step 7 `arra_learn` template
rewritten from YAML-frontmatter-blob form to `arra_learn(pattern=...,
concepts=..., source=..., project=...)` function-call form (sibling-
synced with workflow-1 Step 5 and workflow-2 Step 8 the same day).
The earlier template was isomorphic to the arra_learn "double-wrap"
corruption signature recovered from technical-writer territory on
2026-04-19. Common pitfall bullet added.
