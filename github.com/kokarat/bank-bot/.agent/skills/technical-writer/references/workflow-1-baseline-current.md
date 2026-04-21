# Workflow 1 — Baseline the Current System (bank-bot)

> Reference document for the `technical_writer` agent (`bot-writer-oracle`).
> Read this file before running the workflow. Do not skim.

This is the bank-bot-flavored counterpart of mobiz's `workflow-1-baseline-current.md`. The **discipline** is the same (verify every claim against code at a pinned commit, cite `// verified: path@hash`, append-only corrections, no silent rewrites). The **shape** of the inputs and the template differs because bank-bot is Node.js + Playwright + IMAP, not Go + Fiber + MongoDB.

This workflow produces (or refreshes) `docs/current-system.md` in `bank-bot/docs/` and `bank-bot/docs/.baseline`. Subsequent workflows (`workflow-2-track-commit`, `workflow-4-reconcile-drift`) consume both.

---

## When to run this workflow

Run when **any** of the following is true:

- `docs/.baseline` does not exist (first time — this is that run).
- `docs/.baseline` exists but `last-verified-at` is more than **14 days** old.
- A refactor landed touching `app.js`, `banks/<bank>/*.js`, or `core/*.js` that changed the bot's runtime shape.
- A new bank adapter appeared (e.g., `banks/kbank/` or `banks/bbl/` — two are planned per `CLAUDE.md`).
- A human explicitly asks for a "fresh baseline" or "full read."

Do **not** run this workflow for a single selector update or copy tweak — use **Workflow 2** for that. Baseline is the slow, grounding pass; Workflow 2 is the fast follow-up.

---

## Preconditions

- [ ] Repo tree is clean (`git status --porcelain` is empty). If not, stash or abort.
- [ ] `main` is up-to-date (`git fetch origin && git status -sb` shows no `behind`).
- [ ] Oracle is reachable (`curl -sf http://localhost:47778/api/stats` returns 200). If not, `arra_search` grounding is skipped — note in retro.
- [ ] You have at least **60 minutes** of focused time. Bank-bot is smaller than mobiz but denser (bank-specific selector/flow nuance takes time per bank).

---

## Inputs you will read

In approximate order:

1. Git state — `git log -1 --format='%H %ci %s'`.
2. Charter — `.agent/AGENTS.md` (re-read each session).
3. Skill — `.agent/skills/technical-writer/SKILL.md`.
4. Prior art — any existing `docs/current-system.md`, `docs/.baseline`. (Note: the legacy `ψ/` directory at repo root is **not** prior art for this workflow; per AGENTS.md §2 it is not the canonical vault.)
5. Root docs — `CLAUDE.md`, `README.md` (both are substantial — treat as **claims to verify**, not facts).
6. The Node.js source tree, selectively:
   - `app.js` — entrypoint, SSE listener, poll fallback, bank-module dispatch.
   - `banks/index.js` + `banks/base.js` — registry and interface.
   - `banks/<bank>/` — per-bank adapters. Each has roughly: `selectors.js`, `login.js`, `maker.js` / `transfer.js`, `approver.js` / `checker.js`, `statement.js`, `dashboard.js`, `index.js` (module entry).
   - `core/` — shared infrastructure: `api.js` (backend HTTP), `browser.js` (Playwright launch/context), `sse.js` (SSE client), `otp_email.js` (IMAP polling), `otp_api.js` (backend OTP polling), `logger.js`, `util.js`, `cursor.js`, `thai-roman.js`.
7. Bot flow narratives — `workflow/*.md` (hand-authored per-bank flow notes, e.g., `workflow/scb-transfer.md`).
8. Deployment surface — `Dockerfile`, `Dockerfile.bun`, `docker-compose.yml`, `run-full-flow.sh`, `scripts/`.
9. Environment contract — `.env.example`.
10. Tests — `tests/*.test.js` as a secondary source of "what behavior is considered testable." Do not treat as spec.

---

## Outputs you will produce

Required:

- `docs/current-system.md` — the primary artifact. Follow the template in §Template.
- `docs/.baseline` — two lines, exact format:

  ```
  current-system-baseline: <40-char commit hash>
  last-verified-at:        <ISO 8601 date in GMT+7>
  ```

Optional (only if the main doc grows past thresholds):

