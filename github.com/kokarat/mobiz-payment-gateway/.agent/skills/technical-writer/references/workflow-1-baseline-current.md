# Workflow 1 — Baseline the Current System

> Reference document for the `technical_writer` agent.
> Read this file before running the workflow. Do not skim.

This workflow produces (or refreshes) `docs/current-system.md` — the single authoritative page describing what the running Go + Fiber + MongoDB + Node.js bank-bot system actually does at a specific commit. It also creates or bumps `docs/.baseline` so subsequent workflows (`workflow-2-track-commit`, `workflow-4-reconcile-drift`) know which commit the docs were last verified against.

---

## When to run this workflow

Run when **any** of the following is true:

- `docs/.baseline` does not exist (first time).
- `docs/.baseline` exists but `last-verified-at` is more than **14 days** old.
- A refactor has landed (`refactor:` commit) that touches controllers, models, schedulers, or bank-bot.
- A new top-level feature area appeared since last baseline (e.g. new collection, new scheduler, new bot adapter).
- A human explicitly asks for a "fresh baseline" or "full read."

Do **not** run this workflow for a single incremental change — use **Workflow 2** (`workflow-2-track-commit.md`) for that. Baseline is the big, slow, grounding pass; Workflow 2 is the fast follow-up.

---

## Preconditions

Before the first step:

- [ ] The current repo is clean (`git status --porcelain` is empty). If not, stash or abort — baseline must reflect a clean commit.
- [ ] `main` branch is up to date (`git fetch origin && git status -sb` shows no `behind`).
- [ ] Oracle is reachable (`curl -sf http://localhost:47778/api/stats` returns 200). If not, baseline can still proceed but skip the `arra_search` grounding in Step 1 and note that in the retrospective.
- [ ] You have at least **90 minutes** of focused time. Baseline cannot be rushed; a half-baseline is worse than no baseline.

---

## Inputs you will read

In approximate order:

1. Git state — `git log -1 --format='%H %ci %s'`, `git diff --stat main..HEAD` (should be empty on main).
2. Charter — `.agent/AGENTS.md` (re-read each session).
3. Skill — `.agent/skills/technical-writer/SKILL.md` (re-read each session).
4. Prior art — any existing `docs/current-system.md`, `docs/.baseline`.
5. Repo root docs — `CLAUDE.md`, `RBAC_GUIDE.md`, `README.md`.
6. The Go source tree, selectively:
   - `main.go` (entrypoint, route registration).
   - `controllers/*.go` (26 files as of 2026-04-14 baseline `1e48da1`).
   - `models/*.go` (data structures, enums).
   - `routes/*.go` (URL surface).
   - `middlewares/*.go` (auth, rate limit, IP allowlist).
   - `scheduler/*.go` (6 schedulers).
   - `services/*.go` (bank rotation, callback, withdrawal queue).
   - `helpers/*.go` (JWT, permissions, cache, security, signature, promptpay, ratelimit, storage).
   - `db/mongo.go`, `db/redis.go` (connection setup).
7. The Node.js bank-bot — `bank-bot/` (Playwright adapters, OTP, statement scrapers).
8. Swagger — `swagger_simple.json` for endpoint cross-check.
9. Environment contract — `.env.example` (or `.env` if no example).

---

## Outputs you will produce

Required:

- `docs/current-system.md` — the primary artifact. Follow the template in §Template below.
- `docs/.baseline` — two lines, exact format:

  ```
  current-system-baseline: <40-char commit hash>
  last-verified-at:        <ISO 8601 date in GMT+7>
  ```

Optional (only if you discover them during the read):

- `docs/data-model.md` — one section per MongoDB collection, if the data model section of `current-system.md` grows past ~300 lines.
- `docs/bank-bot.md` — if the bank-bot section grows past ~200 lines.
- `docs/schedulers.md` — if scheduler coverage grows past ~200 lines.
- One or more `arra_learn` entries (see §Memory below).

Never produced in this workflow:

