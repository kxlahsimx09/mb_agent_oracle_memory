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
2. `[UNVERIFIED]` markers acceptable **only** if < 5% of total claims. Above that → halt, ask the human.
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

For every durable fact discovered that is not already in the vault, write an `arra_learn` with the 3-layer tag set from `.agent/AGENTS.md` §7a:

```yaml
tags:
  - technical-writer                   # role
  - repo:bank-bot                      # repo scope
  - current                            # system phase
  - <bank: scb|ktb|kbank|bbl>          # feature (when bank-specific)
  - <topic: selector|otp|login|…>      # feature (recommended)
  - <special: drift|decision|handoff>  # only if applicable
```

Typical baseline learnings for bank-bot:

- A selector that uses Thai text vs `data-testid` (the bank portal doesn't offer a stable testId).
- A quirk of session reuse (e.g., SCB invalidates storage after 2 approver failures — that's a real behavior captured in `95dbb70`).
- An OTP path that isn't obvious (e.g., mock-bank posts OTP to backend; bot polls backend via `otp_api.js`).
- Anti-detection timings that matter (humanDelay ranges).
- Each `[DRIFT]` inline marker gets a matching `#drift` learning with a trace.

Aim for **5–12 learnings** on a first baseline.

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
- [ ] Retrospective under `~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/…`, AI Diary + Honest Feedback present.
- [ ] `arra_handoff` entry with PR pointer and next unanswered question.

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

- **> 5% `[UNVERIFIED]`** → halt, ping user.
- **Credential or OTP handling path not matching the docs** → halt, CC `security_auditor` (when role exists on bot side) before publishing; treat as security-sensitive drift. Do not narrate the exact gap in public `docs/*`.
- **Anti-detection logic that differs from docs** → similar — this is how banks notice bots; surface carefully, not in public readme.

---

## Change log for this workflow file

- 2026-04-16 — Initial version, adapted from mobiz's `workflow-1-baseline-current.md`. Shape identical; inputs and template rewritten for Node.js + Playwright stack. First live run will refine the template.