- `docs/bank-scb.md` — if the SCB section in `current-system.md` exceeds ~200 lines.
- `docs/bank-ktb.md` — if the KTB section exceeds ~200 lines.
- `docs/deployment.md` — if deployment section exceeds ~150 lines.
- One or more `arra_learn` entries (see §Memory).

Never produced in this workflow:

- ADRs (that is Workflow 5 — not yet defined for bot-writer).
- Runbooks (future Workflow 6).
- Target-system docs (Workflow 3 — activates when the `bank-bot-next` target repo exists).

---

## Steps

### Step 0 — Resolve answered threads in territory (blocking, 3–10 min)

Before any new work, run `references/workflow-thread-resolve.md` (Pass 1 + Pass 2) to completion.

- **Pass 1 (primary)**: `grep -rEn '\[(AWAITING_THREAD|RATIFICATION_PENDING):([A-Za-z0-9_-]+)\]' docs/current-system.md workflow README.md CLAUDE.md`. For every id found: `arra_thread_read(<id>)`. On `status="answered"` run the 4-step resolution block (read → classify → update doc + strip/transform marker → `arra_thread_update(status="closed")` + chain child trace).
- **Pass 2 (safety-net)**: `arra_threads(status="answered", limit=50)`. Any returned id not seen in Pass 1 + clearly in bot-writer territory = earlier pass leaked an anchor → file `#workflow-bug + #thread-orphan`.

**Gate:** Step 1 does not start until Pass 1 = zero remaining answered markers and Pass 2 = zero unfiled orphans. "Forgot to check" is not a legal outcome.

### Step 1 — Grounding (5 min)

```
arra_search query="bank-bot technical-writer baseline" type=all limit=10
arra_search query="scb ktb playwright selector" type=learning limit=10
```

Note any prior baseline learning, open `#drift`, or relevant `#gotcha`. If Oracle is unreachable, record `[GROUNDING SKIPPED — Oracle unreachable at <timestamp>]` and continue.

### Step 2 — Pin the commit (2 min)

```
git log -1 --format='%H %ci %s'
```