- ADRs (that is Workflow 5).
- Runbooks (that is Workflow 6).
- Target-system docs (that is Workflow 3).

---

## Steps

### Step 1 — Grounding (5 min)

```
arra_search query="mobiz-payment-gateway technical-writer baseline" type=all limit=10
arra_search query="bank-bot scheduler current-system" type=all limit=10
arra_reflect
```

Read whatever comes back. Goals:

- Find any prior baseline learning from a previous session.
- Find any `#drift` learning that is still open.
- Find any relevant ADR or decision trace.

If the Oracle is unreachable, note it (`[GROUNDING SKIPPED — Oracle unreachable at <timestamp>]`) and continue. Do not block.

### Step 2 — Pin the commit (2 min)

```
git log -1 --format='%H %ci %s'
```

Record the full 40-char hash. Every claim in the output document will be cited against this hash. If you realize mid-workflow that the commit has moved (e.g., someone pushed to main during your read), **stop and restart** — you cannot produce a coherent baseline against a moving target.

### Step 3 — Structure read (15 min)

Read in this order — do not skip ahead:

1. `README.md` — high-level framing. Do not trust any specific claim yet; this is orientation only.
2. `CLAUDE.md` — the tech-stack claims, endpoint lists, status-code conventions. Treat every line as a **claim to verify**, not a fact.
3. `main.go` — the real entrypoint. Note which routes are registered, which middlewares are applied, which schedulers are started, what order things initialize in.
4. Directory tree output: `find . -type d -not -path '*/node_modules/*' -not -path '*/.git/*' | sort | head -60`. This is the map; every subsequent read is a walk on this map.

At the end of Step 3 you should be able to answer: **what are the top-level nouns of this system?** (Expected answer, as of `1e48da1`: User, Merchant, Client, Partner, Role, MDRProfile, SubClient, SystemBank, Wallet, Topup, Transaction, Deposit, Payout, Settlement, PullOutTask, WithdrawalQueueItem, LoginLog, BankStatement, OTPLog.)

### Step 4 — Surface read: routes + controllers (30 min)

For each file in `routes/`:

1. Read the route file.
2. Open the matching controller in `controllers/`.
3. For each endpoint, record:
   - Method + path (e.g. `POST /api/v1/deposits`).
   - Auth middleware (JWT? API key? Bot secret? Public?).
   - Key request fields (do not transcribe — reference the model).
   - Key response fields.
   - Side effects (DB writes, Redis ops, SSE publishes, callback sends).
   - The file:line you verified against.

Use the `current-system.md` "API Surface" section template (§Template) as the structure for this recording. Do not write a separate scratch file — write directly into the template.

**Discipline**: if a controller function does something `CLAUDE.md` does not describe, that is a `#drift` — mark it `[DRIFT: CLAUDE.md does not mention <thing>, see controllers/Foo.go:NNN]` and keep going. Do **not** silently rewrite `CLAUDE.md`. Drift is reconciled in Workflow 4, not here.

### Step 5 — Data model read (20 min)

For each file in `models/`:

1. List fields + types + bson tags.
2. Note enums (the status codes — 0/1/2 convention is entity-wide, 0/1/2/3 is for operations).
3. Note indexes (if declared in the model or in `db/mongo.go`).
4. Note invariants implied by the code (e.g. "Wallet balance is never negative — see `WalletController.go:NNN` guard").

Write this into `current-system.md` "Data Model" section. If it exceeds ~300 lines, split out `docs/data-model.md` and leave a one-paragraph summary + link in `current-system.md`.

### Step 6 — Peripheral read (25 min)

Read these in any order:

- `scheduler/` — all 6 schedulers. Record cadence, input (what it queries), output (what it writes), side effects. The `DepositExpiry` and `WithdrawalDispatcher` are the highest-stakes — read them twice.
- `services/` — `bankRotation.go`, `callbackService.go`, `withdrawalQueue.go`. These encode cross-cutting business rules.
- `helpers/security.go`, `helpers/utilty.go` (note the typo — it is `utilty` not `utility`), `helpers/signature.go` — these carry the financial-calculation + idempotency + SSRF-protection rules. Every doc that mentions "fee calculation" or "JWT signature" must cite these.
- `bank-bot/` — structure-only read for the baseline. Detail lives in `docs/bank-bot.md` (Workflow-1 may stub that file with a one-paragraph summary + TODO).

### Step 7 — Swagger cross-check (10 min)

```
jq '.paths | keys | length' swagger_simple.json
jq '.paths | keys[]' swagger_simple.json | head -30
```

Confirm that every route you recorded in Step 4 appears in swagger. If a route is in code but not in swagger, that is `[DRIFT: route undocumented in swagger]`. If a route is in swagger but not in code, that is `[DRIFT: swagger references removed endpoint]`.

Do not attempt to fix swagger in this workflow — just record drift.

### Step 8 — Write `docs/current-system.md` (45–60 min)

Use the template in §Template below. Strict rules:

1. Every non-trivial claim ends with a verification marker: `// verified: <path>@<hash>` where `<hash>` is the 7-char short of the baseline commit.
2. If a claim could not be verified, mark it `[UNVERIFIED — <reason>]` inline **AND** open an `arra_thread(title="<claim summary>", message="<context + cite file:line + reading A / reading B>")`. Replace the marker with `[AWAITING_THREAD:<threadId> — <reason>]`. Above **5% of total claims** carrying `[AWAITING_THREAD:*]`, stop after bulk-filing threads for every remaining unverified claim — close the baseline with a summary of open threads in §10 and in the PR body. **Do not hard-halt the session**; the threads discover answers async. Security-sensitive ambiguity still halts — see Escalation.
3. No forward-looking language ("will support", "is planned to") without a linked issue number. This is the **current system**, not the roadmap.
4. No marketing prose. No exclamation marks. No "seamless", "robust", "enterprise-grade".
5. Thai is acceptable in quoted strings from code (e.g., bank statement descriptions) but English only for prose.

### Step 9 — Write `docs/.baseline` (1 min)

Overwrite (not append — this is the one file that gets replaced each baseline):

```
current-system-baseline: <40-char commit hash>
last-verified-at:        <ISO 8601 date in GMT+7, e.g. 2026-04-14T21:30:00+07:00>
```

### Step 10 — Log learnings (10 min)

For every durable fact you discovered that is not already in the vault, write an `arra_learn` entry. Two **binding** rules — violating either produces broken titles in Studio:

### Rule 1 — `arra_learn(pattern=…)` takes raw markdown, **not** a pre-wrapped document

```
✅ GOOD (plain text pattern):
  arra_learn(
    pattern="drift — payout bson tags are camelCase while other models are snake_case.\n\nEvidence at ed45b7e:\n- models/payout.go:89-91 ...",
    concepts=["technical-writer", "repo:mobiz-payment-gateway", "current", "payout", "data-model", "drift"],
    project="github.com/kokarat/mobiz-payment-gateway",
    source="models/payout.go:89-91@ed45b7e"
  )

❌ BAD (embeds its own frontmatter — tool double-wraps; outer title becomes literal "---"):
  arra_learn(
    pattern="---\nname: drift — payout bson ...\ndescription: ...\ntype: learning\n---\n\n## Evidence...",
    ...
  )
```

The tool auto-generates the `title:` / `tags:` / `created:` / `source:` / `project:` frontmatter from the arguments. Passing your own `---\n...\n---` block gets double-wrapped — outer title becomes `"---"`.

### Rule 2 — direct file-write frontmatter template (when you skip the MCP tool — AGENTS.md §7 option 2)

```yaml
---
title: <one-line human-readable title — this is what Studio displays>
tags: [technical-writer, repo:mobiz-payment-gateway, current, <feature>, <special>]
created: <YYYY-MM-DD>
source: <file:line@commit or conversation source>
project: github.com/kokarat/mobiz-payment-gateway
---

# <same as title>

<body paragraphs>
```