Record the full 40-char hash. If the commit moves mid-workflow (someone pushed to main while you're reading), **stop and restart**.

### Step 2b — Open the baseline's root trace (1 min)

A baseline is one big multi-hour investigation. Open an anchor trace now so every per-finding child trace (Step 9) can point back to it via `parentTraceId`. Future agents running `arra_trace_chain(<root>)` see the whole session as a tree.

```
arra_trace(
  query="baseline — bank-bot at <short-hash>",
  queryType="project",
  scope="project",
  project="github.com/kokarat/bank-bot",
  foundCommits=[{ hash: "<40-char>", shortHash: "<7-char>", date: "<ISO>", message: "<subject>" }]
)
# store returned trace_id as ROOT_TRACE for the rest of the session
```

If a prior baseline trace exists for this repo (`arra_trace_list project="github.com/kokarat/bank-bot" queryType="project" limit=5`), chain horizontally:

```
arra_trace_link(prevTraceId="<prior baseline root trace_id>", nextTraceId=ROOT_TRACE)
```

No prior baseline → first run; skip the link (ROOT_TRACE becomes chain head).

### Step 3 — Structure read (10 min)

Read in this order — do not skip ahead:

1. `README.md` — high-level framing. Orientation only; do not trust any specific claim yet.
2. `CLAUDE.md` — tech stack, per-bank architecture, deployment model. Every line is a **claim to verify**.
3. `app.js` — the real entrypoint. Note the SSE listener wiring, poll fallback, how a queued job is routed to a bank module, error/retry handling at this top-level.
4. Directory tree: `find . -type d -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/data*/*' | sort`.

At the end of Step 3 you should be able to answer: **what is the top-level runtime loop of this bot?** and **what banks are live today?** (As of `95dbb70`: SCB + KTB implemented; KBANK + BBL documented as planned but not yet coded.)

### Step 4 — Runtime loop + core read (15 min)

Read `app.js` end-to-end, then each file in `core/`:

- `core/api.js` — HTTP client to backend. Record: which backend routes the bot calls, which auth header it carries (`BOT_SECRET`?), timeouts, retry policy.
- `core/browser.js` — Playwright launch: headless toggle, storage/context directory, user-agent, any anti-detection quirks.
- `core/sse.js` — SSE client: what event types it listens for, reconnect policy.
- `core/otp_email.js` — IMAP polling: mailbox, poll interval, pattern matching for OTP bodies.
- `core/otp_api.js` — backend-based OTP polling (alternative to email).
- `core/logger.js` — log shape (JSON structure, destinations).
- `core/util.js`, `core/cursor.js`, `core/thai-roman.js` — note helper semantics (humanDelay, humanType, Thai→English transliteration) because bank portals often accept only English names.

Record each as a subsection in the `current-system.md` §4 "Core infrastructure" section (see §Template).

**Discipline:** any behavior `CLAUDE.md` does not describe is `[DRIFT: CLAUDE.md omits <thing>, see <file>:NNN]` — do NOT silently rewrite `CLAUDE.md`. Drift is reconciled in Workflow 4.

### Step 5 — Per-bank adapter read (20–25 min — scale by bank count)

For each subdir in `banks/` (currently `scb/`, `ktb/`):

1. `selectors.js` — record testIds, URL patterns, Thai text constants. This is the file that drifts most often when banks update their portals; cite every selector.
2. `login.js` — session reuse pattern, credential fields (username/password/company code), popup handling, post-login verification.
3. `maker.js` / `transfer.js` — transfer/batch creation flow. Note batch size limits, retry logic, idempotency handling.
4. `approver.js` — OTP approval flow. Cite the OTP source (email vs API).
5. `checker.js` (if present) — post-transfer verification.
6. `statement.js` — intraday transaction scraping. Record format/schema returned.
7. `dashboard.js` — balance scraping. Note available-vs-account distinction.
8. `index.js` — module entry point, what it exports, how `banks/index.js` registers it.

Write each adapter's read into §3 "Per-bank adapters" as its own subsection. If a bank's section grows past ~200 lines of doc, spin it out to `docs/bank-<name>.md` and leave a one-paragraph summary + link in the main doc.

### Step 6 — Workflow narratives + deployment (10 min)

- Read every file in `workflow/` (typically one per bank flow, e.g., `scb-transfer.md`). These are hand-written behavior narratives. Cross-check against the code you just read in Step 5.
- Read `Dockerfile`, `Dockerfile.bun`, `docker-compose.yml`, `run-full-flow.sh`, `scripts/*.sh`.
- Read `.env.example` — record the env surface (which vars the bot needs at runtime, which are bank-specific, which come from backend config).
- Capture the "1 droplet = 1 bank account = 1 bot" deployment discipline explicitly.

### Step 7 — Write `docs/current-system.md` (40–50 min)

Use the template in §Template below. Strict rules:

1. Every non-trivial claim ends with `// verified: <path>@<short-hash>` (7-char short hash).
2. `[UNVERIFIED]` markers → also open an `arra_thread(title, message)` and replace with `[AWAITING_THREAD:<id>]`. Above **5% of total claims** carrying threads → bulk-file the remaining threads, close the baseline with an open-threads summary in §9/§10 and in the PR body. **Do not hard-halt the session** — threads discover answers async. Security-sensitive ambiguity (credential/OTP/anti-detection) **still halts** — see Escalation.
3. No forward-looking language. This documents the **current** system at the pinned commit. Planned features (KBANK, BBL) are listed with `*(planned per CLAUDE.md; no code yet)*` next to their bank name.
4. No marketing prose.
5. Thai strings from code (bank popup text, statement descriptions) are preserved verbatim inside backticks or quotation marks. Prose remains English.

### Step 8 — Write `docs/.baseline` (1 min)

Overwrite:

```
current-system-baseline: <40-char commit hash>
last-verified-at:        <ISO 8601 date in GMT+7>
```

### Step 9 — Log learnings (10 min)

For every durable fact discovered that is not already in the vault, write an `arra_learn`. Two **binding** rules — violating either produces broken titles in Studio:

### Rule 1 — `arra_learn(pattern=…)` takes raw markdown, **not** a pre-wrapped document

```
✅ GOOD (passes plain text as pattern):
  arra_learn(
    pattern="drift — KTB transfer flow is fully implemented.\n\nEvidence at 95dbb70:\n- banks/ktb/transfer.js ...",
    concepts=["technical-writer", "repo:bank-bot", "current", "ktb", "transfer", "drift"],
    project="github.com/kokarat/bank-bot",
    source="docs/current-system.md §8 DRIFT-11 @ 95dbb70"
  )

❌ BAD (embeds its own frontmatter — tool double-wraps, title becomes literal "---"):
  arra_learn(
    pattern="---\nname: drift — KTB transfer flow ...\ndescription: CLAUDE.md claims ...\ntype: learning\n---\n\n## Evidence at 95dbb70\n- banks/ktb/...",
    ...
  )
```

The tool auto-generates the `title:` (from the first line of pattern) + `tags:` + `created:` + `source:` + `project:` frontmatter. Passing your own `---\n...\n---` block makes the outer title literally `"---"` and buries your real title in the body.

If you prefer direct file write (AGENTS.md §7 option 2), use the template in Rule 2.

### Rule 2 — direct file-write frontmatter template (when you skip the MCP tool)

```yaml
---
title: <one-line human-readable title — this is what Studio displays>
tags: [technical-writer, repo:bank-bot, current, <bank>, <topic>, <special>]
created: <YYYY-MM-DD>
source: <file:line@commit or "Oracle Learn" or conversation source>
project: github.com/kokarat/bank-bot
---

# <same as title>

<body paragraphs>
```

**Always use `title:` — never `name:` + `description:`.** Studio's document-list UI indexes the `title:` field; `name:` is reserved for `SKILL.md` skill identity (different semantic). Retros and learnings with `name:` but no `title:` render as blank rows in Studio until manually fixed.

### Tag layers (mandatory 3-layer)

- role — `technical-writer`
- repo scope — `repo:bank-bot`
- system phase — `current`
- feature tags (recommended) — `<bank: scb|ktb|kbank|bbl>`, `<topic: selector|otp|login|...>`
- special tags (only if applicable) — `drift`, `decision`, `handoff`

Typical baseline learnings for bank-bot:

- A selector that uses Thai text vs `data-testid` (the bank portal doesn't offer a stable testId).
- A quirk of session reuse (e.g., SCB invalidates storage after 2 approver failures — that's a real behavior captured in `95dbb70`).
- An OTP path that isn't obvious (e.g., mock-bank posts OTP to backend; bot polls backend via `otp_api.js`).
- Anti-detection timings that matter (humanDelay ranges).
- Each `[DRIFT]` inline marker gets a matching `#drift` learning with a trace.

Aim for **5–12 learnings** on a first baseline.

**Also: per-finding child traces.** For every `[DRIFT]` marker and every `[UNVERIFIED]` / `[AWAITING_THREAD:<id>]` you added, create a child trace under the session's `ROOT_TRACE` from Step 2b:

```
arra_trace(
  query="<short drift/unverified summary>",
  queryType="pattern",                    # recurring structural smell; use "general" for one-offs
  scope="project",
  project="github.com/kokarat/bank-bot",
  parentTraceId=ROOT_TRACE,               # anchor to the baseline's root
  foundFiles=[
    { path: "<doc path:line>", type: "other", matchReason: "<why this is drift>", confidence: "high" },
    { path: "<code path:line>@<short>", type: "other", matchReason: "<what code actually does>", confidence: "high" }
  ],
  foundCommits=[{ hash, shortHash, date, message }],    # if known
  foundLearnings=["<companion #drift learning source_file>"]
)
```

Children are **vertical** (parent → child) — they represent sub-investigations within the baseline pass. No `arra_trace_link` between siblings.

### Step 10 — Commit + PR (5 min)

Branch: `docs/baseline-current-<short-hash>` (e.g. `docs/baseline-current-95dbb70`).

```
docs: baseline current bot system at <short-hash>

Covers Node.js + Playwright + IMAP + SSE as of <full-hash>.
Banks documented: SCB, KTB. KBANK + BBL listed as planned (no code).

- Added docs/current-system.md (<N> sections, <M> claims, <K> drift markers)
- Updated docs/.baseline
- Logged <X> arra_learn entries (see oracle)

No bot code behavior changes.

Closes #<issue if one exists>
```

PR body: links to `#drift` learnings, list of `[UNVERIFIED]` claims, and the line `**I will not merge this PR. Awaiting human review.**`

Per `AGENTS.md` §9, **never** `gh pr merge`.

### Step 11 — Retrospective (5 min)

Run `rrr` per `AGENTS.md` §7. AI Diary + Honest Feedback are mandatory. Write retro file to `~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_bot-baseline-<short>.md` (central vault path — NOT `bank-bot/ψ/`; see SKILL § "Vault path (the #1 trap)").

**Paste the session's trace tree** into the retro as a "Session map" section:

```
arra_trace_get(ROOT_TRACE, includeChain=true)
# paste the returned chain/children list into retro under ## Session map
```

If this baseline chained from a prior baseline (Step 2b), also paste the horizontal chain:

```
arra_trace_chain(ROOT_TRACE)
# shows baseline-over-time history
```

---

## Template for `docs/current-system.md`

```markdown
# Current System — bank-bot

**Baseline commit:** `<40-char hash>`
**Baselined at:** `<ISO date GMT+7>`
**Baselined by:** `technical_writer` agent (bot-writer-oracle instance)
**Scope:** The running Node.js + Playwright bot that drives bank portals on behalf of the mobiz-payment-gateway backend. Not the target bot (when `bank-bot-next` exists, see that repo's `docs/current-system.md`).

> Produced by `.agent/skills/technical-writer/references/workflow-1-baseline-current.md`. Every non-trivial claim cites the baseline commit. `[UNVERIFIED]` = known gap. `[DRIFT]` = code/doc mismatch with an open `arra_learn` tagged `#drift`.

## 1. Stack

- Runtime: Node.js (≥ 18, per package.json); Bun alternative for start:bun  // verified: package.json@<short>
- Browser automation: Playwright  // verified: package.json@<short>
- Backend contract: REST to mobiz `/api/v1/bot/**`  // verified: core/api.js@<short>
- OTP sources: IMAP (email) and backend API  // verified: core/otp_email.js, core/otp_api.js@<short>
- Event intake: SSE + poll fallback  // verified: app.js@<short>, core/sse.js@<short>
- Deployment: 1 droplet = 1 bank account = 1 bot instance  // verified: CLAUDE.md "Overview" section

## 2. Runtime loop (top-level)

(App dispatch: SSE event → bank module → maker/approver/checker/statement → report back. Cite `app.js:NNN`.)

## 3. Per-bank adapters

### 3.1 SCB — Business Anywhere

- `banks/scb/selectors.js` — testIds + Thai constants  // verified: ...
- `banks/scb/login.js` — session reuse + dismissPopups()  // verified: ...
- `banks/scb/maker.js` — batch creation  // verified: ...
- `banks/scb/approver.js` — OTP approval  // verified: ...
- `banks/scb/checker.js` — statement verification  // verified: ...
- `banks/scb/statement.js` — intraday scraping  // verified: ...
- `banks/scb/dashboard.js` — balance scraping  // verified: ...

### 3.2 KTB — Business (Krungthai Corporate)

- `banks/ktb/selectors.js` — URLs + Thai popup keywords + bank code map  // verified: ...
- `banks/ktb/login.js` — company_code+user+pass + OTP + dismissPopups()  // verified: ...
- `banks/ktb/transfer.js` — single-transfer flow  // verified: ...
- `banks/ktb/dashboard.js` — balance scraping  // verified: ...

### 3.3 KBANK *(planned per CLAUDE.md; no code yet at this baseline)*
### 3.4 BBL *(planned per CLAUDE.md; no code yet at this baseline)*

## 4. Core infrastructure

(Sub-subsections for api, browser, sse, otp_email, otp_api, logger, util, cursor, thai-roman.)

## 5. Deployment surface

(Dockerfiles, docker-compose, run-full-flow.sh, scripts/, env contract.)

## 6. External integrations

(Backend API, IMAP mailbox, bank portals.)

## 7. Security surface

(BOT_SECRET, credential flow — credentials fetched from backend never stored locally, anti-detection delays.)

## 8. Known drift

Table of `[DRIFT]` markers with links to learnings.

## 9. Known unknowns

Table of `[UNVERIFIED]` markers with reason.

## 10. Next baseline triggers

(Copy from this workflow §"When to run".)
```

---

## Definition of Done

- [ ] `docs/current-system.md` exists and follows the template.
- [ ] Every non-trivial claim carries `// verified: <path>@<hash>`.
- [ ] `[UNVERIFIED]` markers < 5% of total claims.
- [ ] Every `[DRIFT]` marker has a matching `arra_learn` tagged `#drift` + `#repo:bank-bot` + `#current` + `#technical-writer`.
- [ ] `docs/.baseline` exists with the exact two-line format.
- [ ] Git branch pushed; PR opened; **not merged**.
- [ ] Retrospective under `~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/…`, AI Diary + Honest Feedback present. The retro is the state carrier for the next session; no separate handoff step.
- [ ] Every unanswered question has an `arra_thread` open with a paired `[AWAITING_THREAD:<id>]` anchor in the doc (see §Escalation). PR body lists open thread ids — it does not carry the questions themselves.
- [ ] Vault audit clean: `bash $(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/scripts/verify.sh | grep -A 3 frontmatter` shows `✅ no double-wrap` + `✅ every indexed doc has a title:`.
- [ ] Root trace (Step 2b) opened with `queryType=project` + baseline commit in `foundCommits`. If a prior baseline trace exists, `arra_trace_link(prev, root)` was called to chain baseline-over-time history.
- [ ] Every `[DRIFT]` and `[UNVERIFIED]` / `[AWAITING_THREAD]` has a child trace with `parentTraceId=ROOT_TRACE` (Step 9). Retro §"Session map" has `arra_trace_get(ROOT_TRACE, includeChain=true)` pasted.
- [ ] Step 0 ran to completion: Pass 1 (doc-anchored grep) left zero `answered`-status markers in bot-writer territory; Pass 2 (orphan scan) returned zero bot-writer-territory threads not seen in Pass 1.
- [ ] **Anchor discipline**: every `arra_thread(...)` call made during this pass inserted a paired `[AWAITING_THREAD:<id>]` marker into a doc that is part of the same PR. Orphan count = 0.

---

## Common pitfalls (carried forward from mobiz's workflow-1 and adapted for bot)

- **Transcribing instead of summarizing.** Bank-bot has dense selector literals — do not paste them; cite and summarize.
- **Trusting `CLAUDE.md` over code.** `CLAUDE.md` here is 20 KB and unusually detailed; still P-004 applies. If it says SCB uses `data-testid=foo` and the code uses `data-testid=bar`, the code wins and that's a `#drift`.
- **Baselining during a rebase.** If `git status` is dirty, restart on a clean commit.
- **Skipping the per-bank read per bank.** Each bank has its own selector fragility profile. A "read one, skim the other" baseline misses half the surface.
- **Ignoring `workflow/*.md` narratives.** They are hand-written and sometimes say things the code doesn't. A mismatch between narrative and code = `#drift` (in favor of code).
- **Documenting the legacy `ψ/`** — the repo-local `ψ/` is not the canonical vault (AGENTS.md §2). Do not treat its contents as the bot's history.

---

## Escalation

- **> 5% `[UNVERIFIED]`** → **bulk-file one `arra_thread` per unverified claim** instead of hard-halt. Close the baseline with the open-threads summary. Next session's wake-up reconciles answered threads.
- **Credential or OTP handling path not matching the docs** → **halt AND open a thread AND CC `security_auditor`** (when role exists on bot side) before publishing. Thread is internal context only — do not narrate the exact gap in public `docs/*` until `security_auditor` has acknowledged. This class of ambiguity cannot ship on thread-alone because exposing a credential path is destructive.
- **Anti-detection logic that differs from docs** → similar — this is how banks notice bots; surface carefully, not in public readme.

### Memory/search/trace anomalies — escalate to brew-ops (non-blocking)

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

## Change log for this workflow file

- 2026-04-16 — Initial version, adapted from mobiz's `workflow-1-baseline-current.md`. Shape identical; inputs and template rewritten for Node.js + Playwright stack. First live run will refine the template.
- 2026-04-17 — Added Step 2b (open baseline's ROOT_TRACE with `queryType=project`) and extended Step 9 (Log learnings) with per-finding child traces anchored to ROOT_TRACE via `parentTraceId`. Step 11 retro now pastes `arra_trace_get(ROOT_TRACE, includeChain=true)` as a "Session map". DoD: root trace + per-drift child traces + horizontal chain linking to prior baselines.
- 2026-04-17 (later) — Added **Step 0 (Resolve answered threads in territory)** as a blocking gate before Step 1. Motivation: observed zombie threads — agent opened a thread in a prior W8/W1 pass, human answered, next session ignored the answer. Fix: doc-anchored grep (Pass 1) + orphan scan (Pass 2). Scoping is `[AWAITING_THREAD]`/`[RATIFICATION_PENDING]` markers in bot-writer territory, not title prefix. DoD added two items: Step 0 must clear to zero, and every `arra_thread(...)` call in the pass must insert a paired doc marker in the same PR (anchor discipline). See `workflow-thread-resolve.md`.