**Always use `title:` — never `name:` + `description:`.** Studio's document-list UI indexes `title:`; `name:` is reserved for `SKILL.md` skill identity (different semantic). Retros and learnings written with `name:` but no `title:` render as blank rows in Studio until manually fixed.

### Tag layers (mandatory 3-layer)

- role — `technical-writer`
- repo scope — `repo:mobiz-payment-gateway` (or `repo:cross` if fact spans repos)
- system phase — `current`
- feature tags (recommended) — e.g. `bank-bot`, `scheduler`, `deposit`, `payout`, `settlement`
- special tags (only if applicable) — `drift`, `decision`, `handoff`

Typical baseline learnings:

- A field whose semantics are non-obvious (e.g. "`status: 1` means active for entities, but `status: 1` means completed for transactions").
- A non-idempotent side effect (e.g. "approving a topup writes to N partner wallets in a loop, no transaction — partial failure mid-loop is visible").
- A timer cadence or retry count that matters.
- Each `[DRIFT]` marker you added to `current-system.md` gets its own `#drift` learning with a trace linking commit → doc section → (future) resolution PR.

Aim for **5–15 learnings** from a first baseline. Much fewer and you probably didn't read carefully; much more and you are transcribing code (stop — the code is already the truth per P-004).

### Step 11 — Commit + PR (5 min)

Branch: `docs/baseline-current-<short-hash>` (e.g. `docs/baseline-current-1e48da1`).

Commit message:

```
docs: baseline current system at <short-hash>

Covers Go/Fiber + MongoDB + bank-bot as of <full-hash>.

- Added docs/current-system.md (<N> sections, <M> claims, <K> drift markers)
- Updated docs/.baseline
- Logged <X> arra_learn entries (see oracle)

No code behavior changes.

Closes #<issue if one exists>
```

PR body includes:

- Link to each `#drift` learning.
- List of any `[UNVERIFIED]` claims and why.
- A note: **"I will not merge this PR. Awaiting human review."**

Per `.agent/AGENTS.md` §9 (safety rules), **never** `gh pr merge`.

### Step 12 — Retrospective (5 min)

Run `rrr` per `.agent/AGENTS.md` §7. A baseline session without a retrospective is an incomplete baseline. AI Diary + Honest Feedback are mandatory.

---

## Template for `docs/current-system.md`

Use this skeleton. Do not renumber sections — downstream tooling and sibling agents expect stable anchors.

```markdown
# Current System — mobiz-payment-gateway

**Baseline commit:** `<40-char hash>`
**Baselined at:** `<ISO date GMT+7>`
**Baselined by:** `technical_writer` agent (pg-writer-oracle instance)
**Scope:** The running Go + Fiber + MongoDB + Node.js bank-bot system. Not the target system (see `docs/target-system.md`).

> This document is produced by following `.agent/skills/technical-writer/references/workflow-1-baseline-current.md`. Every non-trivial claim is cited against the baseline commit above. Claims marked `[UNVERIFIED]` are known gaps; claims marked `[DRIFT]` are code ↔ doc mismatches that have an open `arra_learn` entry tagged `#drift`.

## 1. Stack

- Runtime: Go 1.25, Fiber v2  // verified: main.go@<short>
- Database: MongoDB (primary) + read replica via `db.GetReadCollection()`  // verified: db/mongo.go@<short>
- Cache: Redis  // verified: db/redis.go@<short>
- Bank automation: Node.js + Playwright (separate process tree under `bank-bot/`)
- Auth: JWT access 8h + refresh 7d (Redis-backed)  // verified: helpers/jwt.go@<short>

## 2. Top-level entities

(Table: entity → model file → collection → status convention → key invariants)

## 3. API surface

### 3.1 Public (no auth)
### 3.2 JWT-protected
### 3.3 API-Key protected (client-facing)
### 3.4 Bot-secret protected (automation)
### 3.5 SSE

For each endpoint: method, path, middleware stack, request summary, response summary, side effects, file:line citation.

## 4. Data model (summary)

(If long: link to `docs/data-model.md`.)

## 5. Schedulers

One subsection per scheduler: cadence, input query, output writes, idempotency guarantee (or lack thereof), file:line.

## 6. Services and cross-cutting rules

Bank rotation, callback retry, withdrawal queue locking, per-bank busy/ready.

## 7. Security surface

JWT, API key, bot secret, rate limiting, SSRF protection, signature replay prevention, login logs.

## 8. External integrations

Bank-bot (SCB, KTB), callbacks, DigitalOcean Spaces (storage), Ollama (if enabled).

## 9. Known drift

Table of `[DRIFT]` markers with links to learnings.

## 10. Known unknowns

Table of `[UNVERIFIED]` markers with the reason each is unverified.

## 11. Next baseline triggers

What would cause a fresh baseline run (copy from workflow-1 §"When to run").
```

---

## Definition of Done

This workflow is complete **only** when all are true:

- [ ] `docs/current-system.md` exists and follows the template.
- [ ] Every non-trivial claim carries `// verified: <path>@<hash>`.
- [ ] `[UNVERIFIED]` markers are < 5% of total claims.
- [ ] Every `[DRIFT]` marker has a matching `arra_learn` entry tagged `#drift` + `#repo:mobiz-payment-gateway` + `#current` + `#technical-writer`.
- [ ] `docs/.baseline` exists with the exact two-line format.
- [ ] Git branch pushed; PR opened; **not merged**.
- [ ] Retrospective written under `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_slug.md`, including AI Diary + Honest Feedback.
- [ ] `arra_handoff` entry written with a pointer to the PR and the next unanswered question.

---

## Common pitfalls (learned the hard way)

- **Transcribing instead of summarizing.** A baseline is not a code listing. If a section is quoting > 10 lines of code, back off — the code is the truth; cite it, don't copy it.
- **Trusting `CLAUDE.md` over the code.** `CLAUDE.md` is the most useful starting point and the most dangerous trap. It encodes *intent*; the code encodes *behavior*. P-004 applies.
- **Reading controllers without reading middleware.** Auth, rate-limit, and request-token checks can add or remove behavior. A `POST /api/v1/deposits` with two middlewares behaves differently from the same handler with one — the endpoint summary must reflect the middleware stack.
- **Baselining during a rebase or merge.** If `git status` is dirty, you are baselining against a commit that does not exist in history. Restart on a clean commit.
- **Finishing without retrospective.** Without `rrr`, no one (including you, in a future session) knows how this baseline went, what took longer than expected, what surprised you. Mandatory.

---

## Escalation

- If you cannot verify > 5% of claims, **bulk-file one `arra_thread` per claim** (don't hard-halt). Close the baseline with the open-threads summary and note the count in the PR body. Root cause is usually either "code is newer than CLAUDE.md" (document the drift) or "I don't understand this subsystem" (name it in each thread). Next session's wake-up reconciles answered threads.
- If you find a security-sensitive behavior that `CLAUDE.md` does not mention (e.g. an auth bypass path), **halt AND open a thread AND CC `security_auditor` in `arra_inbox`** before continuing. Do not document the vulnerability in public `docs/*` files until `security_auditor` has acknowledged — the thread is for internal context only, not public exposure.
- If the baseline reveals that CURRENT and TARGET systems have started to share code (a merge instead of a migration), **halt** — that contradicts §3 of SKILL.md ("Current and Target, never mixed") and needs a human-level decision before the baseline can proceed. A thread here would be insufficient; this is an architectural drift that blocks the whole workflow.

---

## Change log for this workflow file

- 2026-04-14 — Initial version, written during technical_writer bootstrapping for mobiz-payment-gateway. Baseline commit of payment-gateway at time of writing: `1e48da1`.
